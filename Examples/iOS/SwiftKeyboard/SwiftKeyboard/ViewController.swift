//
//  ViewController.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var conductor = Conductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func keyPressed(sender: UIButton) {
        
        let key = sender
        let index = key.tag
        
        key.backgroundColor = UIColor.redColor()
        conductor.play(index)

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
        conductor.stop(index)

    }
    @IBAction func reverbSliderValueChanged(sender: UISlider) {
        conductor.setReverbFeedbackLevel(sender.value)
    }
    @IBAction func toneColorSliderValueChanged(sender: UISlider) {
        conductor.setToneColor(sender.value)
    }
}

