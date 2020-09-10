
import UIKit

class TrackCell: UITableViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    func setTrackCell(trackName: String, number: Int, duration: Double) {
        trackNameLabel.text = trackName
        numberLabel.text = String(number)
        let durationInSeconds = duration / 1000
        let minutes = Int(durationInSeconds / 60)
        let seconds = Int(durationInSeconds) % 60
        if seconds <= 9 {
            durationLabel.text = "\(minutes):0\(seconds)"
        } else {
            durationLabel.text = "\(minutes):\(seconds)"
        }
    }
    
}
