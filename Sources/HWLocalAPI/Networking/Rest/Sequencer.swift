
import Foundation

internal actor Sequencer {
    nonisolated static var next: Int {
        get async {
            await shared.next()
        }
    }

    private var counter: Int = 0

    private static let shared = Sequencer()
    private init() {}

    func next() -> Int {
        counter += 1
        return counter
    }
}
