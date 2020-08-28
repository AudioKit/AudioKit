// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)
import UIKit.UIGestureRecognizerSubclass

/// Extension of `UIGestureRecognizerDelegate` which allows the delegate to receive messages relating to
/// individual touches. The `delegate` property can be set to a class
/// implementing `MultitouchGestureRecognizerDelegate` and it will receive these messages.
@objc public protocol MultitouchGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    /// Called when a touch is started.
    @objc optional func multitouchGestureRecognizer(_ gestureRecognizer: MultitouchGestureRecognizer,
                                                    touchDidBegin touch: UITouch)

    /// Called when a touch is updates.
    @objc optional func multitouchGestureRecognizer(_ gestureRecognizer: MultitouchGestureRecognizer,
                                                    touchDidMove touch: UITouch)

    /// Called when a touch is cancelled.
    @objc optional func multitouchGestureRecognizer(_ gestureRecognizer: MultitouchGestureRecognizer,
                                                    touchDidCancel touch: UITouch)

    /// Called when a touch is ended.
    @objc optional func multitouchGestureRecognizer(_ gestureRecognizer: MultitouchGestureRecognizer,
                                                    touchDidEnd touch: UITouch)
}

/// `UIGestureRecognizer` subclass which tracks the state of individual touches.
public class MultitouchGestureRecognizer: UIGestureRecognizer {
    /// Denotes the way the list of touches is managed.
    public enum Mode {
        /// The first touch in is the first touch out.
        case stack

        /// The first touch in is the last touch out.
        case queue
    }

    /// The touch management mode.
    public var mode: Mode = .stack

    /// The maximum number of touches allowed in the stack/queue. Defaults to `0`, signifying unlimited touches.
    /// If `count` is decreased past the current number of touches, any excess touches will be ended immediately.
    public var count: Int = 0 {
        didSet {
            // swiftlint:disable empty_count
            if count != 0 {
                while count < touches.count {
                    switch mode {
                    case .stack:
                        if let lastTouch = touches.last {
                            end(lastTouch)
                        }
                    case .queue:
                        if let firstTouch = touches.first {
                            end(firstTouch)
                        }
                    }
                }
            }
        }
    }

    /// If `sustain` is set to `true`, when touches end they will be retained in `touches` until such time as all
    /// touches have ended and a new touch begins.
    /// If `sustain` is switched from `true` to `false`, any currently sustained touches will be ended immediately.
    public var sustain: Bool = true {
        didSet {
            if oldValue == true, sustain == false {
                end()
            }
        }
    }

    /// The currently tracked collection of touches. May contain touches after they have ended,
    /// if `sustain` is set to `true`.
    public private(set) lazy var touches = [UITouch]()

    /// The current gesture recognizer state, as it pertains to the `sustain` setting.
    public enum MultitouchState {
        /// All touches are ended, and none are being sustained.
        case ready

        /// One more more touches are currently in progress.
        case live

        /// All touches have ended, but one or more is being retained in the `touches` collection
        /// thanks to the `sustain` setting.
        case sustained
    }

    /// The current multitouch gesture recognizer state.
    public var multitouchState: MultitouchState {
        if touches.isEmpty {
            return .ready
        } else if touches.filter({ $0.phase != .ended }).isNotEmpty {
            return .live
        } else {
            return .sustained
        }
    }

    // MARK: - Delegate

    internal var multitouchDelegate: MultitouchGestureRecognizerDelegate? {
        return delegate as? MultitouchGestureRecognizerDelegate
    }

    // MARK: - Overrides

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        if sustain {
            end()
        }
        update(touches)
    }

    /// Handle moved touches
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        update(touches)
    }

    /// Handle cancelled touches
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        update(touches)
    }

    /// Handle ended touches
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        update(touches)
    }

    // MARK: - Touch updating

    private func update(_ touches: Set<UITouch>) {
        for touch in touches {
            switch touch.phase {
            case .began:
                start(touch)
            case .moved:
                move(touch)
            case .stationary:
                move(touch)
            case .cancelled:
                cancel(touch)
            case .ended where sustain:
                move(touch)
            case .ended:
                end(touch)
            case .regionEntered:
                break
            case .regionMoved:
                break
            case .regionExited:
                break
            @unknown default:
                fatalError("Unknown touch phase!")
            }
        }
    }

    private func end() {
        for touch in touches where touch.phase == .ended {
            end(touch)
        }
    }

    // MARK: - Single touches

    private func start(_ touch: UITouch) {
        guard count == 0 || count > touches.count else {
            if let firstTouch = touches.first, mode == .queue {
                end(firstTouch)
                start(touch)
            }
            return
        }

        touches.append(touch)
        multitouchDelegate?.multitouchGestureRecognizer?(self, touchDidBegin: touch)
    }

    private func move(_ touch: UITouch) {
        if touches.contains(touch) {
            multitouchDelegate?.multitouchGestureRecognizer?(self, touchDidMove: touch)
        }
    }

    private func cancel(_ touch: UITouch) {
        if touches.contains(touch) {
            touches.remove(touch)
            multitouchDelegate?.multitouchGestureRecognizer?(self, touchDidCancel: touch)
        }
    }

    private func end(_ touch: UITouch) {
        if touches.contains(touch) {
            touches.remove(touch)
            multitouchDelegate?.multitouchGestureRecognizer?(self, touchDidEnd: touch)
        }
    }
}

// MARK: - Centroid helpers

extension MultitouchGestureRecognizer {
    /// The average of all touch locations in the current view.
    public var centroid: CGPoint? {
        guard let view = view, touches.isNotEmpty else {
            return nil
        }

        let location = touches.reduce(.zero) { (location, touch) -> CGPoint in
            let touchLocation = touch.location(in: view)

            return CGPoint(
                x: location.x + touchLocation.x / CGFloat(touches.count),
                y: location.y + touchLocation.y / CGFloat(touches.count)
            )
        }

        return location
    }

    /// The average of all previous touch locations in the current view.
    public var previousCentroid: CGPoint? {
        guard let view = view, touches.isNotEmpty else {
            return nil
        }

        let location = touches.reduce(.zero) { (location, touch) -> CGPoint in
            let touchLocation = touch.previousLocation(in: view)

            return CGPoint(
                x: location.x + touchLocation.x / CGFloat(touches.count),
                y: location.y + touchLocation.y / CGFloat(touches.count)
            )
        }

        return location
    }
}

// MARK: - Private extensions

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        self = filter { $0 != element }
    }
}

#endif
