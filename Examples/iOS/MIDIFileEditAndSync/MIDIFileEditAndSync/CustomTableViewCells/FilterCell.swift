//
//  FilterCell.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!
    var pitchClass: Int = 0
    var offset: Int = 0
    weak var filterModifier: FilterModifier?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func decreaseOffset(_ sender: Any) {
        offset -= 1
        filterModifier?.changeOffset(pitchClass: pitchClass, offset: offset)
    }

    @IBAction func increaseOffset(_ sender: Any) {
        offset += 1
        filterModifier?.changeOffset(pitchClass: pitchClass, offset: offset)
    }
}
