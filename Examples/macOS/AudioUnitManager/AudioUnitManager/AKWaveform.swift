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
    
    public var displayTimebar: Bool = true
    
    private var timelineBar = TimelineBar()
    
    public var time: Double = 0 {
        didSet {
            timelineBar.frame.origin.x = CGFloat(time * visualScaleFactor)
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
        guard file != nil else { return }
        
        let loc = convert( event.locationInWindow, from: nil)

        let mouseTime = Double(loc.x / frame.width) * file!.duration
        delegate?.waveformSelected(source: self, at: mouseTime)
        
        self.time = mouseTime
    }
    
    public func dispose() {
        file = nil
        plot = nil
        removeFromSuperview()
    }
    
}

public protocol AKWaveformDelegate: class {
    func waveformSelected(source: AKWaveform, at time: Double)
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



