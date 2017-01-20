//
//  AKMIDIBluetoothWindow.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/19/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit

open class AKMIDIBluetoothWindow: CABTMIDICentralViewController, UIPopoverPresentationControllerDelegate {
    
    var midi: AKMIDI?
    var listener: AKMIDIListener?
    var sourceView: UIViewController?
    var navC: UINavigationController?
    
    public convenience init(midi: AKMIDI, listener: AKMIDIListener, sourceView: UIViewController) {
        self.init()
        self.midi = midi
        self.listener = listener
        self.sourceView = sourceView
        
        navC = UINavigationController(rootViewController: self)
        navC?.modalPresentationStyle = .popover
        let popC = navC?.popoverPresentationController
        popC!.permittedArrowDirections = UIPopoverArrowDirection.any
        popC?.sourceView = self.sourceView?.view
        popC?.delegate = self
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem =
            UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action:#selector(AKMIDIBluetoothWindow.doneAction))
        
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem =
            UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action:#selector(AKMIDIBluetoothWindow.doneAction))
    }
    
    public func show(){
        sourceView?.present(navC!, animated: true, completion: nil)
    }
    
    func doneAction(){
        dismiss(animated: true, completion: nil)
        midi?.closeAllInputs()
        midi?.openInput("Bluetooth")
        midi?.clearListeners()
        midi?.addListener(listener!)
    }
}
