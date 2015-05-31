
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
    var shoe : Shoe!

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
        
        let entity = NSEntityDescription.entityForName("Shoe", inManagedObjectContext: managedContext)
        
        let shoe_obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        shoe_obj.setValue(self.shoe.id, forKey: "id")
        
        var error: NSError?
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
