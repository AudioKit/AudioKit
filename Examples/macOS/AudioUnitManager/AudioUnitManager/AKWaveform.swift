//
//  AKWaveform.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 12/7/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AudioKitUI

public class AKWaveform: AKView {
    public var url: URL?
    public var plot: EZAudioPlot?
    public var file: EZAudioFile?
    public var visualScaleFactor: Double = 30
    public var color = NSColor.black
    public weak var delegate: AKWaveformDelegate?
    
    public var displayTimebar: Bool = true {
        didSet {
            timelineBar.isHidden = !displayTimebar
        }
    }
    
    private var timelineBar = TimelineBar()
    
    /// position in seconds of the bar
    public var position: Double = 0 {
        didSet {
            timelineBar.frame.origin.x = CGFloat(position * visualScaleFactor)
        }
    }

    convenience init?(url: URL, color: NSColor = NSColor.black) {
        self.init()
        
        self.file = EZAudioFile(url: url)
        self.color = color
        
        if file == nil { return nil }
        
        initialize()    
    }

    private func initialize() {
        frame = NSMakeRect(0, 0, 200, 20)

        guard let file = file else { return }
        
        guard let data = file.getWaveformData() else { return }
        plot = EZAudioPlot()
        
        guard let plot = plot else { return }
        
        plot.frame = NSMakeRect(0, 0, 200, 20)
        
        plot.plotType = EZPlotType.buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = self.color
        plot.wantsLayer = true
        
        plot.gain = 1.5 // just make it a bit more present looking
        
        // customize the waveform
        plot.waveformLayer.fillColor = self.color.cgColor
        plot.waveformLayer.lineWidth = 0.1
        plot.waveformLayer.strokeColor = self.color.withAlphaComponent(0.6).cgColor
        // add a shadow
        plot.waveformLayer.shadowColor = NSColor.black.cgColor
        plot.waveformLayer.shadowOpacity = 0.4
        plot.waveformLayer.shadowOffset = NSSize( width: 1, height: -1 )
        plot.waveformLayer.shadowRadius = 2.0
        
        plot.updateBuffer( data.buffers[0], withBufferSize: data.bufferSize )
        
        addSubview( plot )
        plot.redraw()
        
        ////////////
        
        addSubview(timelineBar)
        
    }
    
    public func fitToFrame() {
        guard file != nil, file?.duration != 0 else { return }
        
        let w = Double(frame.width)
        let scale = w / file!.duration
        
        visualScaleFactor = scale
        //handleScaleChanged()
    }
    
    override public func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        plot?.setFrameSize(newSize)
        plot?.redraw()
    }
    
    
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        position = mousePositionToTime(with: event)
        delegate?.waveformSelected(source: self, at: position)

    }
    
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        delegate?.waveformScrubComplete(source: self, at: position)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        position = mousePositionToTime(with: event)
        delegate?.waveformScrubbed(source: self, at: position)
    }
    
    private func mousePositionToTime(with event: NSEvent) -> Double {
        guard file != nil else { return 0 }
        let loc = convert( event.locationInWindow, from: nil)
        let mouseTime = Double(loc.x / frame.width) * file!.duration
        return mouseTime
    }
    
    public func dispose() {
        file = nil
        plot = nil
        removeFromSuperview()
    }
    
}

public protocol AKWaveformDelegate: class {
    func waveformSelected(source: AKWaveform, at time: Double)
    func waveformScrubbed(source: AKWaveform, at time: Double)
    func waveformScrubComplete(source: AKWaveform, at time: Double)
}


class TimelineBar: AKView {
    let red = NSColor( red: 0.6, green: 0.3, blue: 0.3, alpha: 0.5 )

    convenience init() {
        self.init(frame: NSRect(x:0, y:0, width:2, height:100) )
    }

    func updateSize(height:CGFloat = 0) {
        guard self.superview != nil else { return }
        
        let theHeight = height > 0 ? height : superview!.frame.height
        
        setFrameSize( NSSize( width:2, height:theHeight))
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let context = NSGraphicsContext.current {
            context.shouldAntialias = false
        }
        red.setFill()
        NSMakeRect(0, 0, 2, self.bounds.height).fill()
    }
}



