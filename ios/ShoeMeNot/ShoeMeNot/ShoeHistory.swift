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
    
    var image : UIImage?
    
    init(id: String) {
        self.id = id
        self.url = NSURL(string: Backend.Static.upload_url + id + ".jpg")!
        self.image = nil
    }
    
    init(id: String, url: NSURL, thumb_url : NSURL) {
        self.id = id
        self.url = url
        self.image = nil
    }
    
    func getImage() {
        var img = UIImage(data: NSData(contentsOfURL: self.url)!)
        self.image = img
    }
}
