// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import Atomics

final class WorkStealingQueueTests: XCTestCase {
    func testBasic() throws {
        let queue = WorkStealingQueue()

        for i in 0 ..< 1000 {
            queue.push(i)
        }

        var popCount = ManagedAtomic(0)
        let owner = Thread {
            while !queue.isEmpty {
                if queue.pop() != nil {
                    popCount.wrappingIncrement(ordering: .relaxed)
                }
            }
        }

        var theftCount = ManagedAtomic(0)
        let thief = Thread {
            while !queue.isEmpty {
                if queue.steal() != nil {
                    theftCount.wrappingIncrement(ordering: .relaxed)
                }
            }
        }

        owner.start()
        thief.start()

        sleep(2)

        XCTAssertTrue(owner.isFinished)
        XCTAssertTrue(thief.isFinished)

        // Stupid NSThread doesn't have join, so just use atomics.
        let pc = popCount.load(ordering: .relaxed)
        let tc = theftCount.load(ordering: .relaxed)

        // Shoud have at least some of each pops and thefts.
        XCTAssertGreaterThan(pc, 0)
        XCTAssertGreaterThan(tc, 0)

        // Everything should have been either popped or stolen
        XCTAssertEqual(pc + tc, 1000)
    }
}
