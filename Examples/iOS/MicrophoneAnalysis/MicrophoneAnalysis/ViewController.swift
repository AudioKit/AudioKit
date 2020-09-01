// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var frequencyLabel: UILabel!
    @IBOutlet private var amplitudeLabel: UILabel!
    @IBOutlet private var noteNameWithSharpsLabel: UILabel!
    @IBOutlet private var noteNameWithFlatsLabel: UILabel!
    @IBOutlet private var audioInputPlot: AKNodeOutputPlot!

    let engine = AKEngine()
    lazy var mic = AKMicrophone(engine: engine.avEngine)
    let mixer = AKMixer()
    var tracker: AKPitchTap!
    var silence: AKBooster!

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)

        // Pin the AKNodeOutputPlot to the audioInputPlot
        var constraints = [plot.leadingAnchor.constraint(equalTo: audioInputPlot.leadingAnchor)]
        constraints.append(plot.trailingAnchor.constraint(equalTo: audioInputPlot.trailingAnchor))
        constraints.append(plot.topAnchor.constraint(equalTo: audioInputPlot.topAnchor))
        constraints.append(plot.bottomAnchor.constraint(equalTo: audioInputPlot.bottomAnchor))
        constraints.forEach { $0.isActive = true }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kludge to align sample rates of the graph with the current input sample rate
        AKSettings.sampleRate = engine.avEngine.inputNode.inputFormat(forBus: 0).sampleRate

        AKSettings.audioInputEnabled = true
        mic! >>> mixer
        tracker = AKPitchTap(mixer) { pitch, amp in
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
        silence = AKBooster(mixer, gain: 0)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        engine.output = silence
        do {
            try engine.start()
            tracker.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
    }

    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
            let trackerFrequency = Float(tracker.leftPitch)

            guard trackerFrequency < 7_000 else {
                // This is a bit of hack because of modern Macbooks giving super high frequencies
                return
            }

            frequencyLabel.text = String(format: "%0.1f", tracker.leftPitch)

            var frequency = trackerFrequency
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            for i in 0 ..< noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(trackerFrequency / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }

    // MARK: - Actions

    @IBAction func didTapInputDevicesButton(_ sender: UIBarButtonItem) {
        let inputDevices = InputDeviceTableViewController()
        inputDevices.settingsDelegate = self
        let navigationController = UINavigationController(rootViewController: inputDevices)
        navigationController.preferredContentSize = CGSize(width: 300, height: 300)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
    }
}

// MARK: - InputDeviceDelegate

extension ViewController: InputDeviceDelegate {
    func didSelectInputDevice(_ device: AKDevice) {
        do {
            try mic!.setDevice(device)
        } catch {
            AKLog("Error setting input device")
        }
    }
}
