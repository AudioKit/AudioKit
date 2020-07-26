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

class WaveformView: NSView {
    let maroon = NSColor(calibratedRed: 0.79, green: 0.372, blue: 0.191, alpha: 1)

    var waveform: AKWaveform?

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    public func open(audioFile: AVAudioFile) {
        if waveform != nil {
            close()
        }

        if waveform == nil {
            waveform = AKWaveform(channels: Int(audioFile.fileFormat.channelCount),
                                  size: frame.size,
                                  waveformColor: maroon.cgColor,
                                  backgroundColor: nil)
            waveform?.isMirrored = true
            if let waveform = waveform {
                layer?.addSublayer(waveform)
                waveform.frame = frame
            }
        }

        AKWaveformDataRequest(audioFile: audioFile).getDataAsync(with: 1024,
                                                                 completionHandler: { data in

                                                                     guard let floatData = data else { return }
                                                                     AKLog("got waveform data")
                                                                     self.fill(with: floatData)
                                                                 })
    }

    private func fill(with data: FloatChannelData) {
        waveform?.fill(with: data)
    }

    public func close() {
        waveform?.dispose()
        waveform?.removeFromSuperlayer()
        waveform = nil
    }
}
