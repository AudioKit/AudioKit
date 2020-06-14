//
//  AKAutomatable.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 9/10/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

@objc public protocol AKAutomatable: AnyObject {
    var parameterAutomation: AKParameterAutomation? { get }
    func startAutomation(at audioTime: AVAudioTime?, duration: AVAudioTime?)
    func stopAutomation()
}
