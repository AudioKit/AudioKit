// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

open class AKParameterAutomation {
    private var avAudioUnit: AVAudioUnit
    private var scheduleParameterBlock: AUScheduleParameterBlock?
    private var renderObserverToken: Int?
    private var automationObserverToken: AUParameterObserverToken?
    private var automation: UnsafeMutableRawPointer?

    public init(_ avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
    }

    deinit {
        if let token = renderObserverToken {
            avAudioUnit.auAudioUnit.removeRenderObserver(token)
        }

        if let token = automationObserverToken {
            avAudioUnit.auAudioUnit.parameterTree?.removeParameterObserver(token)
        }

        if let automation = automation {
            deleteAKParameterAutomation(automation)
        }
    }

    private func createAutomation() {
        // only create the automation once:
        guard automation == nil else { return }

        let au = avAudioUnit.auAudioUnit

        // cache the parameter block for best performance
        scheduleParameterBlock = au.scheduleParameterBlock
        automation = createAKParameterAutomation(scheduleParameterBlock)

        guard let renderObserverBlock = getAKParameterAutomationRenderObserverBlock(automation),
            let automationObserverBlock = getAKParameterAutomationAutomationObserverBlock(automation) else {
            AKLog("Failed to create observation blocks")
            return
        }
        renderObserverToken = au.token(byAddingRenderObserver: renderObserverBlock)
        automationObserverToken = au.parameterTree?.token(byAddingParameterAutomationObserver: automationObserverBlock)
    }

    /// Start playback immediately with the specified offset (seconds) from the start of the sequence
    public func startPlayback(offset: Double = 0, rate: Double = 1) {
        guard let automation = automation else { return }
        guard let lastTime = avAudioUnit.lastRenderTime else { return }
        let adjustedOffset = offset / rate
        let time = lastTime.offset(seconds: -adjustedOffset)
        playAKParameterAutomation(automation, time, rate)
    }

    /// Start playback immediately from the specified absolute time and offset (seconds).
    /// This function is similar to startPlayback(offset: ), but ensures an absolute start time
    /// independent of execution speed or threading.
    public func startPlayback(at absoluteTime: AVAudioTime, offset: Double = 0, rate: Double = 1) {
        guard let automation = automation else {
            AKLog("Error: automation is nil")
            return
        }

        let adjustedOffset = offset / rate
        if absoluteTime.isSampleTimeValid {
            let time = absoluteTime.offset(seconds: -adjustedOffset)
            playAKParameterAutomation(automation, time, rate)
        } else if absoluteTime.isHostTimeValid {
            // AKParameterAutomation works with sample time, we need to convert
            guard let lastAudioTime = avAudioUnit.lastRenderTime, lastAudioTime.isHostTimeValid else { return }
            let lastTime = AVAudioTime.seconds(forHostTime: lastAudioTime.hostTime)
            let startTime = AVAudioTime.seconds(forHostTime: absoluteTime.hostTime)
            let time = lastAudioTime.offset(seconds: (startTime - lastTime) - adjustedOffset)
            playAKParameterAutomation(automation, time, rate)
        }
    }

    public func stopPlayback() {
        guard let automation = automation else { return }
        stopAKParameterAutomation(automation)
    }

    /// Arm or disarm a parameter for recording. This only has an effect during active playback.
    /// When armed, existing automation will play normally until the AUParameter receives a setValue() call with
    /// the .touch event type.
    /// Assuming the use of AKNodeParameter, this is done by calling the beginTouch() function.
    /// When a .touch event is received, existing automation will be muted, and any changes to the parameter's
    /// value will be written as points to the automation track at the times during playback in which they are
    /// received, overwriting existing points.
    /// Recording will continue until a setValue() call with the .release event type is received, or endTouch()
    /// in AKNodeParameter.
    /// When a .release event is received, normal playback will resume.
    public func setRecordingEnabled(_ enabled: Bool, for parameter: String) {
        if automation == nil { createAutomation() }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        setAKParameterAutomationRecordingEnabled(automation, addr, enabled)
    }

    public func isRecordingEnabled(for parameter: String) -> Bool {
        guard automation != nil else { return false }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return false }
        return getAKParameterAutomationRecordingEnabled(automation, addr)
    }

    /// Return a sorted array of all points of the given parameter.
    /// WARNING: for parameters armed for recording, this is not guaranteed to be up-to-date until playback is stopped.
    public func getPoints(of parameter: String) -> [AKParameterAutomationPoint] {
        guard automation != nil else { return [] }
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
        guard let automation = automation else { return }
        guard let addr = avAudioUnit.auAudioUnit.parameterTree?[parameter]?.address else { return }
        clearAKParameterAutomationRange(automation, addr, range.lowerBound, range.upperBound)
    }

    public func clearAllPoints(of parameter: String) {
        guard let automation = automation else { return }
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
