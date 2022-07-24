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

class Stack {
    private var storage: [Chip] = []
    var counter: Int = 0
    private let condition = NSCondition()
    
    public var isAvailable = false
    
    public var isEmpty: Bool {
        return storage.isEmpty
    }
    
    func push(item: Chip) {
        condition.lock()
        storage.append(item)
        counter += 1
        print("Чип \(counter) добавлен в хранилище.")
        print("Чипы в наличии \(storage)\n")
        isAvailable = true
        condition.signal()
        condition.unlock()
    }
    
    func pop() -> Chip {
        while (!isAvailable) {
            condition.wait()
        }
        let lastChip = storage.removeLast()
        condition.signal()
        condition.unlock()
        if isEmpty {
            isAvailable = false
        }
        return lastChip
    }
    
}

class GenerationThread: Thread {
    private var timer = Timer()
    private var storage: Stack
    
    init(storage: Stack) {
        self.storage = storage
    }
    
    override func main() {
        timer = Timer(timeInterval: 2, repeats: true) { [unowned self] _ in
            self.storage.push(item: Chip.make())
        }
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 20))
    }
}

class WorkThread: Thread {
    private var storage: Stack
    
    init(storage: Stack) {
        self.storage = storage
    }
    
    override func main() {
        repeat {
            let lastChip = storage.pop()
            lastChip.soldering()
            print("Чип припаян - \(lastChip)\n")
        } while storage.isAvailable || storage.isEmpty
    }
}

let storage = Stack()
let worker = WorkThread(storage: storage)
let generator = GenerationThread(storage: storage)

generator.start()
worker.start()
