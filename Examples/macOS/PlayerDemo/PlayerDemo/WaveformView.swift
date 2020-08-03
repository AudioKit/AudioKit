//
//  WaveformView.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/26/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import AVFoundation
import Cocoa

/// A basic Waveform editor interface

class WaveformView: NSView {
    public struct Selection {
        var startTime: TimeInterval = 0
        var endTime: TimeInterval = 0
    }

    private let maroon = NSColor(calibratedRed: 0.79, green: 0.372, blue: 0.191, alpha: 1)

    public weak var delegate: WaveformViewDelegate?

    public var pixelsPerSample: Int = 1024

    public private(set) var waveform: AKWaveform?

    internal var fadeInLayer = ActionCAShapeLayer()
    internal var fadeOutLayer = ActionCAShapeLayer()
    internal var fadeColor = NSColor.black.withAlphaComponent(0.4).cgColor

    public private(set) lazy var timelineBar = TimelineBar(color: NSColor.white.cgColor)

    internal var inOutLayer = ActionCAShapeLayer()

    private var visualScaleFactor: Double = 30

    var mouseDownTime: TimeInterval = 0

    public var time: TimeInterval = 0 {
        didSet {
            timelineBar.frame.origin.x = CGFloat(time * visualScaleFactor)
        }
    }

    var timelineDuration: TimeInterval {
        startOffset + duration
    }

    public private(set) var duration: TimeInterval = 0 {
        didSet {
            outPoint = duration
        }
    }

    public private(set) var selection = Selection()

    public var inPoint: TimeInterval = 0 {
        didSet {
            updateSelectionLayer()
        }
    }

    public var outPoint: TimeInterval = 0 {
        didSet {
            updateSelectionLayer()
        }
    }

    public var startOffset: TimeInterval = 0 {
        didSet {
            updateLayers()
        }
    }

    public var fadeInOffset: TimeInterval = 0 {
        didSet {
            updateFadeIn()
        }
    }

    public var fadeOutOffset: TimeInterval = 0 {
        didSet {
            updateFadeOut()
        }
    }

    public var fadeInTime: TimeInterval = 0 {
        didSet {
            updateFadeIn()
        }
    }

    public var fadeOutTime: TimeInterval = 0 {
        didSet {
            updateFadeOut()
        }
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    // MARK: - Private Functions

    private func initialize() {
        wantsLayer = true

        fadeInLayer.fillColor = fadeColor
        fadeOutLayer.fillColor = fadeColor
        inOutLayer.backgroundColor = NSColor.white.withAlphaComponent(0.3).cgColor

        layer?.insertSublayer(inOutLayer, at: 0)
        // waveform to be inserted at: 1
        layer?.insertSublayer(fadeInLayer, at: 3)
        layer?.insertSublayer(fadeOutLayer, at: 4)
        layer?.insertSublayer(timelineBar, at: 5)
    }

    private func updateLayers() {
        guard duration > 0 else { return }

        let x: CGFloat = CGFloat(startOffset * visualScaleFactor)
        let virtualWidth = frame.width - x
        visualScaleFactor = Double(virtualWidth) / duration

        fadeInOffset = startOffset
        updateFadeOut()

        waveform?.frame = CGRect(x: x, y: 0, width: virtualWidth, height: frame.height)
        waveform?.updateLayer()

        timelineBar.setHeight(frame.height)
    }

    private func updateSelectionLayer() {
        let start = CGFloat(inPoint * visualScaleFactor)
        let end = CGFloat(outPoint * visualScaleFactor)
        inOutLayer.frame = CGRect(x: start, y: 0, width: end - start, height: frame.height)
        inOutLayer.setNeedsDisplay()
        updateSelection()
    }

    private func updateSelection() {
        selection.startTime = min(outPoint, inPoint)
        selection.endTime = max(inPoint, outPoint)
    }

    private func updateFadeIn() {
        guard fadeInTime > 0 else {
            fadeInLayer.path = nil
            return
        }

        let fh = frame.height - 1

        let fadePath = NSBezierPath()

        var fw = CGFloat(fadeInTime * visualScaleFactor)
        if fw < 3.0 { fw = 3.0 }

        let startX = CGFloat(fadeInOffset * visualScaleFactor)
        fadeInLayer.frame = CGRect(x: startX, y: 0, width: fw, height: fh)

        fadePath.move(to: NSPoint(x: 0, y: 0))
        fadePath.line(to: NSPoint(x: fw, y: fh))
        fadePath.line(to: NSPoint(x: fw, y: 0))
        fadePath.line(to: NSPoint(x: 0, y: 0))
        fadeInLayer.path = fadePath.cgPath
    }

    private func updateFadeOut() {
        guard fadeOutTime > 0 else {
            fadeOutLayer.path = nil
            return
        }

        let fh = frame.height - 1
        let fadePath = NSBezierPath()
        let startX = CGFloat(fadeOutOffset * visualScaleFactor)

        var fw = CGFloat(fadeOutTime * visualScaleFactor)
        if fw < 3.0 { fw = 3.0 }
        let x = fw

        fadeOutLayer.frame = CGRect(x: frame.width - startX - fw, y: 0, width: fw, height: fh)

        fadePath.move(to: NSPoint(x: fw, y: 0))
        fadePath.line(to: NSPoint(x: x - fw, y: 0))
        fadePath.line(to: NSPoint(x: x - fw, y: fh))
        fadePath.line(to: NSPoint(x: x, y: 0))
        fadeOutLayer.path = fadePath.cgPath
    }

    private func convertToTime(with event: NSEvent) -> Double {
        let loc = convert(event.locationInWindow, from: nil)
        var mouseTime = Double(loc.x / frame.width) * timelineDuration
        mouseTime = max(0, mouseTime)
        mouseTime = min(timelineDuration, mouseTime)
        return mouseTime
    }

    // MARK: - Public Functions

    public func open(url: URL) {
        if waveform != nil {
            close()
        }

        // it's good to reopen this file as using the same file object in multiple
        // places can be problematic
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            AKLog("Failed to open file for reading...")
            return
        }

        if waveform == nil {
            duration = audioFile.duration

            waveform = AKWaveform(channels: Int(audioFile.fileFormat.channelCount),
                                  size: frame.size,
                                  waveformColor: maroon.cgColor,
                                  backgroundColor: nil)
            waveform?.isMirrored = true
            waveform?.allowActions = false

            if let waveform = waveform {
                layer?.insertSublayer(waveform, at: 1)
                updateLayers()
            }
        }

        // fetch the waveform data
        AKWaveformDataRequest(audioFile: audioFile)
            .getDataAsync(with: pixelsPerSample,
                          completionHandler: { data in
                              guard let floatData = data else {
                                  AKLog("Error getting waveform data", type: .error)
                                  return
                              }
                              self.waveform?.fill(with: floatData)
                          })
    }

    public func close() {
        waveform?.dispose()
        waveform?.removeFromSuperlayer()
        waveform = nil
    }
}

// MARK: - Mouse Handlers

extension WaveformView {
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        inPoint = convertToTime(with: event)
        outPoint = inPoint
        delegate?.waveformSelected(source: self, at: inPoint)
    }

    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let time = convertToTime(with: event)
        delegate?.waveformScrubComplete(source: self, at: time)
    }

    override public func mouseDragged(with event: NSEvent) {
        outPoint = convertToTime(with: event)
        updateSelectionLayer()
        delegate?.waveformScrubbed(source: self, at: outPoint)
    }
}

protocol WaveformViewDelegate: class {
    func waveformSelected(source: WaveformView, at time: Double)
    func waveformScrubbed(source: WaveformView, at time: Double)
    func waveformScrubComplete(source: WaveformView, at time: Double)
}

// MARK: - Misc

class TimelineBar: ActionCAShapeLayer {
    public init(color: CGColor) {
        super.init()
        strokeColor = color
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        strokeColor = NSColor.white.cgColor
    }

    public func setHeight(_ height: CGFloat = 200) {
        lineWidth = 1

        let path = CGMutablePath()
        path.move(to: NSPoint(x: 0, y: 0))
        path.addLine(to: NSPoint(x: 0, y: height))
        self.path = path
    }
}

public extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }

        return path
    }
}
