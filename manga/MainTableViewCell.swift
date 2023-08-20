//
//  MainTableTableViewCell.swift
//  manga
//
//  Created by Ryosuke Takaoka on 2023/05/14.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var date: UILabel!
    
    //日付
    func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: now as Date)
        }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        date.text = getToday(format:"yyyy/MM/dd")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
