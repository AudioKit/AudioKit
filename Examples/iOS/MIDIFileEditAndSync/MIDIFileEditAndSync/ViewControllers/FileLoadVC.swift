//
//  FileLoadVCViewController.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/12.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class FileLoadVC: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var fileLoadTableView: UITableView!
    weak var delegate: FileLoaderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        fileLoadTableView.delegate = self
        fileLoadTableView.dataSource = self
    }

    @IBAction func loadFileFromiCloud(_ sender: Any) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.midi-audio"], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        delegate?.loadFile(url: urls[0])
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView
extension FileLoadVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.localMIDIFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.fileLoadCell.rawValue, for: indexPath)
        cell.textLabel?.text = Constants.localMIDIFiles[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.loadFile(filename: Constants.localMIDIFiles[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}
