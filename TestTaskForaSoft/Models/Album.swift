
import Foundation

class Album {
    
    var albumTitle: String
    var artist: String
    var imageURL60px: String
    var imageURL100px: String
    var releaseDate: String
    var albumPrice: Double
    var copyright: String
    var currency: String
    var albumID: Int
    var genre: String
    
    init(albumTitle: String, artist: String, imageURL60px: String, imageURL100px: String, releaseDate: String, albumPrice: Double, copyright: String, currency: String, albumID: Int, genre: String) {
        self.albumTitle = albumTitle
        self.artist = artist
        self.imageURL60px = imageURL60px
        self.imageURL100px = imageURL100px
        self.releaseDate = releaseDate
        self.albumPrice = albumPrice
        self.copyright = copyright
        self.currency = currency
        self.albumID = albumID
        self.genre = genre
        
    }
    
}
