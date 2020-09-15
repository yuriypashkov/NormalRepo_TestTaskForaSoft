

import Foundation

struct NewAlbum: Decodable {
    
    var albumTitle: String?
    var artist: String?
    var imageURL60px: String?
    var imageURL100px: String?
    var releaseDate: String?
    var albumPrice: Double?
    var copyright: String?
    var currency: String?
    var albumID: Int?
    var genre: String?
    
    enum CodingKeys: String, CodingKey {
        case collectionName
        case artistName
        case artworkUrl60
        case artworkUrl100
        case releaseDate
        case collectionPrice
        case copyright
        case currency
        case collectionId
        case primaryGenreName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.albumTitle = try? container.decode(String.self, forKey: .collectionName)
        self.artist = try? container.decode(String.self, forKey: .artistName)
        self.imageURL60px = try? container.decode(String.self, forKey: .artworkUrl60)
        self.imageURL100px = try? container.decode(String.self, forKey: .artworkUrl100)
        self.releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        releaseDate = releaseDate?.substrForYear() // обрежем дату до строки
        self.albumPrice = try? container.decode(Double.self, forKey: .collectionPrice)
        self.copyright = try? container.decode(String.self, forKey: .copyright)
        self.currency = try? container.decode(String.self, forKey: .currency)
        self.albumID = try? container.decode(Int.self, forKey: .collectionId)
        self.genre = try? container.decode(String.self, forKey: .primaryGenreName)
    }
    
    
}
