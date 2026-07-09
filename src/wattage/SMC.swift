// SMC.swift parses and decodes SMC values from the AppleSMC kernel extension.

// Attribution note:
//   Ported from github.com/beutton/wattsec (MIT)

import Foundation
import IOKit

func decodeSMCValue(dataType: String, bytes: [UInt8]) -> Double? {
    switch dataType {
    case "flt ":
        guard bytes.count >= 4 else { return nil }
        return bytes[0..<4].withUnsafeBytes {
            Double($0.load(as: Float32.self))
        }
    case "ui8 ":
        guard bytes.count >= 1 else { return nil }
        return Double(bytes[0])
    case "ui16":
        guard bytes.count >= 2 else { return nil }
        return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
    case "ui32":
        guard bytes.count >= 4 else { return nil }
        return bytes[0..<4].reduce(0.0) { $0 * 256 + Double($1) }
    case let type where type.hasPrefix("sp"):
        guard bytes.count >= 2, let fractionBits = UInt32(type.suffix(1), radix: 16) else { return nil }
        let raw = Int16(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
        return Double(raw) / Double(1 << fractionBits)
    case let type where type.hasPrefix("fp"):
        guard bytes.count >= 2, let fractionBits = UInt32(type.suffix(1), radix: 16) else { return nil }
        let raw = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        return Double(raw) / Double(1 << fractionBits)
    default:
        return nil
    }
}

enum SMCKeys: UInt8 {
    case kernelIndex = 2
    case readBytes = 5
    case readKeyInfo = 9
}

struct SMCKeyData_t {
    typealias SMCBytes_t = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8)

    struct vers_t {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }

    struct LimitData_t {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    struct keyInfo_t {
        var dataSize: IOByteCount32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
    }

    var key: UInt32 = 0
    var vers = vers_t()
    var pLimitData = LimitData_t()
    var keyInfo = keyInfo_t()
    var padding: UInt16 = 0
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: SMCBytes_t = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0))
}

struct SMCVal_t {
    var key: String
    var dataSize: UInt32 = 0
    var dataType: String = ""
    var bytes: [UInt8] = Array(repeating: 0, count: 32)

    init(_ key: String) {
        self.key = key
    }
}

extension FourCharCode {
    init(fromString str: String) {
        precondition(str.count == 4)

        self = str.utf8.reduce(0) { sum, character in
            return sum << 8 | UInt32(character)
        }
    }

    func toString() -> String {
        return String(describing: UnicodeScalar(self >> 24 & 0xff)!) +
               String(describing: UnicodeScalar(self >> 16 & 0xff)!) +
               String(describing: UnicodeScalar(self >> 8  & 0xff)!) +
               String(describing: UnicodeScalar(self       & 0xff)!)
    }
}

class SMC {
    private var conn: io_connect_t = 0

    init?() {
        var result: kern_return_t
        var iterator: io_iterator_t = 0
        let device: io_object_t

        let matchingDictionary: CFMutableDictionary = IOServiceMatching("AppleSMC")
        result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDictionary, &iterator)
        if result != kIOReturnSuccess {
            warn("IOServiceGetMatchingServices()", result)
            return nil
        }

        device = IOIteratorNext(iterator)
        IOObjectRelease(iterator)
        if device == 0 {
            warn("IOIteratorNext()", result)
            return nil
        }

        result = IOServiceOpen(device, mach_task_self_, 0, &conn)
        IOObjectRelease(device)
        if result != kIOReturnSuccess {
            warn("IOServiceOpen()", result)
            return nil
        }
    }

    deinit {
        IOServiceClose(conn)
    }

    func getValue(_ key: String) -> Double? {
        var val: SMCVal_t = SMCVal_t(key)

        let result = read(&val)
        if result != kIOReturnSuccess {
            warn("read(\(key))", result)
            return nil
        }

        return decodeSMCValue(dataType: val.dataType, bytes: Array(val.bytes[0..<Int(val.dataSize)]))
    }

    private func read(_ value: UnsafeMutablePointer<SMCVal_t>) -> kern_return_t {
        var result: kern_return_t = 0
        var input = SMCKeyData_t()
        var output = SMCKeyData_t()

        input.key = FourCharCode(fromString: value.pointee.key)
        input.data8 = SMCKeys.readKeyInfo.rawValue

        result = call(SMCKeys.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return result
        }

        value.pointee.dataSize = UInt32(output.keyInfo.dataSize)
        value.pointee.dataType = output.keyInfo.dataType.toString()
        input.keyInfo.dataSize = output.keyInfo.dataSize
        input.data8 = SMCKeys.readBytes.rawValue

        result = call(SMCKeys.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return result
        }

        memcpy(&value.pointee.bytes, &output.bytes, Int(value.pointee.dataSize))

        return kIOReturnSuccess
    }

    private func call(_ index: UInt8, input: inout SMCKeyData_t, output: inout SMCKeyData_t) -> kern_return_t {
        let inputSize = MemoryLayout<SMCKeyData_t>.stride
        var outputSize = MemoryLayout<SMCKeyData_t>.stride

        return IOConnectCallStructMethod(conn, UInt32(index), &input, inputSize, &output, &outputSize)
    }

    private func warn(_ context: String, _ result: kern_return_t) {
        let message = String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown error"
        FileHandle.standardError.write(Data("Error \(context): \(message)\n".utf8))
    }
}
