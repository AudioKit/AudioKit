//
//  AKBluetoothMIDIButton.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import CoreAudioKit

class AKBTMIDICentralViewController: CABTMIDICentralViewController {
    var uiViewController: UIViewController?

    override public func viewDidLayoutSubviews() {
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

    /// Handle touches
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        let bluetoothMIDIViewController = AKBTMIDICentralViewController()
        let navController = UINavigationController(rootViewController: bluetoothMIDIViewController)

        navController.modalPresentationStyle = .popover

        let popC = navController.popoverPresentationController
        let centerPopup = realSuperView != nil
        let displayView = realSuperView ?? self.superview

        popC?.permittedArrowDirections = centerPopup ? [] : .any
        popC?.sourceRect = centerPopup ? CGRect(x: displayView!.bounds.midX,
                                                 y: displayView!.bounds.midY,
                                                 width: 0,
                                                 height: 0) : self.frame

        let controller = displayView!.next as? UIViewController
        controller?.present(navController, animated: true, completion: nil)

        popC?.sourceView = controller?.view
        bluetoothMIDIViewController.uiViewController = controller

    }

}
