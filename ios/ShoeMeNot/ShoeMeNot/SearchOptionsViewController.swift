//
//  SearchOptionsViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 6/9/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class SearchOptionsViewController: UITableViewController{
    @IBOutlet var colorSwitch : UISwitch!
    @IBOutlet var styleSwitch : UISwitch!
    var styleSwitchStatus : Bool?
    var colorSwitchStatus : Bool?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let blueColor = UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        colorSwitch.onTintColor = blueColor
        styleSwitch.onTintColor = blueColor
        colorSwitch.setOn(colorSwitchStatus!, animated: false)
        styleSwitch.setOn(styleSwitchStatus!, animated: false)
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

}
