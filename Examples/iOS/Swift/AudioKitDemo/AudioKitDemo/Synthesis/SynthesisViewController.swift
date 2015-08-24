//
//  ViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


class SynthesisViewController: UIViewController {
    
    @IBOutlet var fmSynthesizerTouchView: UIView!
    @IBOutlet var tambourineTouchView: UIView!
    
    let tambourine    = AKTambourineInstrument()
    let fmSynthesizer = FMSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the vFMSynthesizeriew, typically from a nib.
        AKOrchestra.addInstrument(tambourine)
        AKOrchestra.addInstrument(fmSynthesizer)
        
        let amp = AKAmplifier(input: tambourine.output)
        AKOrchestra.addInstrument(amp)
        amp.start()
    }


    @IBAction func tapTambourine(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.locationInView(tambourineTouchView)
        let scaledX = touchPoint.x / tambourineTouchView.bounds.size.height
        let scaledY = 1.0 - touchPoint.y / tambourineTouchView.bounds.size.height
        
        let intensity = Float(scaledY*4000 + 20)
        let dampingFactor = Float(scaledX / 2.0)
        
        let note = AKTambourineNote(intensity: intensity, dampingFactor: dampingFactor)
        tambourine.playNote(note)
    }
    
    @IBAction func tapFMOscillator(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.locationInView(fmSynthesizerTouchView)
        let scaledX = touchPoint.x / fmSynthesizerTouchView.bounds.size.height
        let scaledY = 1.0 - touchPoint.y / fmSynthesizerTouchView.bounds.size.height
        
        let frequency = Float(scaledY*400)
        let color = Float(scaledX)
        
        let note = FMSynthesizerNote(frequency: frequency, color: color)
        fmSynthesizer.playNote(note)
    }
}
