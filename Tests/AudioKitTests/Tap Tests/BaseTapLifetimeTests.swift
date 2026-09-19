import AVFoundation
import XCTest
@testable import AudioKit

final class BaseTapLifetimeTests: XCTestCase {
    func testCallbackCanOverlapStopAndRestart() throws {
        let engine = AVAudioEngine()
        let node = CapturingTapNode()
        engine.attach(node.avAudioNode)
        let delivery = DispatchQueue(label: "BaseTapLifetimeTests.stress.delivery")
        let tap = BaseTap(node, bufferSize: 64, callbackQueue: delivery)
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 64))
        buffer.frameLength = 64
        let time = AVAudioTime(sampleTime: 0, atRate: 44_100)
        tap.start()
        let callback = try XCTUnwrap(node.mixer.callback)
        let group = DispatchGroup()
        let started = DispatchSemaphore(value: 0)
        group.enter()
        DispatchQueue(label: "BaseTapLifetimeTests.render").async {
            started.signal()
            for _ in 0..<10_000 { callback(buffer, time) }
            group.leave()
        }
        XCTAssertEqual(started.wait(timeout: .now() + 2), .success)
        for _ in 0..<1_000 {
            tap.stop()
            tap.start()
        }
        XCTAssertEqual(group.wait(timeout: .now() + 10), .success)
        tap.stop()
        delivery.sync {}
        XCTAssertFalse(tap.isStarted)
    }

    func testStopDiscardsCallbackInvokedByRemoveTap() throws {
        let engine = AVAudioEngine()
        let node = CapturingTapNode()
        engine.attach(node.avAudioNode)
        let queue = DispatchQueue(label: "BaseTapLifetimeTests.removal")
        let tap = RecordingTap(node, bufferSize: 64, callbackQueue: queue)
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 64))
        buffer.frameLength = 64
        let time = AVAudioTime(sampleTime: 0, atRate: 44_100)
        tap.start()
        let callback = try XCTUnwrap(node.mixer.callback)
        node.mixer.onRemoveTap = { callback(buffer, time) }

        tap.stop()
        queue.sync {}

        XCTAssertFalse(tap.isStarted)
        XCTAssertEqual(tap.deliveredCount, 0)
    }

    func testCallbacksFromPreviousInstallationAreDiscarded() throws {
        let engine = AVAudioEngine()
        let node = CapturingTapNode()
        engine.attach(node.avAudioNode)
        let queue = DispatchQueue(label: "BaseTapLifetimeTests.delivery")
        let tap = RecordingTap(node, bufferSize: 64, callbackQueue: queue)
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 64))
        buffer.frameLength = 64
        let time = AVAudioTime(sampleTime: 0, atRate: 44_100)

        tap.start()
        let previousCallback = try XCTUnwrap(node.mixer.callback)
        // Hold delivery while a native callback is in flight across stop/start.
        queue.suspend()
        previousCallback(buffer, time)
        tap.stop()
        tap.start()
        previousCallback(buffer, time)
        node.mixer.callback?(buffer, time)
        queue.resume()
        queue.sync {}

        XCTAssertEqual(tap.deliveredCount, 1, "Only the current installation may deliver analysis")
        tap.stop()
        previousCallback(buffer, time)
        queue.sync {}
        XCTAssertEqual(tap.deliveredCount, 1)
    }
}

private final class RecordingTap: BaseTap {
    var deliveredCount = 0
    override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        deliveredCount += 1
    }
}

private final class CapturingTapNode: Node {
    let mixer = CapturingMixer()
    var avAudioNode: AVAudioNode { mixer }
    var connections: [Node] { [] }
}

private final class CapturingMixer: AVAudioMixerNode, @unchecked Sendable {
    var callback: AVAudioNodeTapBlock?
    var onRemoveTap: (() -> Void)?
    override func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount,
                             format: AVAudioFormat?, block tapBlock: @escaping AVAudioNodeTapBlock) {
        callback = tapBlock
    }
    override func removeTap(onBus bus: AVAudioNodeBus) {
        onRemoveTap?()
        callback = nil
    }
}
