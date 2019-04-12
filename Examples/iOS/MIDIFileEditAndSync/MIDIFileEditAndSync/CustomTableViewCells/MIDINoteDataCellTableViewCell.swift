//
//  MIDINoteDataCellTableViewCell.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/13.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class MIDINoteDataCellTableViewCell: UITableViewCell {
    @IBOutlet weak var noteNum: UILabel!
    @IBOutlet weak var velocity: UILabel!
    @IBOutlet weak var channel: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var duration: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
