//
//  AKMetronome.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/4/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

public let callbackUgen =
    AKCustomUgen(name: "callback", argTypes: "f") { _, stack, userData in
        let trigger = stack.popFloat()
        if trigger != 0 {
            if let callback = userData as? AKCallback {
                callback()
            }
        }
        stack.push(trigger)
}

public class AKMetronome: AKOperationGenerator {
    
    public var tempo: Double = 60 { didSet { parameters[0] = tempo } }
    
    public var subdivision: Int = 4 { didSet { parameters[1] = Double(subdivision) } }
    
    public var currentBeat: Int {
        get { return 1 + Int((parameters[2] + 1).truncatingRemainder(dividingBy: Double(subdivision)))  }
        set(newValue) { parameters[2] = Double(newValue) }
    }
    
    public var callback: AKCallback {
        didSet {
            callbackUgen.userData = callback
        }
    }
    
    public init() {
        let sporth = "480 2 (0 p) 60 / metro (_callback f) (1 p) 0 count dup 2 pset (1 p) / 0.49 + round - * 1 sine (0 p) 60 / metro 0.01 0 0.05 tenv * dup"
        callback = { _ in return }
        super.init(sporth: sporth, customUgens: [callbackUgen])
        parameters = [tempo, Double(subdivision), -1]
    }
    
    public func reset() {
        currentBeat = -1
    }
}
