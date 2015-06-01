//
//  ShoeHistory.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/31/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import Foundation
import UIKit

class HistoryItem {
    var id : String!
    var url : NSURL!
    var thumb_url : NSURL!
    
    var image : UIImage?
    var thumb_image : UIImage?
    
    init(id: String) {
        self.id = id
        self.url = NSURL(string: Backend.Static.upload_url + id + ".jpg")!
        self.thumb_url = NSURL(string: Backend.Static.upload_url + id + "_sm.jpg")!
        self.image = nil
        self.thumb_image = nil
    }
    
    func getImage() {
        var img = UIImage(data: NSData(contentsOfURL: self.url)!)
        self.image = img
    }
    
    func getThumbnail() {
        var img = UIImage(data: NSData(contentsOfURL: self.thumb_url)!)
        self.thumb_image = img
    }
}
