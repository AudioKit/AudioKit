//
//  AKMIDIBluetoothWindow.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit

open class AKMIDIBluetoothWindow: CABTMIDICentralViewController, UIPopoverPresentationControllerDelegate {
    
    var sourceViewController: UIViewController?
    
    public convenience init(_ sourceViewController: UIViewController) {
        self.init()
        self.sourceViewController = sourceViewController
    }

    public func show(from sender: UIView) {
        let viewController = CABTMIDICentralViewController()
        let navController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: nil)
        navController.modalPresentationStyle = .popover
        let popC = navController.popoverPresentationController
        popC?.permittedArrowDirections = UIPopoverArrowDirection.any
        popC?.sourceRect = sender.frame
        popC?.sourceView = sender.superview
        
        sourceViewController!.present(navController, animated: true, completion: nil)
    }

}
