import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Неверное случайное значение")
        }
        return Chip(chipType: chipType)
    }
    
    public func soldering() {
        let solderingTime = chipType.rawValue
        sleep(UInt32(solderingTime))
    }
}
