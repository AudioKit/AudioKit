//
//  ViewController.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit
import AudioKit

class MainViewController: UIViewController {

    var sequencerManager: SequencerManager?
    var midiFilter = MIDIFilter()

    enum FileMode {
        case newFile, addFile
    }

    var fileLoadMode: FileMode = .newFile
    var trackForInspection: Int?
    let documentInteractionController = UIDocumentInteractionController()
    var selectedTracks: Set<Int> {
        var selected = Set<Int>()
        for row in 0 ..< trackTableView.numberOfRows(inSection: 0) {
            if let cell = trackTableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                if cell.isSelected { selected.insert(row) }
            }
        }
        return selected
    }

    @IBOutlet weak var trackTableView: UITableView!

    // MARK: - Set up
    override func viewDidLoad() {
        super.viewDidLoad()
        sequencerManager = SequencerManager()
        setUpTableView()
        documentInteractionController.delegate = self
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        trackTableView.reloadData()
    }

    // MARK: - IBActions: Options
    @IBAction func play(_ sender: Any) {
        sequencerManager?.play()
    }

    @IBAction func stop(_ sender: Any) {
        sequencerManager?.stop()
    }

    @IBAction func pressNewSequence(_ sender: Any) {
        fileLoadMode = .newFile
        performSegue(withIdentifier: Constants.Identifiers.toFileLoadVC.rawValue, sender: self)
    }

    @IBAction func pressAddMIDIFile(_ sender: Any) {
        fileLoadMode = .addFile
        performSegue(withIdentifier: Constants.Identifiers.toFileLoadVC.rawValue, sender: self)
    }

    @IBAction func pressOpenFilterSettings(_ sender: Any) {
        performSegue(withIdentifier: Constants.Identifiers.toFilterSettings.rawValue, sender: self)
    }

    @IBAction func pressOpenSequencerSettings(_ sender: Any) {
        performSegue(withIdentifier: Constants.Identifiers.toSequencerSettingsVC .rawValue, sender: self)
    }

    @IBAction func pressExport(_ sender: Any) {
        guard let url = sequencerManager?.getURLwithMIDIFileData() else { return }
        share(url: url)
    }

    // MARK: - IBActions: MIDI Editing
    @IBAction func pressApplyFilter(_ sender: Any) {
        sequencerManager?.filterNotes(selectedTracks,
                                     filterFunction: midiFilter.filterFunction)
    }

    @IBAction func pressDouble(_ sender: Any) {
        sequencerManager?.doubleTrackLengths(selectedTracks)
    }

    @IBAction func pressHalve(_ sender: Any) {
        sequencerManager?.halveTrackLengths(selectedTracks)
    }

    @IBAction func pressShiftRight(_ sender: Any) {
        sequencerManager?.shiftRight(selectedTracks)
    }

    @IBAction func pressShiftLeft(_ sender: Any) {
        sequencerManager?.shiftLeft(selectedTracks)
    }

    @IBAction func pressDelete(_ sender: Any) {
        sequencerManager?.deleteSelectedTracks(selectedTracks)
        trackTableView.reloadData()
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = Constants.Identifiers(rawValue: segue.identifier ?? "") else { return }

        switch id {
        case .toFilterSettings:
            guard let vc = segue.destination as? MIDIFilterVC else { return }
            vc.filterTableDelegate = midiFilter
        case .toFileLoadVC:
            guard let vc = segue.destination as? FileLoadVC else { return }
            vc.delegate = self
        case .toSequencerSettingsVC:
             guard let vc = segue.destination as? SequencerSettingsVC,
             let manager = sequencerManager,
             let seq = manager.seq else { return }
            vc.sequencerDelegate = seq
        case .toMIDINoteDataVC:
            guard let vc = segue.destination as? MIDINoteDataVC,
                let manager = sequencerManager,
                let seq = manager.seq,
                let trackForInspection = trackForInspection,
                seq.tracks.count > trackForInspection else { return }
            vc.noteData = seq.tracks[trackForInspection].getMIDINoteData()
        default:
            return
        }
    }
}

// MARK: - TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    fileprivate func setUpTableView() {
        trackTableView.dataSource = self
        trackTableView.delegate = self
        trackTableView.allowsMultipleSelection = true
        trackTableView.register(UINib(nibName: Constants.Identifiers.trackCell.rawValue, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.trackCell.rawValue)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = sequencerManager,
            let seq = manager.seq else { return 0 }
        // last row is 'select all'
        return seq.tracks.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.trackCell.rawValue, for: indexPath) as? TrackCell,
            let manager = sequencerManager,
            let seq = manager.seq else { return UITableViewCell() }

        if indexPath.row < seq.trackCount {
            cell.index.text = "\(indexPath.row)"
            cell.noteEvents.text = "Note Events: \(seq.tracks[indexPath.row].getMIDINoteData().count)"
            cell.selectionStyle = .blue
            cell.trackNum = indexPath.row

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressCell(gesture:)))
            longPress.minimumPressDuration = 0.5
            cell.addGestureRecognizer(longPress)
        } else {
            cell.index.text = " - Select All - "
            cell.noteEvents.text = ""
            cell.selectionStyle = .none
        }
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let manager = sequencerManager,
            let seq = manager.seq,
            indexPath.row >= seq.tracks.count  else { return }

        for row in 0 ..< tableView.numberOfRows(inSection: 0) {
            tableView.selectRow(at: IndexPath(item: row, section: 0), animated: false, scrollPosition: .none)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Music Tracks"
    }

    @objc func longPressCell(gesture: UILongPressGestureRecognizer) {
        guard let cell = gesture.view as? TrackCell else { return }
        guard gesture.state == .began else { return }

        trackForInspection = cell.trackNum
        performSegue(withIdentifier: Constants.Identifiers.toMIDINoteDataVC.rawValue, sender: self)
    }
}

// MARK: - File Loading and Exporting
extension MainViewController: FileLoaderDelegate, UIDocumentInteractionControllerDelegate {
    func loadFile(filename: String) {
        guard let manager = sequencerManager,
            let seq = manager.seq else { return }
        seq.stop()
        if fileLoadMode == .newFile {
            seq.loadMIDIFile(filename)
        } else {
            seq.addMIDIFileTracks(filename)
        }

        updatesForSequencerChange()
    }

    func loadFile(url: URL) {
        guard let manager = sequencerManager,
        let seq = manager.seq else { return }
        seq.stop()
        if fileLoadMode == .newFile {
            seq.loadMIDIFile(fromURL: url)
        } else {
            seq.addMIDIFileTracks(url)
        }

        updatesForSequencerChange()
    }

    fileprivate func updatesForSequencerChange() {
        sequencerManager?.sequencerTracksChanged()
        trackTableView.reloadData()
    }

    fileprivate func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.presentOptionsMenu(from: trackTableView.frame, in: view, animated: true)
    }

}

protocol FileLoaderDelegate: class {
    func loadFile(filename: String)
    func loadFile(url: URL)
}

extension AKAppleSequencer: SequencerDelegate { }
