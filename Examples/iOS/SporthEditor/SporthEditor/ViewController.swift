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
    
    var brain = SporthEditorBrain()
    
    @IBAction func run(sender: UIButton) {
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
}
