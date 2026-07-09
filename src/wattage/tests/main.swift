import Foundation

var failures = 0

func expect(_ actual: Double?, _ expected: Double?, _ label: String) {
    let matches: Bool
    switch (actual, expected) {
    case (nil, nil):
        matches = true
    case let (a?, e?):
        matches = abs(a - e) < 0.0001
    default:
        matches = false
    }
    if !matches {
        failures += 1
        print("FAIL \(label): expected \(String(describing: expected)), got \(String(describing: actual))")
    }
}

expect(decodeSMCValue(dataType: "flt ", bytes: [0x66, 0x66, 0xD6, 0x40]), 6.7, "flt")
expect(decodeSMCValue(dataType: "flt ", bytes: [0x66, 0x66]), nil, "flt short bytes")
expect(decodeSMCValue(dataType: "sp78", bytes: [0x1A, 0x40]), 26.25, "sp78")
expect(decodeSMCValue(dataType: "sp78", bytes: [0xFF, 0x00]), -1.0, "sp78 negative")
expect(decodeSMCValue(dataType: "spa5", bytes: [0x00, 0x20]), 1.0, "spa5")
expect(decodeSMCValue(dataType: "sp78", bytes: [0x1A]), nil, "sp short bytes")
expect(decodeSMCValue(dataType: "fpe2", bytes: [0x01, 0x90]), 100.0, "fpe2")
expect(decodeSMCValue(dataType: "fp88", bytes: [0x06, 0xB3]), 6.69921875, "fp88")
expect(decodeSMCValue(dataType: "ui8 ", bytes: [42]), 42.0, "ui8")
expect(decodeSMCValue(dataType: "ui16", bytes: [0x01, 0x00]), 256.0, "ui16")
expect(decodeSMCValue(dataType: "ui32", bytes: [0x00, 0x00, 0x01, 0x00]), 256.0, "ui32")
expect(decodeSMCValue(dataType: "ch8*", bytes: [0x41]), nil, "unknown type")

if failures > 0 {
    exit(1)
}
print("OK")
