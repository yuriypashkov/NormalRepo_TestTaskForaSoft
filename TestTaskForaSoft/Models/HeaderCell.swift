
import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    
    func setHeader(album: Album) {
        albumLabel.text = album.albumTitle
        artistLabel.text = album.artist
        genreLabel.text = album.genre
        currencyLabel.text = "\(album.albumPrice) \(album.currency)"
        yearLabel.text = album.releaseDate
        albumCover.lazyDownloadImage(link: album.imageURL100px)
    }
    
}
