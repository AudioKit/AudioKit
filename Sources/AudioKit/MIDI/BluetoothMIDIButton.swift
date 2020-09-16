// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(iOS)
import CoreAudioKit

class AKBTMIDICentralViewController: CABTMIDICentralViewController {
    var uiViewController: UIViewController?

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneAction))
    }

    @objc public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}

/// A button that will pull up a Bluetooth MIDI menu
public class AKBluetoothMIDIButton: UIButton {

    private var realSuperView: UIView?

    /// Use this when your button's superview is not the entire screen, or when you prefer
    /// the aesthetics of a centered popup window to one with an arrow pointing to your button
    public func centerPopupIn(view: UIView) {
        realSuperView = view
    }

    /// Pull up a popover controller when the button is released
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        let bluetoothMIDIViewController = AKBTMIDICentralViewController()
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
            let controller = displayView.next as? UIViewController
            controller?.present(navController, animated: true, completion: nil)

            popC?.sourceView = controller?.view
            bluetoothMIDIViewController.uiViewController = controller
        }
    }

}
#endif
