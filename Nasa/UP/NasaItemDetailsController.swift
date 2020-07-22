//
//  NasaItemDetailsController.swift

import UIKit

class NasaItemDetailsController: UIViewController {

    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    var item: NasaItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setValues()
    }
    
    func setValues() {
        if let item = item {
            title = item.id
            itemTitleLabel.text = item.name
            itemDescriptionLabel.text = item.desc
            itemImageView.kf.setImage(with: item.getUrl())
        }
    }

}
