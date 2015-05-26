//
//  HistoryViewController.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/25/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class HistoryViewController: UICollectionViewController {
    
    private let reuseIdentifier = "ShoeCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var result = "0.jpg"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

}

extension HistoryViewController : UICollectionViewDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ShoeHeaderView", forIndexPath: indexPath) as! ShoeHeaderView
                headerView.label.text = "History"
                return headerView
    }
}
