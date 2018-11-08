//
//  TrackCell.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/13.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var noteEvents: UILabel!
    var trackNum: Int!
}
