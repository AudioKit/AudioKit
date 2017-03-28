//
//  ViewController.swift
//  AudioKitParticles
//
//  Created by Simon Gladman on 28/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {

    let statusLabel = UILabel()
    let floatPi = Float.pi
    var gravityWellAngle: Float = 0

    var particleLab: ParticleLab!
    var fft: AKFFTTap!
    var amplitudeTracker: AKAmplitudeTracker!

    var amplitude: Float = 0

    var lowMaxIndex: Float = 0
    var hiMaxIndex: Float = 0
    var hiMinIndex: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let mic = AKMicrophone()

        fft = AKFFTTap(mic)

        amplitudeTracker = AKAmplitudeTracker(mic)

        // Turn the volume all the way down on the output of amplitude tracker
        let noAudioOutput = AKMixer(amplitudeTracker)
        noAudioOutput.volume = 0

        AudioKit.output = noAudioOutput
        AudioKit.start()

        let _ = Loop(every: 1 / 60) {
            let fftData = self.fft.fftData
            let count = 250

            let lowMax = fftData[0 ... (count / 2) - 1].max() ?? 0
            let hiMax = fftData[count / 2 ... count - 1].max() ?? 0
            let hiMin = fftData[count / 2 ... count - 1].min() ?? 0

            let lowMaxIndex = fftData.index(of: lowMax) ?? 0
            let hiMaxIndex = fftData.index(of: hiMax) ?? 0
            let hiMinIndex = fftData.index(of: hiMin) ?? 0

            self.amplitude = Float(self.amplitudeTracker.amplitude * 25)

            self.lowMaxIndex = Float(lowMaxIndex)
            self.hiMaxIndex = Float(hiMaxIndex - count / 2)
            self.hiMinIndex = Float(hiMinIndex - count / 2)
        }

        // ----

        view.backgroundColor = UIColor.white

        let numParticles = ParticleCount.twoMillion

        if view.frame.height < view.frame.width {
            particleLab = ParticleLab(width: UInt(view.frame.width),
                height: UInt(view.frame.height),
                numParticles: numParticles)

            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.width,
                height: view.frame.height)
        } else {
            particleLab = ParticleLab(width: UInt(view.frame.height),
                height: UInt(view.frame.width),
                numParticles: numParticles)

            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.height,
                height: view.frame.width)
        }

        particleLab.particleLabDelegate = self
        particleLab.dragFactor = 0.9
        particleLab.clearOnStep = false
        particleLab.respawnOutOfBoundsParticles = true

        view.addSubview(particleLab)

        statusLabel.textColor = UIColor.darkGray
        statusLabel.text = "AudioKit Particles"

        view.addSubview(statusLabel)
    }

    func particleLabStep() {
        gravityWellAngle += 0.01

        let radiusLow = 0.1 + (lowMaxIndex / 256)

        particleLab.setGravityWellProperties(
            gravityWell: .one,
            normalisedPositionX: 0.5 + radiusLow * sin(gravityWellAngle),
            normalisedPositionY: 0.5 + radiusLow * cos(gravityWellAngle),
            mass: (lowMaxIndex * amplitude),
            spin: -(lowMaxIndex * amplitude))

        particleLab.setGravityWellProperties(
            gravityWell: .four,
            normalisedPositionX: 0.5 + radiusLow * sin((gravityWellAngle + floatPi)),
            normalisedPositionY: 0.5 + radiusLow * cos((gravityWellAngle + floatPi)),
            mass: (lowMaxIndex * amplitude),
            spin: -(lowMaxIndex * amplitude))

        let radiusHi = 0.1 + (0.25 + (hiMaxIndex / 1_024))

        particleLab.setGravityWellProperties(
            gravityWell: .two,
            normalisedPositionX: particleLab.getGravityWellNormalisedPosition(gravityWell: .one).x +
                (radiusHi * sin(gravityWellAngle * 3)),
            normalisedPositionY: particleLab.getGravityWellNormalisedPosition(gravityWell: .one).y +
                (radiusHi * cos(gravityWellAngle * 3)),
            mass: (hiMaxIndex * amplitude),
            spin: (hiMinIndex * amplitude))

        particleLab.setGravityWellProperties(
            gravityWell: .three,
            normalisedPositionX: particleLab.getGravityWellNormalisedPosition(gravityWell: .four).x +
                (radiusHi * sin((gravityWellAngle + floatPi) * 3)),
            normalisedPositionY: particleLab.getGravityWellNormalisedPosition(gravityWell: .four).y +
                (radiusHi * cos((gravityWellAngle + floatPi) * 3)),
            mass: (hiMaxIndex * amplitude),
            spin: (hiMinIndex * amplitude))
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        statusLabel.frame = CGRect(x: 5,
            y: view.frame.height - statusLabel.intrinsicContentSize.height,
            width: view.frame.width,
            height: statusLabel.intrinsicContentSize.height)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension ViewController: ParticleLabDelegate {
    func particleLabMetalUnavailable() {
        // handle metal unavailable here
    }

    func particleLabDidUpdate(_ status: String) {
        statusLabel.text = status

        particleLab.resetGravityWells()

        particleLabStep()
    }
}
