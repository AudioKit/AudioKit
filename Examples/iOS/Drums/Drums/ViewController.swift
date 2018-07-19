//
//  ViewController.swift
//  Drums
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {

    let conductor = Conductor()

    @IBOutlet weak var drumPad11: AKButton!

    @IBOutlet weak var drumPad12: AKButton!

    @IBOutlet weak var drumPad13: AKButton!

    @IBOutlet weak var drumPad14: AKButton!

    @IBOutlet weak var drumPad21: AKButton!

    @IBOutlet weak var drumPad22: AKButton!

    @IBOutlet weak var drumPad23: AKButton!

    @IBOutlet weak var drumPad24: AKButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        drumPad11.callback = { button in
            try? self.conductor.drums.play(noteNumber: 36 - 12)
        }
        drumPad12.callback = { button in
            try? self.conductor.drums.play(noteNumber: 38 - 12)
        }
        drumPad13.callback = { button in
            try? self.conductor.drums.play(noteNumber: 42 - 12)
        }
        drumPad14.callback = { button in
            try? self.conductor.drums.play(noteNumber: 46 - 12)
        }
        drumPad21.callback = { button in
            try? self.conductor.drums.play(noteNumber: 41 - 12)
        }
        drumPad22.callback = { button in
            try? self.conductor.drums.play(noteNumber: 47 - 12)
        }
        drumPad23.callback = { button in
            try? self.conductor.drums.play(noteNumber: 50 - 12)
        }
        drumPad24.callback = { button in
            try? self.conductor.drums.play(noteNumber: 39 - 12)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
