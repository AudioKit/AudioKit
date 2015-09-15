//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A parent class to all instruments */
@objc class AKInstrument : AKParameter {
    
    /** All operations which need to be computed for this instrument */
    var operations: [AKParameter] = []
    
    /** A final audio output parameter */
    var output: AKParameter? {
        didSet {
            connect(AKAudioOutput(input: output!))
            leftOutput = output!.leftOutput
            rightOutput = output!.rightOutput
        }
    }
    
    /** Initialize and append to the list of instruments */
    override init() {
        super.init()
        AKManager.sharedManager.instruments.append(self)
    }
    
    /** Add a parameter to the operations and all of its dependencies */
    func connect(operation: AKParameter) {
        operation.connected = true
        operation.dependencies.forEach { (dependency) -> () in
            if !dependency.connected {
                connect(dependency)
            }
        }
        operations.append(operation)
    }

}