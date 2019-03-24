//
//  InputDeviceTableViewController.swift
//  MicrophoneAnalysis
//
//  Created by Dean Woodward on 22/03/19.
//  Copyright © 2019 Dean Woodward. All rights reserved.
//

import UIKit
import AudioKit

protocol InputDeviceDelegate {
    func didSelectInputDevice(_ device: AKDevice)
}

class InputDeviceTableViewController: UITableViewController {

    var currentInputDevice: AKDevice?
    var inputDevices = AudioKit.inputDevices ?? []
    var settingsDelegate: InputDeviceDelegate?
    let reuseIdentifier = "inputCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Input Devices"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputDevices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let inputDevice = inputDevices[indexPath.row]
        cell.textLabel?.text = inputDevice.name
        cell.detailTextLabel?.text = inputDevice.deviceID
        cell.accessoryType = (inputDevice == currentInputDevice) ? .checkmark : .none
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        settingsDelegate?.didSelectInputDevice(inputDevices[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

}
