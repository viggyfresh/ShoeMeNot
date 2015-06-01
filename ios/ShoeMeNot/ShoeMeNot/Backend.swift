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
        static var upload_url = base_url + "static/uploads/"
    }
    
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
    
    func upload(image: UIImage, completion: (data: [Shoe]?, msg: String, id: String) -> Void) {
        var rotated : UIImage
        if image.imageOrientation.rawValue == 0 {
            rotated = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Left)!
        }
        else {
            rotated = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.Up)!
        }
        
        var imageData = UIImageJPEGRepresentation(rotated, 0.5)!
        let uploadURL = NSURL(string: Static.base_url + "upload")!
        var request = NSMutableURLRequest(URL: uploadURL)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSData(data: imageData)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                completion(data: nil, msg: "ERROR", id: "blah")
            }
            let json = JSON(data: data)
            var msg = toString(json["msg"])
            var upload_id = (json["id"] as JSON).stringValue
            var ids = json["data"]
            var shoes : [Shoe] = [Shoe]()
            for (index: String, id: JSON) in ids {
                var currURL = NSURL(string: Static.dataset_url + toString(id) + ".jpg")!
                var thumbURL = NSURL(string: Static.dataset_url + toString(id) + "_sm.jpg")!
                
                shoes.append(Shoe(id: id.int!, url: currURL, thumb_url: thumbURL))
            }
            completion(data: shoes, msg: msg, id: upload_id)
        })
        task.resume()
        
    }
}