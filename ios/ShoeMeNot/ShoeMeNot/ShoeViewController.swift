
//
//  ShoeViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ShoeViewController: UIViewController {
    @IBOutlet weak var shoeTitle: UILabel!
    @IBOutlet var metadata : UITextView!
    @IBOutlet var image : UIImageView!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    var shoe : Shoe!
    var ns_shoe : NSManagedObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
        if shoe.metadata == nil {
            shoe.getMetadata()
        }
        
        if shoe.image == nil {
            shoe.getImage()
        }
        
        image.image = shoe.image
        displayMetadata()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetch = NSFetchRequest(entityName: "Shoe")
        var error: NSError?
        
        let results = managedContext.executeFetchRequest(fetch, error: &error) as! [NSManagedObject]
        ns_shoe = nil
        for result in results {
            var curr_id = result.valueForKey("id") as! Int
            if shoe.id == curr_id {
                pinButton.image = UIImage(named: "pin")
                ns_shoe = result
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMetadata() {
        var title = shoe.metadata!["name"].stringValue + "\n"
        shoeTitle.text = title
        
        var metaString = shoe.metadata!["price"].stringValue + "\n"
        if shoe.metadata!["stars"].stringValue != "-1" {
            metaString += shoe.metadata!["stars"].stringValue + " stars\n"
        }
        metaString += shoe.metadata!["category"].stringValue + "\n"
        metaString += shoe.metadata!["brand"].stringValue + "\n"
        metaString += shoe.metadata!["color"].stringValue + "\n"
        metaString += shoe.metadata!["sku"].stringValue
        metadata.text = metaString
        metadata.sizeToFit()
    }
    
    @IBAction func favoriteItem(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        if ns_shoe != nil {
            managedContext.deleteObject(ns_shoe!)
            ns_shoe = nil
            pinButton.image = UIImage(named: "pin-empty")
        }
        else {
        
            let entity = NSEntityDescription.entityForName("Shoe", inManagedObjectContext: managedContext)
        
            let shoe_obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
            shoe_obj.setValue(self.shoe.id, forKey: "id")
        
            var error: NSError?
        
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            ns_shoe = shoe_obj
            pinButton.image = UIImage(named: "pin")
        }
        
    }
}
