import Foundation

guard let smc = SMC(),
      let watts = smc.getValue("PSTR") ?? smc.getValue("PDTR") else {
    exit(1)
}

print(String(format: "%.1f", watts))
