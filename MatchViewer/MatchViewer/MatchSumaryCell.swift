//
//  MatchSumaryCell.swift
//  MatchViewer
//
//  Created by David Bireta on 12/13/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

class MatchSumaryCell: UITableViewCell {
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var loserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gameSummaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
