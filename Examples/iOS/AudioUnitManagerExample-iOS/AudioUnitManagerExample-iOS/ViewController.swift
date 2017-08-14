//
//  ViewController.swift
//  AudioUnitManagerExample_iOS
//
//  Created by Ryan Francesconi on 8/13/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import UIKit
import AudioKit
import DropDown

class ViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var auContainer: UIScrollView!

    var currentAU: AudioUnitGenericView?
    
    var effectMenus = [DropDown?](repeating: nil, count: 3)
    var effectButtons = [UIButton?](repeating: nil, count: 3)
    
    var auManager: AKAudioUnitManager?
    var mixer = AKMixer()
    var player: AKAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auManager = AKAudioUnitManager()
        auManager?.delegate = self
        
        auManager?.requestEffects(completionHandler: { audioUnits in
            self.updateEffectsUI(audioUnits: audioUnits)
        })
        
        initDropDowns()
        
        if let audioFile = try? AKAudioFile(readFileName: "Organ.wav",
                                            baseDir: .resources) {
            player = try? AKAudioPlayer(file: audioFile)
            player?.looping = true
            
            mixer.connect(player)
            
            // setup the initial input/output connections
            auManager?.input = player
            auManager?.output = mixer
            
            AudioKit.output = mixer
            AudioKit.start()
        }
        
    }
    
    private func getEffectsButton(_ id: Int ) -> UIButton? {
        guard view != nil else { return nil }
        
        for sv in view.subviews {
            if  let b = sv as? UIButton {
                if b.tag == id {
                    return b
                }
            }
        }
        return nil
    }
    
    private func initDropDowns() {
        for i in 0 ..< 3 {
            
            if let button = getEffectsButton(i) {
                effectButtons[i] = button
            }
            
            effectMenus[i] = DropDown()
            effectMenus[i]?.anchorView = view
            effectMenus[i]?.direction = .any
            effectMenus[i]?.textFont = UIFont.systemFont(ofSize: 10)
            
            effectMenus[i]?.selectionAction = { [weak self] (index: Int, name: String) in
                print("handleSelectEffect() \(name)")
                
                guard let strongSelf = self else { return }
                
                guard strongSelf.auManager != nil else { return }
                
                if name == "-" {
                    strongSelf.auManager!.removeEffect(at: i)
                    if strongSelf.currentAU != nil {
                        strongSelf.currentAU?.removeFromSuperview()
                    }
                } else {
                    strongSelf.auManager!.insertAudioUnit(name: name, at: i)
                }
                
                strongSelf.effectButtons[i]?.setTitle(name, for: .normal)
            }
        }
    }
    
    /// tell the linked drop down to open
    @IBAction func handleChooseEffect(_ sender: UIButton) {
        guard sender.tag < 3 && sender.tag >= 0 else { return }
        effectMenus[sender.tag]?.show()
    }
    
    @IBAction func handlePlay(_ sender: UIButton) {
        guard let player = player else { return }
        
        if player.isStarted {
            player.stop()
            sender.setTitle("▶️", for: .normal)
           
        } else {
            player.play()
            sender.setTitle("⏹", for: .normal)
        }
    }

    /// this is called to fill the drop downs with a list of available audio units
    fileprivate func updateEffectsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard auManager != nil else { return }
 
        for i in 0 ..< 3 {
            var effectMenuData = ["-"]
            
            for component in audioUnits {
                if component.name != "" {
                    effectMenuData.append(component.name)
                }
            }
            
            effectMenus[i]?.dataSource = effectMenuData
        }
    }
    
    
    public func showAudioUnit(_ audioUnit: AVAudioUnit, identifier: Int ) {
        
        if currentAU != nil {
            currentAU?.removeFromSuperview()
        }
        
        currentAU = AudioUnitGenericView(au: audioUnit)
        auContainer.addSubview(currentAU!)
        auContainer.contentSize = currentAU!.frame.size
            
    }

    
    
}

extension ViewController: AKAudioUnitManagerDelegate {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
        Swift.print("handleAudioUnitNotification() type: \(type)")
        guard auManager != nil else { return }
        
        if type == AKAudioUnitManager.Notification.changed {
            updateEffectsUI( audioUnits: auManager!.availableEffects )
        }
    }
    
    /// this is where you can request the UI of the Audio Unit
    func handleEffectAdded(at auIndex: Int) {
        Swift.print("handleEffectAdded() at \(auIndex)")
        
        guard player != nil else { return }

        if player!.isStarted {
            player!.stop()
            player!.start()
        }

        if let au = auManager!.effectsChain[auIndex] {
            showAudioUnit(au, identifier: auIndex)
            
        }
        
        
    }
}


