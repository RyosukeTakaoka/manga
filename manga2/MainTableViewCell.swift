//
//  MainTableViewCell.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/02/03.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet var img: UIImageView!
    @IBOutlet var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
