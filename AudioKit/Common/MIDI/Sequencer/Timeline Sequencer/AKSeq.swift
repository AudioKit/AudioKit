//
//  AKSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSeq {
    
    public var tracks = [AKSequencerTrack]()
    public var lengthInBeats: Double = 1.0 {
        didSet {
            tracks.forEach { $0.lengthInBeats = lengthInBeats }
        }
    }
    public var tempo: Double = 120.0 {
        didSet {
            tracks.forEach { $0.tempo = tempo }
        }
    }
    public var loopEnabled: Bool = true{
        didSet {
            tracks.forEach { $0.loopEnabled = loopEnabled }
        }
    }
    
    var timeline = AKTimeline()

    public func stopAllNotes() {
        tracks.forEach { $0.stopAllNotes() }
    }

    public func play() {
        tracks.forEach { $0.play() }
    }
    
    public func stop() {
        tracks.forEach { $0.stop() }
    }

    public func seek(to beat: Double, at time: AVAudioTime) {
        tracks.forEach { $0.seek(to: beat, at: time) }
    }
    
    public convenience init(node: AKNode) {
        let nodes = [AKNode]([node])
        self.init(nodes: nodes)
    }

    public init(nodes: [AKNode]) {
        var i = 0
        for node in nodes {
            tracks.append(AKSequencerTrack(target: node, index: i))
            i += 1
        }
    }
}
