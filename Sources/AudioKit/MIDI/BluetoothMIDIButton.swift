// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(iOS)
import CoreAudioKit

/// Bluetooth MIDI Central View Controller
class BTMIDICentralViewController: CABTMIDICentralViewController {
    var uiViewController: UIViewController?

    /// Called when subview area layed out
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneAction))
    }

    /// Dismiss view cotnroller when done
    @objc public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}

/// A button that will pull up a Bluetooth MIDI menu
public class BluetoothMIDIButton: UIButton {

    private var realSuperView: UIView?

    /// Use this when your button's superview is not the entire screen, or when you prefer
    /// the aesthetics of a centered popup window to one with an arrow pointing to your button
    public func centerPopupIn(view: UIView) {
        realSuperView = view
    }

    /// Pull up a popover controller when the button is released
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        let bluetoothMIDIViewController = BTMIDICentralViewController()
        let navController = UINavigationController(rootViewController: bluetoothMIDIViewController)

        navController.modalPresentationStyle = .popover

        let popC = navController.popoverPresentationController
        let centerPopup = realSuperView != nil
        let displayView = realSuperView ?? self.superview

        popC?.permittedArrowDirections = centerPopup ? [] : .any
        if let displayView = displayView {
            popC?.sourceRect = centerPopup ? CGRect(x: displayView.bounds.midX,
                                                    y: displayView.bounds.midY,
                                                    width: 0,
                                                    height: 0) : self.frame
            let controller = nextResponderAsViewController(responder: displayView.next)
            controller?.present(navController, animated: true, completion: nil)

            popC?.sourceView = controller?.view
            bluetoothMIDIViewController.uiViewController = controller
        }
    }

    private func nextResponderAsViewController(responder: UIResponder?) -> UIViewController? {
        let next: UIResponder? = responder?.next
        if let viewController = next as? UIViewController {
            return viewController
        } else if next == nil {
            return nil
        } else {
            return nextResponderAsViewController(responder: next)
        }
    }

}
#endif
