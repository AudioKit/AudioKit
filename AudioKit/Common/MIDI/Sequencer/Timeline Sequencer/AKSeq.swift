//
//  AKSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSeq {
    
    public var tracks = [AKTimelineSequencer]()
    var timeline = AKTimeline()

    public func play() {
        for track in tracks {
            track.play()
        }
        print("playing \(tracks.count) tracks")
    }
    
    public func stop() {
        for track in tracks {
            track.stop()
        }
    }

    public func seek(to beat: Double, at time: AVAudioTime) {
        for track in tracks {
            track.setBeatTime(beat, at: time)
        }
    }
    
    public convenience init(node: AKNode) {
        let nodes = [AKNode]([node])
        self.init(nodes: nodes)
    }

    public init(nodes: [AKNode]) {
        var i = 0
        for node in nodes {
            tracks.append(AKTimelineSequencer(node: node, index: Int32(i)))
            i += 1
        }
        print("initin w \(i) nodes")
    }
}
