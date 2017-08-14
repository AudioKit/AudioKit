//
//  EffectsViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class EffectsViewController: UIViewController {

    @IBOutlet private weak var volumeSlider: AKPropertySlider!

    var docController: UIDocumentInteractionController?

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        volumeSlider.maximum = 10.0

        if let volume = songProcessor.playerBooster?.gain {
            volumeSlider.value = volume
        }
        volumeSlider.callback = updateVolume
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(barButton:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateVolume(value: Double) {
        songProcessor.playerBooster?.gain = value
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
