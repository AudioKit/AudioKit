// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
