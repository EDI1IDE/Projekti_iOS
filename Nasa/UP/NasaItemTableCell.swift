//
//  ItemTableViewCell.swift


import UIKit

class NasaItemTableCell: UITableViewCell {

    @IBOutlet weak var ItemImageView: UIImageView!
    @IBOutlet weak var ItemDescriptionLabel: UILabel!
    @IBOutlet weak var ItemTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
