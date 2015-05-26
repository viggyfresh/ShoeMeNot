
//
//  ShoeViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class ShoeViewController: UIViewController {
    @IBOutlet var mainShoeMeta : UILabel!
    @IBOutlet var mainShoeImage : UIImageView!
    private var result = "0.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainShoeImage.image = UIImage(named: result)
        mainShoeMeta.text = "Converse Chuck Taylor® All Star® Core Ox Optical White\n\nConverse\n\nOptical White\n\nShoes > Sneakers & Athletic Shoes > Converse\n\n$50.00\n\nSKU 108000"
        mainShoeMeta.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
