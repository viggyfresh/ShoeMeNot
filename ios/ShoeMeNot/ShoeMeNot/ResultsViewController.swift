//
//  ResultsViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class ResultsViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate  {
    private let reuseIdentifier = "ShoeCell"
    var shoes : [Shoe]!
    let backend = Backend()
    var searchByColor: Bool = true
    var searchByStyle: Bool = true
    var shoeId: String?
    var shoeIdInt: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView?.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShoeView" {
            SwiftLoader.show(animated: true)
            if let dest = segue.destinationViewController as? ShoeViewController {
                let cell = sender as! ShoeCell
                dest.shoe = cell.shoe
            }
        }
        if segue.identifier == "optionsSegue" {
            let popoverViewController = segue.destinationViewController as! SearchOptionsViewController
            popoverViewController.colorSwitchStatus = searchByColor
            popoverViewController.styleSwitchStatus = searchByStyle
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func saveOptions(segue:UIStoryboardSegue) {
        var optionsView:SearchOptionsViewController = segue.sourceViewController as! SearchOptionsViewController
        searchByColor = optionsView.colorSwitch.on
        searchByStyle = optionsView.styleSwitch.on
        SwiftLoader.show(animated: true)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        if shoeId != nil {
            if (searchByColor && searchByStyle) || (!searchByColor && !searchByStyle){
                backend.recompare(shoeId!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
            else if searchByColor {
                backend.recompare_color(shoeId!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
            else if searchByStyle {
                backend.recompare_style(shoeId!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
        }
        else if shoeIdInt != nil {
            if (searchByColor && searchByStyle) || (!searchByColor && !searchByStyle){
                backend.compare_by_id(shoeIdInt!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
            else if searchByColor {
                backend.compare_by_color(shoeIdInt!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
            else if searchByStyle {
                backend.compare_by_style(shoeIdInt!, completion: { (data, msg) -> Void in
                    self.shoes = data!
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        SwiftLoader.hide()
                        self.collectionView?.reloadData()
                    })
                })
            }
        }
    }
    
}

extension ResultsViewController : UICollectionViewDataSource {
    
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
        headerView.label.text = "Search Results"
        return headerView
    }
}