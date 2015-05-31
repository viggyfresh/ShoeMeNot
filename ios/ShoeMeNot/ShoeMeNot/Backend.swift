//
//  Backend.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import Foundation
import UIKit

class Backend {
    struct Static {
        static var ip = "http://128.12.10.36"
        static var port = "5000"
        static var base_url = ip + ":" + port + "/"
        static var dataset_url = base_url + "static/shoe_dataset/"
    }
    
    let processingQueue = NSOperationQueue()
    
    func discover(completion: (data: [Shoe]?, msg: String) -> Void) {
        let discoverURL = NSURL(string: Static.base_url + "discover")!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(discoverURL, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                completion(data: nil, msg: "ERROR")
            }
            let json = JSON(data: data)
            var msg = toString(json["msg"])
            var ids = json["data"]
            var shoes : [Shoe] = [Shoe]()
            for (index: String, id: JSON) in ids {
                var currURL = NSURL(string: Static.dataset_url + toString(id) + ".jpg")!
                var thumbURL = NSURL(string: Static.dataset_url + toString(id) + "_sm.jpg")!

                shoes.append(Shoe(id: id.int!, url: currURL, thumb_url: thumbURL))
            }
            completion(data: shoes, msg: msg)
        })
        task.resume()
    }
}