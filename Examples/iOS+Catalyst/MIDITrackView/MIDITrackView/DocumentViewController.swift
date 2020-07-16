//
//  DocumentViewController.swift
//  MIDIView
//
//  Created by Evan Murray on 7/15/20.
//

import UIKit
import AudioKit
import AudioKitUI
let conductor = Conductor()
class DocumentViewController: UIViewController {
    var document: UIDocument?
    var midiTrack: AKMIDITrackView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Access the document
        var windowWidth: CGFloat = 0
        var windowHeight: CGFloat = 0
        if let appScene = scene {
            guard let windowScene = (appScene as? UIWindowScene) else { return }
            #if targetEnvironment(macCatalyst)
                if let windowSize = windowScene.sizeRestrictions {
                    windowSize.maximumSize = CGSize(width: 1270, height: 250)
                    windowSize.minimumSize = CGSize(width: 1270, height: 250)
                    windowWidth = windowSize.maximumSize.width
                    windowHeight = windowSize.maximumSize.height + 27
                }
                if let titlebar = windowScene.titlebar {
                    titlebar.titleVisibility = .hidden
                    titlebar.toolbar = nil
                }
            #endif
        }
        document?.open(completionHandler: { (success) in
            if success {
                conductor.loadSequencerWithFile(url: self.document!.fileURL)
                // Display the content of the document, e.g.:
                if windowHeight != 0.0 && windowWidth != 0 {
                    self.midiTrack = AKMIDITrackView(frame: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight), midiFile: self.document?.fileURL, trackNumber: 0, sampler: conductor.sampler, sequencer: conductor.sequencer)
                    self.view.addSubview(self.midiTrack)
                    self.midiTrack.play()
                } else {
                    self.midiTrack = AKMIDITrackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), midiFile: self.document?.fileURL, trackNumber: 0, sampler: conductor.sampler, sequencer: conductor.sequencer)
                    self.view.addSubview(self.midiTrack)
                    self.midiTrack.play()
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
}
