//
//  ProductsTableViewController.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-18.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ProductsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var pictures = [String]()
    var productDescription = [String: String]()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        pictures = Product().getProducts()
        productDescription = Product().productDescription
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - UITableViewDatasource

extension ProductsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        let image = pictures[indexPath.row]
        var title = image.deletePrefixAndSuffix("product_", ".png")
        
        if title == "Skin_Serum" {
            title = "Skin Serum"
        } else if title == "BalanceOil_Capsules" {
            title = "BalanceOil Capsules"
        } else if title == "Energy_Bar" {
            title = "Energy Bar"
        }

        cell.productTitle.text = title
        cell.productImage.image = UIImage(named: pictures[indexPath.row])
        cell.productDescription.text = productDescription[title]
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Row selected")
//        tableView.deselectRow(at: indexPath, animated: true)
//        let urlPath = Bundle.main.path(forResource: "balanceoil_aquax_SD", ofType: "mp4")
//        let url = NSURL.fileURL(withPath: urlPath!)
//        
//        let player = AVPlayer(url: url)
//        let vc = AVPlayerViewController()
//        vc.player = player
//        present(vc, animated: true) {
//            vc.player?.play()
//        }
//    }
}
