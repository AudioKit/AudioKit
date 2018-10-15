//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/14/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSequencerTrack {
    var events = [AKMIDIEvent]()
    var target: AKNode

    public init(target: AKNode) {
        self.target = target
    }
}
