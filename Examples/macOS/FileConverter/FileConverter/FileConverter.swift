//
//  FileConverter
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AudioKit
import Cocoa

/// Simple interface to show AKConverter
class FileConverter: NSViewController {
    @IBOutlet var inputPathControl: NSPathControl!
    @IBOutlet var formatPopUp: NSPopUpButton!
    @IBOutlet var sampleRatePopUp: NSPopUpButton!
    @IBOutlet var bitDepthPopUp: NSPopUpButton!
    @IBOutlet var bitRatePopUp: NSPopUpButton!
    @IBOutlet var channelsPopUp: NSPopUpButton!
    let openPanel = NSOpenPanel()
    let savePanel = NSSavePanel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.delegate = self

        openPanel.message = "Choose File to Convert..."
        openPanel.allowedFileTypes = AKConverter.inputFormats

        for outType in AKConverter.outputFormats {
            formatPopUp.addItem(withTitle: outType)
        }

        savePanel.message = "Save As..."
        savePanel.allowedFileTypes = AKConverter.outputFormats
        savePanel.isExtensionHidden = false

        sampleRatePopUp.selectItem(withTitle: "44100")
    }

    @IBAction func openDocument(_ sender: Any) {
        chooseAudio(sender)
    }

    @IBAction func chooseAudio(_ sender: Any) {
        guard let window = view.window else { return }

        openPanel.beginSheetModal(for: window, completionHandler: { response in
            if response == NSApplication.ModalResponse.OK {
                if let url = self.openPanel.url {
                    self.inputPathControl.url = url
                }
            }
        })
    }

    @IBAction func handleFormatSelection(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title else { return }
        let isCompressed = title == "m4a"
        bitDepthPopUp.isHidden = isCompressed
        bitRatePopUp.isHidden = !isCompressed
    }

    @IBAction func convertAudio(_ sender: NSButton) {
        guard let window = view.window else { return }

        var options = AKConverter.Options()

        guard let format = formatPopUp.selectedItem?.title else { return }
        options.format = format

        if let sampleRate = sampleRatePopUp.selectedItem?.title {
            options.sampleRate = Double(sampleRate)
        }
        if let bitDepth = bitDepthPopUp.selectedItem?.title {
            options.bitDepth = UInt32(bitDepth)
        }
        if let bitRate = bitRatePopUp.selectedItem?.title {
            let br = UInt32(bitRate) ?? 256
            options.bitRate = br * 1_000
        }
        if let channels = channelsPopUp.selectedItem?.title {
            options.channels = UInt32(channels)
        }
        guard let inputURL = inputPathControl.url else { return }

        let basepath = inputURL.deletingPathExtension().deletingLastPathComponent()
        let basename = inputURL.deletingPathExtension().lastPathComponent

        savePanel.directoryURL = basepath
        savePanel.nameFieldStringValue = basename + "_converted." + format

        savePanel.beginSheetModal(for: window, completionHandler: { response in
            if response == NSApplication.ModalResponse.OK {
                if let url = self.savePanel.url {
                    self.convert(inputURL: inputURL, outputURL: url, options: options)
                }
            }
        })
    }

    /// Do the conversion
    private func convert(inputURL: URL, outputURL: URL, options: AKConverter.Options) {
        let converter = AKConverter(inputURL: inputURL, outputURL: outputURL, options: options)
        converter.start(completionHandler: { error in
            if let error = error {
                AKLog("Error during convertion: \(error)")
            } else {
                AKLog("Conversion Complete!")
            }
        })
    }
}

/// Handle Window Events
extension FileConverter: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // AudioKit.stop()
        exit(0)
    }
}
