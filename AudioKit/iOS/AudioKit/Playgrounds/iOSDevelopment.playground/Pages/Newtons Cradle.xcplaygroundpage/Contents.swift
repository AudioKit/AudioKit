import UIKit
import PlaygroundSupport

import AudioKit

let file = try AKAudioFile(readFileName: "click.wav", baseDir: .resources)
var tink = try AKAudioPlayer(file: file)

var reverb = AKCostelloReverb(tink)
let gravity = 0.166
reverb.feedback = 0.2 / gravity
reverb.cutoffFrequency = 20_000 * gravity
AudioKit.output = AKMixer(tink, reverb)

AudioKit.start()
/*:
 ## Newton's Cradle and UIKit Dynamics
 This playground uses **UIKit Dynamics** to create a
 [Newton's Cradle](https://en.wikipedia.org/wiki/Newton%27s_cradle).
 Commonly seen on desks around the world, Newton's Cradle is a device
 that illustrates conservation of momentum and energy.
 
 Let's create an instance of our UIKit Dynamics based Newton's Cradle.
 Try adding more colors to the array to increase the number of balls in the device.
 */
let newtonsCradle = NewtonsCradle(colors:
    [[#Color(colorLiteralRed: 0.878, green: 0.381, blue: 0.577, alpha: 1)#],
    [#Color(colorLiteralRed: 0.220, green: 0.702, blue: 0.959, alpha: 1)#],
    [#Color(colorLiteralRed: 0.917, green: 0.4121, blue: 0.284, alpha: 1)#],
    [#Color(colorLiteralRed: 0.522, green: 0.8, blue: 0.346, alpha: 1)#]])
/*:
 ### Size and spacing
 Try changing the size and spacing of the balls and see how that changes the device.
 What happens if you make `ballPadding` a negative number?
 */
newtonsCradle.ballSize = CGSize(width: 60, height: 60)
newtonsCradle.ballPadding = 2.0
/*:
 ### Behavior
 Adjust `elasticity` and `resistance` to change how the balls react to eachother.
 */
newtonsCradle.itemBehavior.elasticity = 1.0
newtonsCradle.itemBehavior.resistance = 0.2
/*:
 ### Shape and rotation
 How does Newton's Cradle look if we use squares instead of circles and allow them to rotate?
 */
newtonsCradle.useSquaresInsteadOfBalls = false
newtonsCradle.itemBehavior.allowsRotation = false
/*:
 ### Gravity
 Change the `angle` and/or `magnitude` of gravity to see what
 Newton's Device might look like in another world.
 */
newtonsCradle.gravityBehavior.angle = CGFloat(M_PI_2)
newtonsCradle.gravityBehavior.magnitude = CGFloat(gravity)
/*:
 ### Attachment
 What happens if you change `length` of the attachment behaviors to different values?
 */
for attachmentBehavior in newtonsCradle.attachmentBehaviors {
    attachmentBehavior.length = 100
}

PlaygroundPage.current.liveView = newtonsCradle

public class NewtonsCradle: UIView, UICollisionBehaviorDelegate {

    private let colors: [UIColor]
    private var balls: [UIView] = []

    private var animator: UIDynamicAnimator?
    private var ballsToAttachmentBehaviors: [UIView:UIAttachmentBehavior] = [:]
    private var snapBehavior: UISnapBehavior?

    public let collisionBehavior: UICollisionBehavior
    public let gravityBehavior: UIGravityBehavior
    public let itemBehavior: UIDynamicItemBehavior

    public init(colors: [UIColor]) {
        self.colors = colors
        collisionBehavior = UICollisionBehavior(items: [])
        gravityBehavior = UIGravityBehavior(items: [])
        itemBehavior = UIDynamicItemBehavior(items: [])

        super.init(frame: CGRect(x: 0, y: 0, width: 480, height: 320))
        backgroundColor = UIColor.white

        animator = UIDynamicAnimator(referenceView: self)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(itemBehavior)

        createBallViews()
        collisionBehavior.collisionDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        for ball in balls {
            ball.removeObserver(self, forKeyPath: "center")
        }
    }

    // MARK: Collision

    public func collisionBehavior(behavior: UICollisionBehavior,
                                  beganContactForItem item1: UIDynamicItem,
                                  withItem item2: UIDynamicItem,
                                  atPoint point: CGPoint) {
        tink.stop()
        tink.play()
    }

    // MARK: Ball Views

    func createBallViews() {
        for color in colors {
            let ball = UIView(frame: CGRect.zero)

            // Observe the center point of the ball view to draw the attachment behavior.
            ball.addObserver(self,
                             forKeyPath: "center",
                             options: NSKeyValueObservingOptions(rawValue: 0),
                             context: nil)

            // Make the ball view round and set the background
            ball.backgroundColor = color

            // Add the balls as a subview before we add it to any UIDynamicBehaviors.
            addSubview(ball)
            balls.append(ball)

            // Layout the balls based on the ballSize and ballPadding.
            layoutBalls()
        }
    }

    // MARK: Properties

    public var attachmentBehaviors: [UIAttachmentBehavior] {
        var attachmentBehaviors: [UIAttachmentBehavior] = []
        for ball in balls {
            guard let attachmentBehavior = ballsToAttachmentBehaviors[ball]
                else { fatalError("Can't find attachment behavior for \(ball)") }
            attachmentBehaviors.append(attachmentBehavior)
        }
        return attachmentBehaviors
    }

    public var useSquaresInsteadOfBalls: Bool = false {
        didSet {
            for ball in balls {
                if useSquaresInsteadOfBalls {
                    ball.layer.cornerRadius = 0
                } else {
                    ball.layer.cornerRadius = ball.bounds.width / 2.0
                }
            }
        }
    }

    public var ballSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            layoutBalls()
        }
    }

    public var ballPadding: Double = 0.0 {
        didSet {
            layoutBalls()
        }
    }

    // MARK: Ball Layout

    private func layoutBalls() {
        let requiredWidth = CGFloat(balls.count) * (ballSize.width + CGFloat(ballPadding))
        for (index, ball) in balls.enumerate() {
            // Remove any attachment behavior that already exists.
            if let attachmentBehavior = ballsToAttachmentBehaviors[ball] {
                animator?.removeBehavior(attachmentBehavior)
            }

            // Remove the ball from the appropriate behaviors before update its frame.
            collisionBehavior.removeItem(ball)
            gravityBehavior.removeItem(ball)
            itemBehavior.removeItem(ball)

            // Determine the horizontal position of the ball based on the number of balls.
            let ballXOrigin = ((bounds.width - requiredWidth) / 2.0) +
                (CGFloat(index) * (ballSize.width + CGFloat(ballPadding)))
            ball.frame = CGRect(x: ballXOrigin,
                                y: bounds.midY,
                                width: ballSize.width,
                                height: ballSize.height)

            // Create the attachment behavior.
            let attachmentBehavior = UIAttachmentBehavior(item: ball,
                                                          attachedToAnchor:
                CGPoint(x: ball.frame.midX, y: bounds.midY - 50))
            ballsToAttachmentBehaviors[ball] = attachmentBehavior
            animator?.addBehavior(attachmentBehavior)

            // Add the collision, gravity and item behaviors.
            collisionBehavior.addItem(ball)
            gravityBehavior.addItem(ball)
            itemBehavior.addItem(ball)
        }
    }

    // MARK: Touch Handling

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(superview)
            for ball in balls {
                if ball.frame.contains(touchLocation) {
                    snapBehavior = UISnapBehavior(item: ball, snapToPoint: touchLocation)
                    animator?.addBehavior(snapBehavior!)
                }
            }
        }
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(superview)
            if let snapBehavior = snapBehavior {
                snapBehavior.snapPoint = touchLocation
            }
        }
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let snapBehavior = snapBehavior {
            animator?.removeBehavior(snapBehavior)
        }
        snapBehavior = nil
    }

    // MARK: KVO

    public override func observeValueForKeyPath(keyPath: String?,
                                                ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {
        if keyPath == "center" {
            setNeedsDisplay()
        }
    }

    // MARK: Drawing

    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)

        for ball in balls {
            guard let attachmentBehavior = ballsToAttachmentBehaviors[ball]
                else { fatalError("Can't find attachment behavior for \(ball)") }
            let anchorPoint = attachmentBehavior.anchorPoint

            CGContextMoveToPoint(context, anchorPoint.x, anchorPoint.y)
            CGContextAddLineToPoint(context, ball.center.x, ball.center.y)
            CGContextSetStrokeColorWithColor(context, UIColor.darkGray.CGColor)
            CGContextSetLineWidth(context, 4.0)
            CGContextStrokePath(context)

            let attachmentDotWidth: CGFloat = 10.0
            let attachmentDotOrigin = CGPoint(x: anchorPoint.x - (attachmentDotWidth / 2),
                                              y: anchorPoint.y - (attachmentDotWidth / 2))
            let attachmentDotRect = CGRect(x: attachmentDotOrigin.x,
                                           y: attachmentDotOrigin.y,
                                           width: attachmentDotWidth,
                                           height: attachmentDotWidth)

            CGContextSetFillColorWithColor(context, UIColor.darkGray.CGColor)
            CGContextFillEllipseInRect(context, attachmentDotRect)
        }

        CGContextRestoreGState(context)
    }

}
