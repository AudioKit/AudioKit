// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

final class AtomicListTests: XCTestCase {

    func testAtomicList() {

        let list = AtomicList(size: 100)

        for i in 0..<10 {
            list.push(i)
        }

        class Worker: Thread {

            var index: Int
            var list: AtomicList

            init(index: Int, list: AtomicList) {
                self.index = index
                self.list = list
            }

            override func main() {
                while let index = list.pop() {
                    print("worker \(self.index) working on index \(index)")
                    usleep(100)
                    if index < 10 {
                        list.push(index+10)
                    }
                }
            }
        }

        let worker1 = Worker(index: 0, list: list)
        let worker2 = Worker(index: 1, list: list)

        worker1.start()
        worker2.start()

        sleep(1)
    }
}
