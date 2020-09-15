

import UIKit

class AlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    func setCell(albumTitle: String, imageUrl: String, artist: String, year: String) {
        albumTitleLabel.text = albumTitle
        artistLabel.text = artist
        yearLabel.text = year
        albumCover.image = UIImage(named: "white")
        albumCover.lazyDownloadImage(link: imageUrl)
    }
}


