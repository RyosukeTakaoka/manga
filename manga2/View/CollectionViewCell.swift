//
//  CollectionViewCell.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/01/12.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
