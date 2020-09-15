
import Foundation

struct TrackListResponse: Decodable {
    let resultCount: Int
    let results: [NewTrack]
}
