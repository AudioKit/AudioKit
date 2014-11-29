//
//  ViewController.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var toneGenerator = ToneGenerator()
    var currentNotes = [ToneGeneratorNote](count: 13, repeatedValue: ToneGeneratorNote())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AKOrchestra.addInstrument(toneGenerator)
        AKOrchestra.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func keyPressed(sender: UIButton) {
        
        let frequencies = [440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880]
        let key = sender
        let index = key.tag
        
        key.backgroundColor = UIColor.redColor()
        let frequency = Float(frequencies[index])
        let note = ToneGeneratorNote()
        note.frequency.value = frequency
        toneGenerator.playNote(note)
        currentNotes[index]=note;
    }

    @IBAction func keyReleased(sender: UIButton) {
        
        let key = sender
        let index = key.tag
        let blackKey = (index==1 || index==3 || index==6 || index==8 || index==10)
        if  blackKey {
            key.backgroundColor = UIColor.blackColor()
        } else {
            key.backgroundColor = UIColor.whiteColor()
        }
        let noteToStop = currentNotes[index]
        noteToStop.stop()
    }
}

