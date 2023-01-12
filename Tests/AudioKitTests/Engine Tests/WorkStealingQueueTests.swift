// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

extension Int: DefaultInit {
    public init() { self = 0 }
}

final class WorkStealingQueueTests: XCTestCase {
    func testBasic() throws {
        let queue = WorkStealingQueue<Int>()

        for i in 0 ..< 1000 {
            queue.push(i)
        }

        let owner = Thread {
            while !queue.isEmpty {
                if let item = queue.pop() {
                    print("popped \(item)")
                }
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
