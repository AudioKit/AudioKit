//
//  ViewController.swift
//  SporthEditor
//
//  Created by Aurelius Prochazka on 7/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet var codeEditorTextView: UITextView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var listOfSavedCodes: UIPickerView!
    
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    @IBOutlet var slider4: UISlider!
    
    var brain = SporthEditorBrain()
    
    @IBAction func run(sender: UIButton) {
        slider1.value = 0.0
        slider2.value = 0.0
        slider3.value = 0.0
        slider4.value = 0.0
        brain.run(codeEditorTextView.text)
    }
    
    @IBAction func stop(sender: UIButton) {
        brain.stop()
    }
    
    func updateUI() {
        listOfSavedCodes.reloadAllComponents()
    }
    
    func setupUI() {
        do {
            try brain.save(Constants.File.chat, code: String(contentsOfFile: Constants.Path.chat, encoding: NSUTF8StringEncoding))
            try brain.save(Constants.File.drone, code: String(contentsOfFile: Constants.Path.drone, encoding: NSUTF8StringEncoding))
            try brain.save(Constants.File.rhythmic, code: String(contentsOfFile: Constants.Path.rhythmic, encoding: NSUTF8StringEncoding))
            listOfSavedCodes.selectRow(0, inComponent: 1, animated: true)
            codeEditorTextView.text = brain.knownCodes[brain.names.first!]
            nameTextField.text = brain.names.first!
            
        } catch {
            NSLog(Constants.Error.Loading)
        }
    }
    
    func presentAlert(error: Error) {
        let alert = UIAlertController()
        switch error {
        case .Code:
            alert.title = Constants.Code.title
            alert.message = Constants.Code.message
        case .Name:
            alert.title = Constants.Name.title
            alert.message = Constants.Name.message
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func save(sender: UIButton) {
        guard let name = nameTextField.text where !name.isEmpty else {
            presentAlert(Error.Name)
            return
        }
        guard let code = codeEditorTextView.text where !code.isEmpty else {
            presentAlert(Error.Code)
            return
        }
        brain.save(name, code: code)
        updateUI()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        // The number of components (or “columns”) that the picker view should display.
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brain.names.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return brain.names[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        codeEditorTextView.text = brain.knownCodes[brain.names[row]]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        listOfSavedCodes.dataSource = self
        listOfSavedCodes.delegate = self
        nameTextField.delegate = self
    }
    
    @IBAction func trigger1(sender: UIButton) {
        print("triggering 1")
        brain.generator?.trigger(0)
    }
    
    @IBAction func trigger2(sender: UIButton) {
        print("triggering 2")
        brain.generator?.trigger(1)
    }
    
    @IBAction func trigger3(sender: UIButton) {
        print("triggering 3")
        brain.generator?.trigger(2)
    }
    
    @IBAction func trigger4(sender: UIButton) {
        print("triggering 4")
        brain.generator?.trigger(3)
    }
    
    @IBAction func activateGate1(sender: UIButton) {
        brain.generator?.parameters[0] = 1.0
        slider1.value = 1
    }
    
    @IBAction func deactivateGate1(sender: UIButton) {
        brain.generator?.parameters[0] = 0.0
        slider1.value = 0
    }
    
    @IBAction func activateGate2(sender: UIButton) {
        brain.generator?.parameters[1] = 1.0
        slider2.value = 1
    }
    
    @IBAction func deactivateGate2(sender: UIButton) {
        brain.generator?.parameters[1] = 0.0
        slider2.value = 0
    }
    
    @IBAction func activateGate3(sender: UIButton) {
        brain.generator?.parameters[2] = 1.0
        slider3.value = 1
    }
    
    @IBAction func deactivateGate3(sender: UIButton) {
        brain.generator?.parameters[2] = 0.0
        slider3.value = 0
    }
    
    @IBAction func activateGate4(sender: UIButton) {
        brain.generator?.parameters[3] = 1.0
        slider4.value = 1
    }
    
    @IBAction func deactivateGate4(sender: UIButton) {
        brain.generator?.parameters[3] = 0.0
        slider4.value = 0
    }
    
    
    @IBAction func updateParameter1(sender: UISlider) {
        print("value 1 = \(sender.value)")
        brain.generator?.parameters[0] = Double(sender.value)
    }
    @IBAction func updateParameter2(sender: UISlider) {
        print("value 2 = \(sender.value)")
        brain.generator?.parameters[1] = Double(sender.value)
    }
    @IBAction func updateParameter3(sender: UISlider) {
        print("value 3 = \(sender.value)")
        brain.generator?.parameters[2] = Double(sender.value)
    }
    @IBAction func updateParameter4(sender: UISlider) {
        print("value 4 = \(sender.value)")
        brain.generator?.parameters[3] = Double(sender.value)
    }

}
