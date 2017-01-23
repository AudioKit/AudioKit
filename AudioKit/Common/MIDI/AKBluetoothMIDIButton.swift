//
//  AKBluetoothMIDIButton.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 1/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit

public class AKBluetoothMIDIButton: UIButton {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let viewController = CABTMIDICentralViewController()
        let navController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        navController.modalPresentationStyle = .popover
        let popC = navController.popoverPresentationController
        popC?.permittedArrowDirections = .any
        popC?.sourceRect = self.frame
        popC?.sourceView = self.superview
        let controller = self.superview?.next as? UIViewController
        controller?.present(navController, animated: true, completion: nil)
    }
}
