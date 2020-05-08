//
//  InventoryViewController.swift
//  TestApp
//
//  Created by Jacob Smith on 4/18/20.
//  Copyright © 2020 Senior Design. All rights reserved.
//

import UIKit

class InventoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "CellIdentifier"
    let BASE_SERVER_URL = "http://server162.site:59435"
    var items: [IndexPath: String] = [[0, 0]: "bullet"]
    var selectedItem: IndexPath = [0, 0]
    var playerName: String!
    var gameID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
         // Dispose of any resources that can be recreated.
     }
     
     //UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
     {
         return 2;
     }
    
    // Determine cell size
    func collectionView(_ collectionView: UICollectionView,
           layout collectionViewLayout: UICollectionViewLayout,
           sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
//     func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
//     {
//
//         return 1;
//     }
     
     
     //UICollectionViewDatasource methods
//     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//
//         return 1
//     }
    
    // Handling selection    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        selectedItem = didSelectItemAt
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
     }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InventoryViewCell
        
        if items[indexPath] == nil {
            items[indexPath] = items[[-1, -1]]
            items[[-1, -1]] = nil
        }
            
        cell.label.text = items[indexPath]
        cell.loadThumbnailImage(baseUrlString: BASE_SERVER_URL, item: items[indexPath]!, gameID: gameID!, playerName: playerName!)
        
        if indexPath == selectedItem {
            cell.label.textColor = UIColor.red
            cell.backgroundColor = UIColor.red
        }
        else {
            cell.label.textColor = UIColor.lightGray
            cell.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }

     // custom function to generate a random UIColor
     func randomColor() -> UIColor{
         let red = CGFloat(drand48())
         let green = CGFloat(drand48())
         let blue = CGFloat(drand48())
         return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
     }
    
    func addToInventory(_ item: String) {
        let url = URL(string: "\(BASE_SERVER_URL)/add-to-inventory/\(gameID!)/\(playerName!)/\(item)")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print(error)
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                if (dataString != "Success") {
                    print("Error adding item: \(dataString)")
                }
            }
        }
        task.resume()
        
    }
    
    @IBAction func exitScanAndSaveItem(unwindSegue: UIStoryboardSegue) {
        if let sourceVC = unwindSegue.source as? ScanViewController {

            let spacelessItem = sourceVC.item.replacingOccurrences(of: " ", with: "-")
            print(spacelessItem)
            items[[-1, -1]] = spacelessItem
            addToInventory(spacelessItem)
            
            collectionView.reloadData()
        }
    }

    @IBAction func exitScanAndTrashItem(unwindSegue: UIStoryboardSegue) {
        print("Item trashed!")
    }
}
