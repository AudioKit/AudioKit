//
//  AKPlaygroundUgens.swift
//  AudioKit Playgrounds
//
//  Created by Aurelius Prochazka on 4/7/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

public typealias AKValueCallback = (Double) -> Void

/// Used in Playground: Effects on Page: Sporth Custom Effect
public let throttleUgen =
    AKCustomUgen(name: "throttle", argTypes: "ff") { _, stack, userData in
        let maxChangePerSecond = stack.popFloat()
        let maxChange = maxChangePerSecond / Float(AKSettings.sampleRate)

        let destValue = stack.popFloat()
        var nextValue = destValue

        if let prevValue = userData.flatMap({ $0 as? Float }) {
            let change = destValue - prevValue
            if abs(change) > maxChange {
                nextValue = prevValue + (change > 0 ? maxChange : -maxChange)
            }
        }
        userData = nextValue
        stack.push(nextValue)
    }

public let tanhdistUgen =
    AKCustomUgen(name: "tanhdist", argTypes: "ff") { _, stack, _ in
        let parameter = stack.popFloat()
        let input = stack.popFloat()
        stack.push(tanh(input * parameter) * 0.7)
    }

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

public let callbackWithValueUgen =
    AKCustomUgen(name: "callbackWithValue", argTypes: "ff") { _, stack, userData in
        let value = stack.popFloat()
        let trigger = stack.popFloat()
        if trigger != 0 {
            if let callback = userData as? AKValueCallback {
                callback(Double(value))
            }
        }
        stack.push(trigger)
        stack.push(value)
    }
