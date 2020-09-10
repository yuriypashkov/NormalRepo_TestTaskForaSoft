
import UIKit

class AboutCell: UITableViewCell {

    @IBOutlet weak var copyrightLabel: UILabel!
    
    func setAbout(copyright: String) {
        copyrightLabel.text = copyright
    }
    
    
}
