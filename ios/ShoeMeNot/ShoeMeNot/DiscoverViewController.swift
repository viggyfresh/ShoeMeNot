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
    private var pictures : [NSURL]!
    let backend = Backend()
    
    override func viewDidAppear(animated: Bool) {
        backend.discover() {
            json in
            println("HEREHEREHERE")
            println(json)
        }
    }
}

extension DiscoverViewController : UICollectionViewDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShoeCell
        cell.backgroundColor = UIColor.whiteColor()
        cell.imageView.image = UIImage(named: result)
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
                dest.url = NSURL(string: "http://a2.zassets.com/images/z/3/1/3/3/9/0/3133908-3-4x.jpg")
                dest.image = UIImage(named: "7.jpg")
            }
        }
    }
}