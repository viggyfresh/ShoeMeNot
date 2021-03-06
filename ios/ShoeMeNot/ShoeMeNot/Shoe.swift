//
//  Shoe.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/30/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import Foundation
import UIKit

class Shoe {
    var id : Int!
    var url : NSURL!
    var thumb_url : NSURL!
    
    var image : UIImage?
    var thumb_image: UIImage?
    var metadata : JSON?
    
    init(id: Int) {
        self.id = id
        self.thumb_url = NSURL(string: Backend.Static.dataset_url + toString(id) + "_sm.jpg")!
        self.thumb_image = nil
        self.metadata = nil
    }
    
    init(id: Int, thumb_url : NSURL) {
        self.id = id
        self.thumb_url = thumb_url
        self.thumb_image = nil
        self.metadata = nil
    }
    
    func getThumbnail() {
        if self.thumb_image == nil {
            var img = UIImage(data: NSData(contentsOfURL: self.thumb_url)!)
            self.thumb_image = img
        }
    }
    
    func getMetadata() {
        if self.metadata == nil {
            var url = NSURL(string: Backend.Static.base_url + "shoe/" + String(id))!
            var data = NSData(contentsOfURL: url)!
            self.metadata = JSON(data: data)
        }
    }
}
