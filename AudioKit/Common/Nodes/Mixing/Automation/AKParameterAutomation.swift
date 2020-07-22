// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKParameterAutomation {
    private var avAudioUnit: AVAudioUnit
    private var scheduleParameterBlock: AUScheduleParameterBlock?
    private var renderObserverToken: Int?
    private var automationObserverToken: AUParameterObserverToken?
    private var automation: AKParameterAutomationHelperRef?

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
        guard var lastTime = avAudioUnit.lastRenderTime else { return }

        // In tests, we may not have a valid lastRenderTime, so
        // assume no rendering has yet occurred.
        if !lastTime.isSampleTimeValid {
            lastTime = AVAudioTime(sampleTime: 0, atRate: AKSettings.sampleRate)
            assert(lastTime.isSampleTimeValid)
        }

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

            guard let lastAudioTime = avAudioUnit.lastRenderTime else { return }

            // In tests, we don't have a valid host time.
            if !lastAudioTime.isHostTimeValid {
                startPlayback(offset: offset, rate: 1)
                return
            }

            // AKParameterAutomation works with sample time, we need to convert
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

    /// Manually add an automation point to a parameter
    public func add(point: AKParameterAutomationPoint, to parameter: AKNodeParameter) {
        add(points: [point], to: parameter)
    }

    /// Manually add automation points to a parameter
    public func add(points: [AKParameterAutomationPoint], to parameter: AKNodeParameter) {
        if automation == nil { createAutomation() }

        guard let addr = parameter.parameter?.address else { return }
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

    public func clearAllPoints(of parameter: AKNodeParameter) {
        guard let automation = automation else { return }
        guard let addr = parameter.parameter?.address else { return }
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

    func isLinear() -> Bool {
        return rampTaper == 1.0 && rampSkew == 0.0
    }
}

extension AKParameterAutomationPoint: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.targetValue == rhs.targetValue
            && lhs.startTime == rhs.startTime
            && lhs.rampDuration == rhs.rampDuration
            && lhs.rampTaper == rhs.rampTaper
            && lhs.rampSkew == rhs.rampSkew
    }
}

/// Replaces automation over a time range.
/// - Parameters:
///   - points: existing automation curve
///   - newPoints: new automation events
///   - startTime: start of range to replace
///   - stopTime: end of range to replace
/// - Returns: new automation curve
public func AKReplaceAutomation(points: [AKParameterAutomationPoint],
                                newPoints: [(Double, AUValue)],
                                startTime: Double,
                                stopTime: Double) -> [AKParameterAutomationPoint] {
    var result = points

    // Clear existing points in segment range.
    result.removeAll { point in
        point.startTime >= startTime && point.startTime <= stopTime
    }

    // Append recorded points.
    result.append(contentsOf: newPoints.map { point in
        AKParameterAutomationPoint(targetValue: point.1, startTime: point.0, rampDuration: 0.01)
    })

    // Sort vector by time.
    result.sort { $0.startTime < $1.startTime }

    return result
}

func evalRamp(start: Double,
              segment: AKParameterAutomationPoint,
              time: Double,
              endTime: Double) -> Double {
    let remain = endTime - time
    let taper = Double(segment.rampTaper)
    let goal = segment.targetValue

    // x is normalized position in ramp segment
    let x = (segment.rampDuration - remain) / segment.rampDuration
    let taper1 = start + (goal - start) * pow(x, abs(taper))
    let absxm1 = abs((segment.rampDuration - remain) / segment.rampDuration - 1.0)
    let taper2 = start + (goal - start) * (1.0 - pow(absxm1, 1.0 / abs(taper)))

    return taper1 * (1.0 - segment.rampSkew) + taper2 * segment.rampSkew
}

/// Returns a new piecewise-linear automation curve which can be handed off to the audio thread
/// for efficient processing.
///
/// - Parameters:
///   - initialValue: Starting point
///   - points: An array of automation points to convert
///   - resolution: Duration of each linear segment in seconds
///   
/// - Returns: A new array of piecewise linear automation points
public func AKEvaluateAutomation(initialValue: AUValue,
                                 points: [AKParameterAutomationPoint],
                                 resolution: Double) -> [AKAutomationEvent] {

    var result = [AKAutomationEvent]()

    // The last evaluated value
    var value = Double(initialValue)

    for i in 0 ..< points.count {
        let point = points[i]

        if point.isLinear() {

            result.append(AKAutomationEvent(targetValue: point.targetValue,
                                            startTime: point.startTime,
                                            rampDuration: point.rampDuration))
            value = Double(point.targetValue)

        } else {

            // Cut off the end if another point comes along.
            let endTime: Double = min(i < points.count - 1 ? points[i + 1].startTime : Double.greatestFiniteMagnitude,
                                      point.startTime + point.rampDuration)

            var t = point.startTime
            let start = value

            // March t along the segment
            while t <= endTime - resolution {

                value = evalRamp(start: start,
                                 segment: point,
                                 time: t + resolution,
                                 endTime: point.startTime + point.rampDuration)

                result.append(AKAutomationEvent(targetValue: AUValue(value),
                                                startTime: t,
                                                rampDuration: resolution))

                t += resolution
            }
        }

    }

    return result
}
