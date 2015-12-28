//
//  ViewController.swift
//  AudioKitParticles
//
//  Created by Simon Gladman on 28/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let statusLabel = UILabel()
    let floatPi = Float(M_PI)
    var particleLab: ParticleLab!
    var gravityWellAngle: Float = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let audiokit = AKManager.sharedInstance
        var oscillator = AKOscillator()
        
        audiokit.audioOutput = oscillator
        audiokit.start()
        
        // ----
        
        view.backgroundColor = UIColor.blackColor()
        
        let numParticles = ParticleCount.FourMillion
        
        if view.frame.height < view.frame.width
        {
            particleLab = ParticleLab(width: UInt(view.frame.width),
                height: UInt(view.frame.height),
                numParticles: numParticles)
            
            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.width,
                height: view.frame.height)
        }
        else
        {
            particleLab = ParticleLab(width: UInt(view.frame.height),
                height: UInt(view.frame.width),
                numParticles: numParticles)
            
            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.height,
                height: view.frame.width)
        }
        
        particleLab.particleLabDelegate = self
        particleLab.dragFactor = 0.5
        particleLab.clearOnStep = false
        particleLab.respawnOutOfBoundsParticles = false
        
        view.addSubview(particleLab)
    
        statusLabel.text = "http://flexmonkey.blogspot.co.uk"
        statusLabel.textColor = UIColor.darkGrayColor()
        
        view.addSubview(statusLabel)
    }
    
    func particleLabStep()
    {
        gravityWellAngle = gravityWellAngle + 0.02
        
        particleLab.setGravityWellProperties(gravityWell: .One,
            normalisedPositionX: 0.5 + 0.1 * sin(gravityWellAngle + floatPi * 0.5),
            normalisedPositionY: 0.5 + 0.1 * cos(gravityWellAngle + floatPi * 0.5),
            mass: 11 * sin(gravityWellAngle / 1.9),
            spin: 23 * cos(gravityWellAngle / 2.1))
        
        particleLab.setGravityWellProperties(gravityWell: .Four,
            normalisedPositionX: 0.5 + 0.1 * sin(gravityWellAngle + floatPi * 1.5),
            normalisedPositionY: 0.5 + 0.1 * cos(gravityWellAngle + floatPi * 1.5),
            mass: 11 * sin(gravityWellAngle / 1.9),
            spin: 23 * cos(gravityWellAngle / 2.1))
        
        particleLab.setGravityWellProperties(gravityWell: .Two,
            normalisedPositionX: 0.5 + (0.35 + sin(gravityWellAngle * 2.7)) * cos(gravityWellAngle / 1.3),
            normalisedPositionY: 0.5 + (0.35 + sin(gravityWellAngle * 2.7)) * sin(gravityWellAngle / 1.3),
            mass: 26, spin: -19 * sin(gravityWellAngle * 1.5))
        
        particleLab.setGravityWellProperties(gravityWell: .Three,
            normalisedPositionX: 0.5 + (0.35 + sin(gravityWellAngle * 2.7)) * cos(gravityWellAngle / 1.3 + floatPi),
            normalisedPositionY: 0.5 + (0.35 + sin(gravityWellAngle * 2.7)) * sin(gravityWellAngle / 1.3 + floatPi),
            mass: 26, spin: -19 * sin(gravityWellAngle * 1.5))
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews()
    {
        statusLabel.frame = CGRect(x: 5,
            y: view.frame.height - statusLabel.intrinsicContentSize().height,
            width: view.frame.width,
            height: statusLabel.intrinsicContentSize().height)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }

}

extension ViewController: ParticleLabDelegate
{
    func particleLabMetalUnavailable()
    {
        // handle metal unavailable here
    }
    
    func particleLabDidUpdate(status: String)
    {
        statusLabel.text = "http://flexmonkey.blogspot.co.uk  |  " + status
        
        particleLab.resetGravityWells()
        
        particleLabStep()
    }
}

