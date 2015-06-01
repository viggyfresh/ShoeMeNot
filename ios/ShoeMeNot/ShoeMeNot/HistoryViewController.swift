//
//  HistoryViewController.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/25/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UICollectionViewController {
    
    private let reuseIdentifier = "HistoryCell"
    private var history : [HistoryItem] = [HistoryItem]()
    
    
    override func viewWillAppear(animated: Bool) {
        history = [HistoryItem]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetch = NSFetchRequest(entityName: "HistoryItem")
        var error: NSError?
        
        let results = managedContext.executeFetchRequest(fetch, error: &error) as! [NSManagedObject]
        for result in results {
            var curr = HistoryItem(id: result.valueForKey("id") as! String)
            history.append(curr)
        }
        self.collectionView?.reloadData()
    }

}

extension HistoryViewController : UICollectionViewDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! HistoryCell
        cell.backgroundColor = UIColor.whiteColor()
        let shoe = self.history[indexPath.row]
        if shoe.image == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                shoe.getImage()
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    cell.shoe = shoe
                    cell.imageView.image = shoe.image
                })
            })
        }
        cell.shoe = shoe
        cell.imageView.image = shoe.image

        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ShoeHeaderView", forIndexPath: indexPath) as! ShoeHeaderView
                headerView.label.text = "History"
                return headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShoeView" {
            if let dest = segue.destinationViewController as? ShoeViewController {
                //dest.url = NSURL(string: "http://a2.zassets.com/images/z/7/4/5/7459-3-4x.jpg")
            }
        }
    }
}
