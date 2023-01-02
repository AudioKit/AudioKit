// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

extension Int: DefaultInit {
    public init() { self = 0 }
}

final class WorkStealingQueueTests: XCTestCase {

    func testBasic() throws {

        let queue = WorkStealingQueue<Int>()

        let owner = Thread {
            for i in 0..<100_000_000 {
                queue.push(i)
            }
            while !queue.isEmpty {
                _ = queue.pop()
            }
        }

        let thief = Thread {
            while !queue.isEmpty {
                if let item = queue.steal() {
                    print("stole \(item)")
                }
            }
        }

        owner.start()
        thief.start()

        sleep(2)

    }

}
