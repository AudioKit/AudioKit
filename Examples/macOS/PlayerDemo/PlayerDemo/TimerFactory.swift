//
//  TimerFactory.swift
//  ADD
//
//  Created by Ryan Francesconi on 10/5/18.
//  Copyright © 2018 Audio Design Desk. All rights reserved.
//
import Cocoa

public protocol AbstractTimer: class {
    var eventHandler: (() -> Void)? { get set }
    var state: TimerFactory.State { get }
    var timeInterval: TimeInterval { get }

    func resume()
    func suspend()
}

public class TimerFactory {
    // 60 frames per second
    public static let fps60: TimeInterval = 0.0167

    public enum TimerType {
        case repeating, classic, displayLink
    }

    public enum State {
        case suspended, resumed
    }

    public static func createTimer(type: TimerType, timeInterval: TimeInterval = fps60, leeway: Int = 100) -> AbstractTimer {
        switch type {
        case .classic:
            return BasicTimer(timeInterval: timeInterval, leeway: leeway)
        case .repeating:
            return RepeatingTimer(timeInterval: timeInterval, leeway: leeway)
        case .displayLink:
            // note, no interval or leeway for the DisplayLinkTimer
            return DisplayLinkTimer()
        }
    }
}

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
public class RepeatingTimer: AbstractTimer {
    public var eventHandler: (() -> Void)?
    public var state: TimerFactory.State = .suspended

    public private(set) var timeInterval: TimeInterval = 1
    // leeway in milliseconds
    public private(set) var leeway: Int = 100

    private let queue = DispatchQueue(label: "com.audiodesigndesk.ADD.RepeatingTimer", qos: .utility)

    init(timeInterval: TimeInterval, leeway: Int = 100) {
        self.timeInterval = timeInterval
        self.leeway = leeway
    }

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(), queue: queue)
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval, leeway: .milliseconds(leeway))
        t.setEventHandler { [weak self] in
            self?.eventHandler?()
        }
        return t
    }()

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

public class BasicTimer: AbstractTimer {
    public var eventHandler: (() -> Void)?
    public var state: TimerFactory.State = .suspended

    public private(set) var timeInterval: TimeInterval = 1
    public private(set) var leeway: Int = 100

    public private(set) var timer: Timer?

    init(timeInterval: TimeInterval, leeway: Int = 100) {
        self.timeInterval = timeInterval
    }

    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed

        if timer != nil {
            timer?.invalidate()
        }
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(handleEvent), userInfo: nil, repeats: true)
        timer?.tolerance = Double(leeway) / 1000

        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
    }

    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer?.invalidate()
        timer = nil
    }

    @objc func handleEvent() {
        eventHandler?()
    }

    deinit {
        timer?.invalidate()
        eventHandler = nil
    }
}

// Timer based on screen refresh rate
public class DisplayLinkTimer: AbstractTimer {
    private let queue = DispatchQueue(label: "com.audiodesigndesk.ADD.DisplayLinkTimer", qos: .utility)

    public var eventHandler: (() -> Void)? {
        didSet {
            displayLink?.callback = eventHandler
        }
    }

    // note, no interval or leeway for the DisplayLinkTimer
    public var timeInterval: TimeInterval {
        return 0
    }

    public var state: TimerFactory.State = .suspended

    private var displayLink: DisplayLink?

    init() {
        displayLink = DisplayLink()
    }

    public func resume() {
        guard state == .suspended else { return }
        state = .resumed

        displayLink?.start()
    }

    public func suspend() {
        guard state == .resumed else { return }
        state = .suspended

        displayLink?.suspend()
    }

    public func dispose() {
        displayLink?.cancel()
        displayLink = nil
    }
}

/**
 Analog to the CADisplayLink in iOS.
 */
public class DisplayLink {
    let timer: CVDisplayLink
    let source: DispatchSourceUserDataAdd

    var callback: (() -> Void)?

    var running: Bool { return CVDisplayLinkIsRunning(timer) }

    /**
     Creates a new DisplayLink that gets executed on the given queue

     - Parameters:
     - queue: Queue which will receive the callback calls
     */
    init?(onQueue queue: DispatchQueue = DispatchQueue.global(qos: .utility)) {
        // Source
        source = DispatchSource.makeUserDataAddSource(queue: queue)

        // Timer
        var timerRef: CVDisplayLink?

        // Create timer
        var successLink = CVDisplayLinkCreateWithActiveCGDisplays(&timerRef)

        // public typealias CVDisplayLinkOutputCallback = @convention(c) (CVDisplayLink, UnsafePointer<CVTimeStamp>, UnsafePointer<CVTimeStamp>, CVOptionFlags, UnsafeMutablePointer<CVOptionFlags>, UnsafeMutableRawPointer?) -> CVReturn

        if let timer = timerRef {
            // Set Output
            successLink = CVDisplayLinkSetOutputCallback(timer, { (timer: CVDisplayLink,
                                                                   currentTime: UnsafePointer<CVTimeStamp>,
                                                                   outputTime: UnsafePointer<CVTimeStamp>,
                                                                   _: CVOptionFlags,
                                                                   _: UnsafeMutablePointer<CVOptionFlags>,
                                                                   sourceUnsafeRaw: UnsafeMutableRawPointer?) -> CVReturn in

                // Un-opaque the source
                if let sourceUnsafeRaw = sourceUnsafeRaw {
                    // Update the value of the source, thus, triggering a handle call on the timer
                    let sourceUnmanaged = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(sourceUnsafeRaw)
                    sourceUnmanaged.takeUnretainedValue().add(data: 1)
                }
                return kCVReturnSuccess

            }, Unmanaged.passUnretained(source).toOpaque())

            guard successLink == kCVReturnSuccess else {
                Swift.print("Failed to create timer with active display")
                return nil
            }

            // Connect to display
            successLink = CVDisplayLinkSetCurrentCGDisplay(timer, CGMainDisplayID())

            guard successLink == kCVReturnSuccess else {
                NSLog("Failed to connect to display")
                return nil
            }
            self.timer = timer
        } else {
            Swift.print("Failed to create timer with active display")
            return nil
        }

        // Timer setup
        source.setEventHandler { [weak self] in
            self?.callback?()
        }
    }

    /// Starts the timer
    func start() {
        guard !running else { return }

        CVDisplayLinkStart(timer)
        source.resume()
    }

    /// Suspends the timer, can be restarted aftewards
    func suspend() {
        guard running else { return }
        CVDisplayLinkStop(timer)
        source.suspend()
    }

    func cancel() {
        guard running else { return }
        CVDisplayLinkStop(timer)
        source.cancel()
    }

    deinit {
        Swift.print("* { DisplayLink }")

        if running {
            cancel()
        }
    }
}
