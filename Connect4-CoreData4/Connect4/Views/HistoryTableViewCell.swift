//
//  HistoryTableViewCell.swift
//  Connect4
//
//  Created by apple on 10/12/2022.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet weak var startLab: UILabel!
    @IBOutlet weak var winLab: UILabel!
    
    let maskShapeLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
