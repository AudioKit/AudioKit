//
//  EffectsViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class EffectsViewController: UIViewController {

    @IBOutlet private var volumeSlider: AKSlider!

    var docController: UIDocumentInteractionController?

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        AKStylist.sharedInstance.theme = .basic

        volumeSlider.range = 0 ... 10.0

        volumeSlider.value = songProcessor.playerBooster.gain
        volumeSlider.callback = updateVolume
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(barButton:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateVolume(value: Double) {
        songProcessor.playerBooster.gain = value
    }

    @objc func share(barButton: UIBarButtonItem) {
        renderAndShare { docController in
            guard let canOpen = docController?.presentOpenInMenu(from: barButton, animated: true) else { return }
            if !canOpen {
                self.present(self.alertForShareFail(), animated: true, completion: nil)
            }
        }
    }

}
