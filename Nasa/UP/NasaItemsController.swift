//
//  NasaItemsController.swift

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class NasaItemsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var items: [NasaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        getItems()
        self.title = "NASA"
    }
    
    func commonInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NasaItemTableCell", bundle: nil), forCellReuseIdentifier: "NasaItemTableCell")
    }
    
    func getItems() {
        self.items.removeAll()
        //api key : D7zN5FgdR6xiWWPTjGWGHyfziY6AVedCNneKqOfi
        self.indicator.isHidden = false
        let url = URL(string: "https://images-api.nasa.gov/search?q=planets&media_type=image")!
        let parameters = Parameters()
        let headers = HTTPHeaders()
        let encoding : ParameterEncoding = URLEncoding.default
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            print(response.result)
            self.indicator.isHidden = true
            if let items = JSON(response.result.value as Any)["collection"]["items"].array {
                for item in items {
                    if let i = NasaItem.create(from: item) {
                        self.items.append(i)
                        self.reloadData()
                    }
                }
            }
            NasaItem.deleteAll()
            self.items.save()
        }
    }
    
    func reloadData() {
        self.items = self.items.sorted(by: {$0.name < $1.name})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Mbyll", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "ZGJEDH", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Fshij të dhënat", style: .default, handler: { (alert) in
            if self.items.count > 0 {
                self.items.removeAll()
//                Item.deleteAll()
                self.reloadData()
                self.showAlert(title: "Njoftim", message: "Të dhënat janë fshirë me sukses")
            }else {
                self.showAlert(title: "Njoftim", message: "Nuk ka të dhënat për tu fshirë")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Fresko të dhënat", style: .default, handler: { (alert) in
            self.getItems()
            self.showAlert(title: "Njoftim", message: "Të dhënat janë përditësuar!")

        }))
        
        
        alert.addAction(UIAlertAction(title: "Anulo", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NasaItemTableCell", for: indexPath) as! NasaItemTableCell
        cell.ItemTitleLabel.text = item.name
        cell.ItemDescriptionLabel.text = item.desc
        cell.ItemImageView.kf.setImage(with: item.getUrl())
        cell.ItemImageView.layer.cornerRadius = cell.ItemImageView.layer.frame.height / 2
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NasaItemDetailsController") as! NasaItemDetailsController
        controller.item = items[indexPath.item]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}



