//
//  ViewController.swift
//  SporthEditor
//
//  Created by Aurelius Prochazka on 7/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, UITextFieldDelegate, AKKeyboardDelegate {
    @IBOutlet private var codeEditorTextView: UITextView!
    @IBOutlet private weak var keyboard: AKKeyboardView!
    @IBOutlet private weak var status: UILabel!
    @IBOutlet private weak var runButton: RoundedButton!

    @IBOutlet private var slider1: AKPropertySlider!
    @IBOutlet private var slider2: AKPropertySlider!
    @IBOutlet private var slider3: AKPropertySlider!
    @IBOutlet private var slider4: AKPropertySlider!

    var brain = SporthEditorBrain()
    var sporthDictionary = [String: URL]()
    var currentMIDINote: MIDINoteNumber = 0
    var sliders: [AKPropertySlider] = []

    @IBAction func run() {
        if let started = brain.generator?.isStarted {
            if started {
                brain.stop()
                runButton.setTitle("Run", for: .normal)
            } else {
                brain.run(codeEditorTextView.text)
                updateContextAwareCotrols()
                runButton.setTitle("Stop", for: .normal)
            }
        } else {
            brain.run(codeEditorTextView.text)
            updateContextAwareCotrols()
            runButton.setTitle("Stop", for: .normal)
        }
    }

    @IBAction func decreasePatch(_ sender: Any) {
        if brain.currentIndex > 0 {
            brain.currentIndex -= 1
        }
        didChangePatch()
    }
    @IBAction func increasePatch(_ sender: Any) {
        if brain.currentIndex < brain.names.count - 1 {
            brain.currentIndex += 1
        }
        didChangePatch()
    }

    func setupUI() {

        do {
            try brain.save(Constants.File.simpleKeyboard,
                           code: String(contentsOfFile: Constants.Path.simpleKeyboard, encoding: String.Encoding.utf8))

            codeEditorTextView.text = brain.knownCodes[brain.names.first!]
            status.text = brain.names.first!

            codeEditorTextView.autocorrectionType = .no
            codeEditorTextView.autocapitalizationType = .none
            keyboard.delegate = self
        } catch {
            NSLog(Constants.Error.Loading)
        }

        updateContextAwareCotrols()
    }

    func getSporthFiles() {
        let baseURL = "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/"
        let keysURL = URL(string: "\(baseURL)ready.txt")
        var urlContents = ""
        do {
            urlContents = try String(contentsOf: keysURL!)
        } catch {
            print ("error")
        }

        for key in urlContents.components(separatedBy: NSCharacterSet.newlines) {
            sporthDictionary[key] = URL(string: "\(baseURL)\(key)/\(key).sp")
        }

        for item in sporthDictionary {
            do {
                let urlContents = try String(contentsOf: item.value)
                brain.knownCodes[item.key] = urlContents
            } catch {
                print ("error")
            }
        }
    }

    func presentAlert(_ error: Error) {
        let alert = UIAlertController()
        switch error {
        case .code:
            alert.title = Constants.Code.title
            alert.message = Constants.Code.message
        case .name:
            alert.title = Constants.Name.title
            alert.message = Constants.Name.message
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIButton) {
        guard let name = status.text, !name.isEmpty else {
            presentAlert(Error.name)
            return
        }
        guard let code = codeEditorTextView.text, !code.isEmpty else {
            presentAlert(Error.code)
            return
        }
        brain.save(name, code: code)
    }

    @IBOutlet private weak var slidersStackView: UIStackView!
    func updateContextAwareCotrols() {
        let sporth = brain.knownCodes[brain.names[brain.currentIndex]]!
        slidersStackView.isHidden = true
        sliders.forEach { $0.isHidden = true }
        keyboard.isHidden = true
        var currentControl = 0
        search: for line in sporth.components(separatedBy: NSCharacterSet.newlines) {
            if sporth.contains("5 p") {
                keyboard.isHidden = false
            }

            var regex = NSRegularExpression()
            var pattern = "# default ([.0-9]+)"
            do {
                regex = try NSRegularExpression(pattern: pattern,
                                                options: .dotMatchesLineSeparators)
            } catch {
                print("Regular expression failed")
            }

            let value = regex.stringByReplacingMatches(in: line,
                                                       options: .reportCompletion,
                                                       range: NSRange(location: 0,
                                                                      length: line.characters.count),
                                                       withTemplate: "$1")

            pattern = "##: - Control ([1-4]): ([^\n]+)"
            do {
                regex = try NSRegularExpression(pattern: pattern,
                                                options: .dotMatchesLineSeparators)
            } catch {
                print("Regular expression failed")
            }
            let currentControlText = regex.stringByReplacingMatches(in: line,
                                                            options: .reportCompletion,
                                                            range: NSRange(location: 0,
                                                                           length: line.characters.count),
                                                            withTemplate: "$1")

            title = regex.stringByReplacingMatches(in: line,
                                                   options: .reportCompletion,
                                                   range: NSRange(location: 0,
                                                                  length: line.characters.count),
                                                   withTemplate: "$2")

            if title != line {
                currentControl = Int(currentControlText)! - 1
                slidersStackView.isHidden = false
                sliders[currentControl].isHidden = false
                sliders[currentControl].property = title!
            }
            if value != line {
                brain.generator?.parameters[currentControl] = Double(value)!
                sliders[currentControl].value = Double(value)!
            }
        }
    }

    func didChangePatch() {
        brain.stop()
        runButton.setTitle("Run", for: .normal)

        let sporth = brain.knownCodes[brain.names[brain.currentIndex]]
        codeEditorTextView.text = sporth

        status.text = brain.names[brain.currentIndex]
        updateContextAwareCotrols()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getSporthFiles()
        sliders = [slider1, slider2, slider3, slider4]
        setupUI()
        for i in 0..<4 {
            sliders[i].callback = { value in self.brain.generator?.parameters[i] = Double(value) }
        }
        }

    // MARK: - Keyboard Delegate

    func noteOn(note: MIDINoteNumber) {
        status.text = "Note Pressed: \(note)"
        currentMIDINote = note
        brain.generator?.parameters[4] = 1
        brain.generator?.parameters[5] = Double(note)

    }

    func noteOff(note: MIDINoteNumber) {
        if currentMIDINote == note {
            status.text = brain.names[brain.currentIndex]
            brain.generator?.parameters[4] = 0
        }
    }

}
