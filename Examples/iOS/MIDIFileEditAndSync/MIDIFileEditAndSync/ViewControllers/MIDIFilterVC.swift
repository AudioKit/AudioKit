//
//  MIDIFilterVC.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class MIDIFilterVC: UIViewController, UITableViewDataSource, FilterModifier {

    @IBOutlet weak var filterTable: UITableView!
    weak var filterTableDelegate: FilterTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setUpTableView()
    }

    @IBAction func resetButton(_ sender: Any) {
        (0 ..< 12).forEach {
            filterTableDelegate?.changeOffset(pitchClass: $0, offset: 0)
        }
        filterTable.reloadData()
    }

    // MARK: - TableView
    fileprivate func setUpTableView() {
        filterTable.register(UINib(nibName: Constants.Identifiers.filterCell.rawValue, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.filterCell.rawValue)
        filterTable.dataSource = self
        filterTable.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTableDelegate?.offsets.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else { return UITableViewCell() }
        cell.noteName.text = Constants.pitchClassSpellings[indexPath.row]
        cell.pitchClass = indexPath.row
        if let offset = filterTableDelegate?.offsets[indexPath.row] {
            cell.offsetLabel.text = "\(offset)"
            cell.offset = offset
        }
        cell.filterModifier = self
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Filter will modify each pitch class by offset:"
    }

    func changeOffset(pitchClass: Int, offset: Int) {
        filterTableDelegate?.changeOffset(pitchClass: pitchClass, offset: offset)
        filterTable.reloadData()
    }
}

protocol FilterModifier: class {
    func changeOffset(pitchClass: Int, offset: Int)
}
