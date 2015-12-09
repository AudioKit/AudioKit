//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    let audiokit = AKManager.sharedInstance
    let oscillator = AKOscillator()
    let bufferSize: UInt32 = 512
    @IBOutlet weak var plot: EZAudioPlot?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mixer = AKMixer(oscillator);
        audiokit.audioOutput = mixer;
        audiokit.start()
        
        mixer.output?.installTapOnBus(0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData[0];
                strongSelf.plot?.updateBuffer(&tail[offset],
                    withBufferSize: strongSelf.bufferSize);
            }
        }
    }
    
    @IBAction func toggleSound(sender: NSButton) {
        if oscillator.amplitude >  0.5 {
            oscillator.amplitude = 0.0
            sender.title = "Play Sine Wave at 440Hz"
        } else {
            oscillator.amplitude = 1.0
            sender.title = "Stop Sine Wave at 440Hz"
        }
        sender.setNeedsDisplay()
    }

    @IBAction func changePlotType(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            plot?.plotType = .Buffer
        case 1:
            plot?.plotType = .Rolling
        default:
            break
        }
    }
}

