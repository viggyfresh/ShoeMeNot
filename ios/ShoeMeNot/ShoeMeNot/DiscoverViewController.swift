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
}