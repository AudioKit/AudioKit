//
//  ViewController.swift
//  AbletonLinkDemo
//
//  Created by Joshua Thompson on 7/15/17.
//  Copyright © 2017 Joshua Thompson. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    //MARK: UI properties
    @IBOutlet weak var tempoTextField: UITextField!
    
    //MARK: Properties
    var conductor: Conductor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        conductor = Conductor(vc: self)
        conductor.setupTracks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: called to update sequencer tempo and update UI
    func updateSessionTempo(tempo: Double){
        conductor.currentTempo = tempo
        tempoTextField.text = "\(Int(tempo))"
    }
    
    //MARK: Tempo update callback triggered by Ableton Link tempo update
    func onSessionTempoChanged(bpm: Float64)->Void{
        updateSessionTempo(tempo: bpm)
    }
    
    

}

