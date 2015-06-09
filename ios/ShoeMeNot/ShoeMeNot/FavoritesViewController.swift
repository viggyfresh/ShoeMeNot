//
//  FavoritesViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UICollectionViewController {
    private let reuseIdentifier = "ShoeCell"
    private var backend = Backend()
    var shoes : [Shoe] = [Shoe]()
    
    var name: String?
    var social: Bool?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if social == nil {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let fetch = NSFetchRequest(entityName: "Shoe")
            var error: NSError?
            
            let results = managedContext.executeFetchRequest(fetch, error: &error) as! [NSManagedObject]
            
            if results.count != shoes.count {
                shoes = [Shoe]()
                for result in results {
                    var curr = Shoe(id: result.valueForKey("id") as! Int)
                    shoes.append(curr)
                }
                shoes = shoes.reverse()
                self.collectionView?.reloadData()
            }
        }
        if social != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func shareFavorites(sender: AnyObject) {
        var alert = UIAlertController(title: "Share your favorites!", message: "Enter a name for your favorites list.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textfield: UITextField!) -> Void in
            textfield.placeholder = "Name"
            textfield.secureTextEntry = false
        }
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            let fields = alert.textFields as! [UITextField]
            let name = fields[0]
            self.backend.share_favorites(name.text!, shoes: self.shoes, completion: { (msg) -> Void in
                alert = UIAlertController(title: "Share Results", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension FavoritesViewController : UICollectionViewDataSource {
    
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
                shoe.getThumbnail()
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
        if let name = self.name {
            headerView.label.text = name + "'s Favorites"
        }
        else {
            headerView.label.text = "Favorites"
        }
        return headerView
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        SwiftLoader.show(animated: true)
        if segue.identifier == "ShoeView" {
            if let dest = segue.destinationViewController as? ShoeViewController {
                let cell = sender as! ShoeCell
                dest.shoe = cell.shoe
            }
        }
    }
}