// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

open class AKParameterAutomation {
    
    private var avAudioUnit: AVAudioUnit
    
    private var scheduleParameterBlock: AUScheduleParameterBlock?
    
    private var token: Int?
    
    private var automation: UnsafeMutableRawPointer?
    
    public init(_ avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
    }
    
    deinit {
        if let token = token {
            avAudioUnit.auAudioUnit.removeRenderObserver(token)
        }
        
        if let automation = automation {
            deleteAKParameterAutomation(automation)
        }
    }
    
    private func createAutomation() {
        if automation != nil { return }
        // cache the parameter block for best performance
        scheduleParameterBlock = avAudioUnit.auAudioUnit.scheduleParameterBlock
        automation = createAKParameterAutomation(scheduleParameterBlock)
        
        let observer = getAKParameterAutomationObserverBlock(automation)!
        token = avAudioUnit.auAudioUnit.token(byAddingRenderObserver: observer)
    }
    
    /// Start playback immediately with the specified offset (seconds) from the start of the sequence
    public func startPlayback(offset: Double = 0, rate: Double = 1) {
        if automation == nil { return }
        guard let lastTime = avAudioUnit.lastRenderTime else { return }
        let adjustedOffset = offset / rate;
        let time = lastTime.offset(seconds: -adjustedOffset)
        playAKParameterAutomation(automation, time, rate)
    }
    
    /// Start playback immediately from the specified absolute time and offset (seconds).
    /// This function is similar to startPlayback(offset: ), but ensures an absolute start time
    /// independent of execution speed or threading.
    public func startPlayback(at absoluteTime: AVAudioTime, offset: Double = 0, rate: Double = 1) {
        if automation == nil { return }
        let adjustedOffset = offset / rate;
        if (absoluteTime.isSampleTimeValid) {
            let time = absoluteTime.offset(seconds: -adjustedOffset)
            playAKParameterAutomation(automation, time, rate)
        }
        else if (absoluteTime.isHostTimeValid) {
            // AKParameterAutomation works with sample time, we need to convert
            guard let lastAudioTime = avAudioUnit.lastRenderTime, lastAudioTime.isHostTimeValid else { return }
            let lastTime = AVAudioTime.seconds(forHostTime: lastAudioTime.hostTime)
            let startTime = AVAudioTime.seconds(forHostTime: absoluteTime.hostTime)
            let time = lastAudioTime.offset(seconds: (startTime - lastTime) - adjustedOffset)
            playAKParameterAutomation(automation, time, rate)
        }
    }
    
    public func stopPlayback() {
        if automation == nil { return }
        stopAKParameterAutomation(automation)
    }
    
    /// When recording is enabled, any parameter changes during playback will be recorded.
    /// Changes will overwrite any existing points at the times the changes occur.
    public func setRecordingEnabled(_ enabled: Bool, for parameter: String) {
        if automation == nil { createAutomation() }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        setAKParameterAutomationRecordingEnabled(automation, addr, enabled)
    }
    
    public func isRecordingEnabled(for parameter: String) -> Bool {
        if automation == nil { return false }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return false }
        return getAKParameterAutomationRecordingEnabled(automation, addr)
    }
    
    /// Return a sorted array of all points of the given parameter
    public func getPoints(of parameter: String) -> [AKParameterAutomationPoint] {
        if automation == nil { return [] }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return [] }
        
        let count = getAKParameterAutomationPoints(automation, addr, nil, 0)
        let buffer = UnsafeMutablePointer<AKParameterAutomationPoint>.allocate(capacity: count)
        let filledCount = getAKParameterAutomationPoints(automation, addr, buffer, count)
        let points = Array(UnsafeBufferPointer(start: buffer, count: count))
        buffer.deallocate()
        
        return points.dropLast(count - filledCount)
    }
    
    /// Manually add an automation point to a parameter
    public func add(point: AKParameterAutomationPoint, to parameter: String) {
        add(points: [point], to: parameter)
    }

    /// Manually add automation points to a parameter
    public func add(points: [AKParameterAutomationPoint], to parameter: String) {
        if automation == nil { createAutomation() }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        addAKParameterAutomationPoints(automation, addr, points, points.count)
    }
    
    /// Set all automation points for a parameter, overriding any existing points
    public func set(points: [AKParameterAutomationPoint], of parameter: String) {
        if automation == nil { createAutomation() }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        setAKParameterAutomationPoints(automation, addr, points, points.count)
    }
    
    /// Clear all points within the specified time range
    public func clear(range: ClosedRange<Double>, of parameter: String) {
        if automation == nil { return }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        clearAKParameterAutomationRange(automation, addr, range.lowerBound, range.upperBound)
    }
    
    public func clearAllPoints(of parameter: String) {
        if automation == nil { return }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        clearAKParameterAutomationPoints(automation, addr)
    }
}

public extension AKParameterAutomationPoint {

    init(targetValue: AUValue,
         startTime: Double,
         rampDuration: Double) {
        self.init(targetValue: targetValue,
                  startTime: startTime,
                  rampDuration: rampDuration,
                  rampTaper: 1,
                  rampSkew: 0)
    }
}
