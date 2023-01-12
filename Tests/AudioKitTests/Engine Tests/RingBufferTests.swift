// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

final class RingBufferTests: XCTestCase {

    func testRingBuffer() {
        let buffer = RingBuffer<Float>()

        let pushResult = buffer.push(1.666)

        XCTAssertTrue(pushResult)

        let popResult = buffer.pop()

        XCTAssertEqual(popResult, 1.666)

        var floats: [Float] = [1, 2, 3, 4, 5]

        _ = floats.withUnsafeBufferPointer { ptr in
            buffer.push(from: ptr)
        }

        floats = [0, 0, 0, 0, 0]

        _ = floats.withUnsafeMutableBufferPointer { ptr in
            buffer.pop(to: ptr)
        }

        XCTAssertEqual(floats, [1, 2, 3, 4, 5])

    }

    func testProducerConsumer() {

        let buffer = RingBuffer<Int>()

        class Producer: Thread {
            var buffer: RingBuffer<Int>

            init(buffer: RingBuffer<Int>) {
                self.buffer = buffer
            }

            override func main() {
                for i in 0 ..< 1000 {
                    XCTAssertTrue(buffer.push(i))
                }
            }
        }

        class Consumer: Thread {
            var buffer: RingBuffer<Int>

            init(buffer: RingBuffer<Int>) {
                self.buffer = buffer
            }

            override func main() {
                for i in 0 ..< 1000 {

                    while(true) {
                        if let value = buffer.pop() {
                            XCTAssertEqual(value, i)
                            break
                        }
                    }

                }
            }
        }

        let producer = Producer(buffer: buffer)
        let consumer = Consumer(buffer: buffer)

        consumer.start()
        producer.start()

        sleep(1)
    }

}
