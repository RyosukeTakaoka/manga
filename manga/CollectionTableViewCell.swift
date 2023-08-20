//
//  CollectionTableViewCell.swift
//  manga
//
//  Created by Ryosuke Takaoka on 2023/05/28.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet var titleaLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet override var backgroundImageView: UIImageView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
