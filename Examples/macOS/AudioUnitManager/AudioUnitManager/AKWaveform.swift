// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AudioKitUI

/// This is a demo of an Audio Region class. Not for production use... ;)
public class AKWaveform: AKView {
    public var url: URL?
    public var plots = [AKWaveformLayer?]()
    public var file: EZAudioFile?
    public var visualScaleFactor: Double = 30
    public var color = NSColor.black
    public weak var delegate: AKWaveformDelegate?
    private var loopStartMarker = LoopMarker(.start)
    private var loopEndMarker = LoopMarker(.end)

    private var basicShadow: NSShadow {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5
        shadow.shadowOffset = CGSize(width: 2, height: -2)
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.7)
        return shadow
    }

    public var displayTimebar: Bool = true {
        didSet {
            timelineBar.isHidden = !displayTimebar
        }
    }

    private var timelineBar = TimelineBar()

    /// position in seconds of the bar
    public var position: Double {
        get {
            return Double(timelineBar.frame.origin.x) / visualScaleFactor
        }

        set {
            timelineBar.frame.origin.x = CGFloat(newValue * visualScaleFactor)
        }
    }

    public var loopStart: Double {
        get {
            return Double(loopStartMarker.frame.origin.x) / visualScaleFactor
        }

        set {
            loopStartMarker.frame.origin.x = CGFloat(newValue * visualScaleFactor)
        }
    }

    public var loopEnd: Double {
        get {
            return Double(loopEndMarker.frame.origin.x + loopEndMarker.frame.width) / visualScaleFactor
        }

        set {
            loopEndMarker.frame.origin.x = CGFloat(newValue * visualScaleFactor) - loopEndMarker.frame.width
        }
    }

    public var isLooping: Bool = false {
        didSet {
            loopStartMarker.isHidden = !isLooping
            loopEndMarker.isHidden = !isLooping
            needsDisplay = true
        }
    }

    public var isReversed: Bool = false {
        didSet {
            for plot in plots {
                if isReversed {
                    plot?.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, 1, 0)
                } else {
                    // To flip back to normal
                    plot?.transform = CATransform3DMakeRotation(0, 0, 1, 0)
                }
            }
        }
    }

    convenience init?(url: URL, color: NSColor = NSColor.white) {
        self.init()
        file = EZAudioFile(url: url)
        self.color = color
        if file == nil { return nil }
        initialize()
    }

    private func initialize() {
        wantsLayer = true
        layer = CALayer()

        frame = NSRect(x: 0, y: 0, width: 200, height: 20)

        guard let file = file else { return }
        guard let data = getFloatChannelData(withNumberOfPoints: 256) else { return }
        guard let leftData = data.first else { return }

        let leftPlot = createPlot(data: leftData)
        layer?.addSublayer(leftPlot)
        plots.insert(leftPlot, at: 0)

        // if the file is stereo add a second plot for the right channel
        if file.fileFormat.mChannelsPerFrame > 1, let rightData = data.last {
            let rightPlot = createPlot(data: rightData)
            layer?.addSublayer(rightPlot)
            plots.insert(rightPlot, at: 1)
        }
        loopStartMarker.delegate = self
        loopEndMarker.delegate = self
        addSubview(loopStartMarker)
        addSubview(loopEndMarker)
        addSubview(timelineBar)
        timelineBar.shadow = basicShadow
        isLooping = false
    }

    public func getFloatChannelData(withNumberOfPoints: Int) -> [[Float]]? {
        guard let file = file,
            let data = file.getWaveformData(withNumberOfPoints: UInt32(withNumberOfPoints)),
            let buffers = data.buffers else {
            return nil
        }
        var output = [[Float]]()

        // this makes a copy which isn't ideal
        if let leftData = buffers[0] {
            let leftBuffer = UnsafeBufferPointer(start: leftData, count: withNumberOfPoints)
            let floatBuffer = [Float](leftBuffer)
            output.append([Float](floatBuffer))
        }

        if file.fileFormat.mChannelsPerFrame > 1, let rightData = buffers[1] {
            let rightBuffer = UnsafeBufferPointer(start: rightData, count: withNumberOfPoints)
            let floatBuffer = [Float](rightBuffer)
            output.append(floatBuffer)
        }
        return output
    }

    private func createPlot(data: [Float]) -> AKWaveformLayer {
        let plot = AKWaveformLayer(table: data,
                                   size: nil,
                                   fillColor: color.cgColor,
                                   strokeColor: nil,
                                   backgroundColor: nil,
                                   opacity: 1,
                                   isMirrored: true)

        // add a shadow
        plot.shadowColor = NSColor.black.cgColor
        plot.shadowOpacity = 0.4
        plot.shadowOffset = NSSize(width: 1, height: -1)
        plot.shadowRadius = 2.0

        return plot
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard isLooping else { return }
        let loopShading = NSRect(x: loopStartMarker.frame.origin.x,
                                 y: 0,
                                 width: loopEndMarker.frame.origin.x - loopStartMarker.frame.origin.x +
                                     loopEndMarker.frame.width,
                                 height: frame.height)
        let rectanglePath = NSBezierPath(rect: loopShading)
        let color = NSColor(calibratedRed: 0.975, green: 0.823, blue: 0.573, alpha: 0.328)
        color.setFill()
        rectanglePath.fill()
    }

    public func fitToFrame() {
        guard let file = file, file.duration != 0 else { return }
        let w = Double(frame.width)
        let scale = w / file.duration
        visualScaleFactor = scale
        loopEndMarker.frame.origin.x = frame.width - loopEndMarker.frame.width - 3
    }

    public override func setFrameSize(_ newSize: NSSize) {
        guard let file = file else { return }
        guard !plots.isEmpty else { return }

        super.setFrameSize(newSize)

        let channels = CGFloat(file.fileFormat.mChannelsPerFrame)
        let waveformSize = NSSize(width: newSize.width, height: (newSize.height / channels) - 2)

        plots.first??.frame.origin = NSPoint(x: 0, y: channels == 1 ? 0 : newSize.height / channels)
        plots.first??.updateLayer(with: waveformSize)

        if channels > 1 {
            plots.last??.frame.origin = NSPoint()
            plots.last??.updateLayer(with: waveformSize)
        }
    }

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        position = mousePositionToTime(with: event)
        delegate?.waveformSelected(source: self, at: position)
    }

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        delegate?.waveformScrubComplete(source: self, at: position)
    }

    public override func mouseDragged(with event: NSEvent) {
        position = mousePositionToTime(with: event)
        delegate?.waveformScrubbed(source: self, at: position)
        needsDisplay = true
    }

    private func mousePositionToTime(with event: NSEvent) -> Double {
        guard let file = file else { return 0 }

        let loc = convert(event.locationInWindow, from: nil)
        let mouseTime = Double(loc.x / frame.width) * file.duration
        return mouseTime
    }

    public func dispose() {
        file = nil
        plots.removeAll()
        removeFromSuperview()
    }
}

extension AKWaveform: LoopMarkerDelegate {
    func markerMoved(source: LoopMarker) {
        if source.loopType == .start {
            source.frame.origin.x = max(0, source.frame.origin.x)
            source.frame.origin.x = min(source.frame.origin.x, loopEndMarker.frame.origin.x - loopEndMarker.frame.width)
        } else if source.loopType == .end {
            source.frame.origin.x = max(loopStartMarker.frame.origin.x + loopStartMarker.frame.width,
                                        source.frame.origin.x)
            source.frame.origin.x = min(source.frame.origin.x, frame.width - source.frame.width - 3)
        }
        needsDisplay = true
        delegate?.loopChanged(source: self)
    }
}

public protocol AKWaveformDelegate: class {
    func waveformSelected(source: AKWaveform, at time: Double)
    func waveformScrubbed(source: AKWaveform, at time: Double)
    func waveformScrubComplete(source: AKWaveform, at time: Double)
    func loopChanged(source: AKWaveform)
}

/// Class to show looping bounds on top of the waveform
class LoopMarker: AKView {
    public enum MarkerType {
        case start, end
    }

    public weak var delegate: LoopMarkerDelegate?
    public var loopType: MarkerType = .start
    private var mouseDownLocation: NSPoint?

    convenience init(_ loopType: MarkerType) {
        self.init(frame: NSRect(x: 0, y: 0, width: 5, height: 70))
        self.loopType = loopType
    }

    public func fitToFrame() {
        guard let superview = superview else { return }
        frame = NSRect(x: 0, y: 0, width: 6, height: superview.frame.height - 2)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        if loopType == .start {
            drawStartRepeat()
        } else if loopType == .end {
            drawEndRepeat()
        }
    }

    fileprivate func drawStartRepeat() {
        NSColor.black.setFill()
        let rectanglePath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 2, height: 66))
        rectanglePath.fill()

        let rectangle2Path = NSBezierPath(rect: NSRect(x: 0, y: 66, width: 5, height: 2))
        rectangle2Path.fill()

        let rectangle3Path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 5, height: 2))
        rectangle3Path.fill()
    }

    fileprivate func drawEndRepeat() {
        NSColor.black.setFill()
        let rectanglePath = NSBezierPath(rect: NSRect(x: 3, y: 0, width: 2, height: 66))
        rectanglePath.fill()

        let rectangle2Path = NSBezierPath(rect: NSRect(x: 0, y: 66, width: 5, height: 2))
        rectangle2Path.fill()

        let rectangle3Path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 5, height: 2))
        rectangle3Path.fill()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        mouseDownLocation = convert(event.locationInWindow, from: nil)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard let mouseDownLocation = mouseDownLocation else { return }

        let svLocation = convertEventToSuperview(theEvent: event)
        let pt = CGPoint(x: svLocation.x - mouseDownLocation.x, y: 0)
        setFrameOrigin(pt)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard superview != nil else { return }
        delegate?.markerMoved(source: self)
    }

    deinit {
        AKLog("* deinit AKWaveform")
    }
}

protocol LoopMarkerDelegate: class {
    func markerMoved(source: LoopMarker)
}

class TimelineBar: AKView {
    private let color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private var rect = NSRect(x: 0, y: 0, width: 2, height: 70)

    convenience init() {
        self.init(frame: NSRect(x: 0, y: 0, width: 2, height: 70))
        wantsLayer = true
    }

    public func updateSize(height: CGFloat = 0) {
        guard let superview = superview else { return }
        let theHeight = height > 0 ? height : superview.frame.height
        setFrameSize(NSSize(width: 2, height: theHeight))
        rect = NSRect(x: 0, y: 0, width: 2, height: bounds.height)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        if let context = NSGraphicsContext.current {
            context.shouldAntialias = false
        }
        color.setFill()
        rect.fill()
    }
}
