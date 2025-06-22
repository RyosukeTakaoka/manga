import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var heartButton: UIButton!
    
    var isLiked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        updateLikeButton()
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        isLiked.toggle()
        updateLikeButton()
    }

    func updateLikeButton() {
        if isLiked {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartButton.tintColor = .red
        } else {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            heartButton.tintColor = .gray
        }
    }
}
