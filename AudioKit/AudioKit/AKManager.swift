//
//  AKManager.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKManager {
    public static let sharedManager = AKManager()
    public var engine = AVAudioEngine()
    public var audioOutput: AKOperation? {
        didSet {
            engine.connect(audioOutput!.output!, to: engine.outputNode, format: nil)
        }
    }
    public func start() {
        // Start the engine.
        do {
            try self.engine.start()
        }
        catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
}