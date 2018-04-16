//
//  MIDINoteDataVC.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/13.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit
import AudioKit

class MIDINoteDataVC: UIViewController {
    @IBOutlet weak var noteDataTableView: UITableView!
    var noteData: [AKMIDINoteData]!

    override func viewDidLoad() {
        super.viewDidLoad()
        noteDataTableView.register(UINib(nibName: Constants.Identifiers.midiNoteDataCell.rawValue,
                                         bundle: nil), forCellReuseIdentifier: Constants.Identifiers.midiNoteDataCell.rawValue)
        noteDataTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
}

extension MIDINoteDataVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.midiNoteDataCell.rawValue,
                                                       for: indexPath) as?  MIDINoteDataCellTableViewCell else {
                                                        return UITableViewCell()
        }

        cell.noteNum.text = "\(noteData[indexPath.row].noteNumber)"
        cell.velocity.text = "\(noteData[indexPath.row].velocity)"
        cell.channel.text = "\(noteData[indexPath.row].channel)"
        cell.position.text = String(format: "%.3f",
                                    noteData[indexPath.row].position.beats)
        cell.duration.text = String(format: "%.3f",
                                    noteData[indexPath.row].duration.beats)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "MIDI Note Data"
    }
}
