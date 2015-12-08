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
    let mic = AKMicrophone();
    @IBOutlet weak var plot: EZAudioPlot?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mixer = AKMixer(mic);
        mixer.volume = 0.25;
        audiokit.audioOutput = mixer;
        audiokit.start()
        
        plot?.plotType = EZPlotType.Buffer;
        
        mixer.output?.installTapOnBus(0, bufferSize: 1024, format: nil) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = 512;
                strongSelf.plot?.updateBuffer(buffer.floatChannelData[0], withBufferSize: 1024);
            }
        };
    }
    
    
    @IBAction func toggleSound(sender: NSButton) {
        if oscillator.amplitude >  0.0 {
            oscillator.amplitude = 0.0
            sender.title = "Play Sine Wave at 440Hz"
        } else {
            oscillator.amplitude = 0.25
            sender.title = "Stop Sine Wave at 440Hz"
        }
        sender.setNeedsDisplay()
    }

}

