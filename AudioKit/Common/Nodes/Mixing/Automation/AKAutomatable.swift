// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

@objc public protocol AKAutomatable: AnyObject {
    var parameterAutomation: AKParameterAutomation? { get }
    func startAutomation(at audioTime: AVAudioTime?, duration: AVAudioTime?)
    func stopAutomation()
}
