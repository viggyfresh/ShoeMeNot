//
//  DiscoverViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class DiscoverViewController: UICollectionViewController {
    private let reuseIdentifier = "ShoeCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var result = "0.jpg"
    private var shoes : [Shoe] = [Shoe]()
    let backend = Backend()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freshDiscovery()
    }
    
    @IBAction func discover(sender: AnyObject) {
        freshDiscovery()
    }
    
    func freshDiscovery() {
        backend.discover() {
            data, msg in
            println(msg)
            self.shoes = data!
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
        }
    }
}

extension DiscoverViewController : UICollectionViewDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShoeCell
        cell.backgroundColor = UIColor.whiteColor()
        let shoe = self.shoes[indexPath.row]
        if shoe.thumb_image == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                println("Updating image for " + String(indexPath.row))
                let data = NSData(contentsOfURL: shoe.thumb_url)!
                var img = UIImage(data: data)
                shoe.thumb_image = img
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    cell.shoe = shoe
                    cell.imageView.image = shoe.thumb_image
                })
            })
        }
        cell.shoe = shoe
        cell.imageView.image = shoe.thumb_image
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ShoeHeaderView", forIndexPath: indexPath) as! ShoeHeaderView
        headerView.label.text = "Discover"
        return headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShoeView" {
            if let dest = segue.destinationViewController as? ShoeViewController {
                let cell = sender as! ShoeCell
                dest.shoe = cell.shoe
            }
        }
    }
}