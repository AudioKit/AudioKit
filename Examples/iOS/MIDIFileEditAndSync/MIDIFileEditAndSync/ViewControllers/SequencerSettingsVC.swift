//
//  SequencerSettingsVC.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/13.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit
import AudioKit

class SequencerSettingsVC: UIViewController {
    @IBOutlet weak var loopEnabledSwitch: UISwitch!
    @IBOutlet weak var sequenceLengthTextField: UITextField!
    @IBOutlet weak var tempoTextField: UITextField!
    @IBOutlet weak var timeSigTextField: UITextField!
    @IBOutlet var parentView: UIView!

    weak var sequencerDelegate: SequencerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setup()
    }

    fileprivate func setup() {
        setUpTextFields()
        loopEnabledSwitch.isOn = sequencerDelegate?.loopEnabled ?? true
    }

    @IBAction func switchMoved(_ sender: Any) {
        if loopEnabledSwitch.isOn {
            sequencerDelegate?.enableLooping()
        } else {
            sequencerDelegate?.disableLooping()
        }
    }
}

extension SequencerSettingsVC: UITextFieldDelegate {

    fileprivate func setUpTextFields() {
        tempoTextField.delegate = self
        tempoTextField.text = "\(Int(sequencerDelegate?.tempo ?? 0))"
        sequenceLengthTextField.delegate = self
        sequenceLengthTextField.text = "\(Int(sequencerDelegate?.length.beats ?? 0))"
        timeSigTextField.delegate = self
        timeSigTextField.text = "4"
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let value = Int(textField.text ?? "0") else { return false }
        switch textField {
        case sequenceLengthTextField:
            if value >= 1 {
                sequencerDelegate?.setLength(AKDuration(beats: Double(value)))
                moveTextField(textField, moveDistance: -200, up: false)
                return true
            }
        case tempoTextField:
            if 40 ... 240 ~= value {
                sequencerDelegate?.setTempo(Double(value))
                moveTextField(textField, moveDistance: -200, up: false)
                return true
            }
        case timeSigTextField:
            if 1 ..< 60 ~= value {
                let timeSig = AKTimeSignature(topValue: UInt8(value),
                                              bottomValue: AKTimeSignature.TimeSignatureBottomValue.four)
                sequencerDelegate?.addTimeSignatureEvent(at: 0.0,
                                                         timeSignature: timeSig,
                                                         ticksPerMetronomeClick: 24,
                                                         thirtySecondNotesPerQuarter: 8,
                                                         clearExistingEvents: true)
                moveTextField(textField, moveDistance: -200, up: false)
                return true
            }
        default:
            return true
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -200, up: true)
    }

    fileprivate func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    // resign textField responder when screen touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for txt in self.view.subviews {
            if txt.isKind(of: UITextField.self) && txt.isFirstResponder {
                txt.resignFirstResponder()
            }
        }
    }
}

protocol SequencerDelegate: class {
    var loopEnabled: Bool { get }
    var tempo: Double { get }
    var length: AKDuration { get }

    func addTimeSignatureEvent(at timeStamp: MusicTimeStamp,
                               timeSignature: AKTimeSignature,
                               ticksPerMetronomeClick: UInt8,
                               thirtySecondNotesPerQuarter: UInt8,
                               clearExistingEvents: Bool)
    func setTempo(_ bpm: Double)
    func enableLooping()
    func disableLooping()
    func setLength(_ length: AKDuration)
}
