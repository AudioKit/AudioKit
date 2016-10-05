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
    var sporthDictionary = [String: URL]()
    
    @IBAction func run(_ sender: UIButton) {
        slider1.value = 0.0
        slider2.value = 0.0
        slider3.value = 0.0
        slider4.value = 0.0
        brain.run(codeEditorTextView.text)
    }
    
    @IBAction func stop(_ sender: UIButton) {
        brain.stop()
    }
    
    func updateUI() {
        listOfSavedCodes.reloadAllComponents()
    }
    
    func setupUI() {
        
        do {
            try brain.save(Constants.File.chat, code: String(contentsOfFile: Constants.Path.chat, encoding: String.Encoding.utf8))
            try brain.save(Constants.File.drone, code: String(contentsOfFile: Constants.Path.drone, encoding: String.Encoding.utf8))
            try brain.save(Constants.File.rhythmic, code: String(contentsOfFile: Constants.Path.rhythmic, encoding: String.Encoding.utf8))
            
            listOfSavedCodes.selectRow(0, inComponent: 1, animated: true)
            codeEditorTextView.text = brain.knownCodes[brain.names.first!]
            nameTextField.text = brain.names.first!
            
        } catch {
            NSLog(Constants.Error.Loading)
        }
    }
    
    func getSporthFiles() {
        
        sporthDictionary["bones"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/bones/bones.sp")
        sporthDictionary["crystalline"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/crystalline/crystalline.sp")
        sporthDictionary["distant_intelligence"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/distant_intelligence/distant_intelligence.sp")
        sporthDictionary["hello"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/hello/hello.sp")
        sporthDictionary["kLtz"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/kLtz/kLtz.sp")
        sporthDictionary["scheale"] = URL(string: "https://raw.githubusercontent.com/PaulBatchelor/the_sporth_cookbook/master/scheale/scheale.sp")
        
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
        guard let name = nameTextField.text , !name.isEmpty else {
            presentAlert(Error.name)
            return
        }
        guard let code = codeEditorTextView.text , !code.isEmpty else {
            presentAlert(Error.code)
            return
        }
        brain.save(name, code: code)
        updateUI()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // The number of components (or “columns”) that the picker view should display.
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brain.names.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return brain.names[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        codeEditorTextView.text = brain.knownCodes[brain.names[row]]
        nameTextField.text = brain.names[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSporthFiles()
        setupUI()
        listOfSavedCodes.dataSource = self
        listOfSavedCodes.delegate = self
        nameTextField.delegate = self
    }
    
    @IBAction func trigger1(_ sender: UIButton) {
        print("triggering 1")
        brain.generator?.trigger(0)
    }
    
    @IBAction func trigger2(_ sender: UIButton) {
        print("triggering 2")
        brain.generator?.trigger(1)
    }
    
    @IBAction func trigger3(_ sender: UIButton) {
        print("triggering 3")
        brain.generator?.trigger(2)
    }
    
    @IBAction func trigger4(_ sender: UIButton) {
        print("triggering 4")
        brain.generator?.trigger(3)
    }
    
    @IBAction func activateGate1(_ sender: UIButton) {
        brain.generator?.parameters[0] = 1.0
        slider1.value = 1
    }
    
    @IBAction func deactivateGate1(_ sender: UIButton) {
        brain.generator?.parameters[0] = 0.0
        slider1.value = 0
    }
    
    @IBAction func activateGate2(_ sender: UIButton) {
        brain.generator?.parameters[1] = 1.0
        slider2.value = 1
    }
    
    @IBAction func deactivateGate2(_ sender: UIButton) {
        brain.generator?.parameters[1] = 0.0
        slider2.value = 0
    }
    
    @IBAction func activateGate3(_ sender: UIButton) {
        brain.generator?.parameters[2] = 1.0
        slider3.value = 1
    }
    
    @IBAction func deactivateGate3(_ sender: UIButton) {
        brain.generator?.parameters[2] = 0.0
        slider3.value = 0
    }
    
    @IBAction func activateGate4(_ sender: UIButton) {
        brain.generator?.parameters[3] = 1.0
        slider4.value = 1
    }
    
    @IBAction func deactivateGate4(_ sender: UIButton) {
        brain.generator?.parameters[3] = 0.0
        slider4.value = 0
    }
    
    @IBAction func updateParameter1(_ sender: UISlider) {
        print("value 1 = \(sender.value)")
        brain.generator?.parameters[0] = Double(sender.value)
    }
    @IBAction func updateParameter2(_ sender: UISlider) {
        print("value 2 = \(sender.value)")
        brain.generator?.parameters[1] = Double(sender.value)
    }
    @IBAction func updateParameter3(_ sender: UISlider) {
        print("value 3 = \(sender.value)")
        brain.generator?.parameters[2] = Double(sender.value)
    }
    @IBAction func updateParameter4(_ sender: UISlider) {
        print("value 4 = \(sender.value)")
        brain.generator?.parameters[3] = Double(sender.value)
    }

}
