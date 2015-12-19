//
//  mix.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public func mix(first: AKOperation, _ second: AKOperation, t: Double) -> AKOperation {
    let firstRatio = 1.0 - t
    return AKOperation("\(firstRatio * first)\(t * second)+")
}

public func mix(first: AKOperation, _ second: AKOperation, t: AKOperation) -> AKOperation {
    let firstRatio = 1.0 - t
    return AKOperation("\(firstRatio * first)\(t * second)+")
}