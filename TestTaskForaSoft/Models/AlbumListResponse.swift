

import Foundation

struct AlbumListResponse: Decodable {
    let resultCount: Int
    let results: [NewAlbum]
}
