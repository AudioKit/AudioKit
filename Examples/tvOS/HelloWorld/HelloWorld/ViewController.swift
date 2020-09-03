// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {

    @IBOutlet private var plot: AKNodeOutputPlot!

    var oscillator = AKOscillator()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        engine.output = oscillator
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            sender.setTitle("Play Sine Wave", for: UIControl.State())
        } else {
            oscillator.amplitude = random(in: 0.5 ... 1)
            oscillator.frequency = random(in: 220 ... 880)
            oscillator.start()
            sender.setTitle("Stop Sine Wave at \(Int(oscillator.frequency))Hz", for: .normal)
        }
        sender.setNeedsDisplay()
    }

}
