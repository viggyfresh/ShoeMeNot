//
//  SocialViewController.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 6/9/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

let reuseIdentifier = "FavoritesCell"

class SocialViewController: UICollectionViewController {
    var backend = Backend()
    var names = [String]()
    var shoes = [Shoe]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadSocial()
    }
    
    func loadSocial() {
        SwiftLoader.show(animated: true)
        backend.social { (data, msg) -> Void in
            println(msg)
            self.names = data!
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                SwiftLoader.hide()
                self.collectionView?.reloadData()
            })
        }

    }

    @IBAction func refresh(sender: AnyObject) {
        self.loadSocial()
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.names.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FavoritesCell
    
        // Configure the cell
        let name = self.names[indexPath.row]
        cell.label.text = name
        cell.label.sizeToFit()
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ShoeHeaderView", forIndexPath: indexPath) as! ShoeHeaderView
        headerView.label.text = "Social"
        return headerView
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let name = self.names[indexPath.row]
        SwiftLoader.show(animated: true)
        backend.social_list(name, completion: { (data, msg) -> Void in
            println(msg)
            self.shoes = data!
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                SwiftLoader.hide()
                self.performSegueWithIdentifier("FavoritesSegue", sender: name)
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FavoritesSegue" {
            if let dest = segue.destinationViewController as? FavoritesViewController {
                dest.shoes = self.shoes
                dest.name = sender as? String
                dest.social = true
            }
        }        
    }
    

}
