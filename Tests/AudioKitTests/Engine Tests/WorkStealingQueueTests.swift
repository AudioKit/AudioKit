// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

final class WorkStealingQueueTests: XCTestCase {
    func testBasic() throws {
        let queue = WorkStealingQueue()

        for i in 0 ..< 1000 {
            queue.push(i)
        }

        var popCount = 0
        let owner = Thread {
            while !queue.isEmpty {
                if queue.pop() != nil {
                    popCount += 1
                }
            }
        }

        var theftCount = 0
        let thief = Thread {
            while !queue.isEmpty {
                if queue.steal() != nil {
                    theftCount += 1
                }
            }
        }

        owner.start()
        thief.start()

        sleep(2)

        XCTAssertTrue(owner.isFinished)
        XCTAssertTrue(thief.isFinished)

        XCTAssertGreaterThan(popCount, 0)
        XCTAssertGreaterThan(theftCount, 0)

        XCTAssertEqual(popCount + theftCount, 1000)
    }
}
