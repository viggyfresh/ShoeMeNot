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
    
    func recompare(id: String, completion: (data: [Shoe]?, msg: String) -> Void) {
        let recompareURL = NSURL(string: Static.base_url + "recompare/" + id)!
        var response: NSURLResponse?
        var request = NSURLRequest(URL: recompareURL)
        var error: NSErrorPointer = nil
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        
        let json = JSON(data: data!)
        var msg = toString(json["msg"])
        var ids = json["data"]
        var shoes : [Shoe] = [Shoe]()
        for (index: String, id: JSON) in ids {
            var currURL = NSURL(string: Static.dataset_url + toString(id) + ".jpg")!
            var thumbURL = NSURL(string: Static.dataset_url + toString(id) + "_sm.jpg")!
            shoes.append(Shoe(id: id.int!, url: currURL, thumb_url: thumbURL))
        }
        completion(data: shoes, msg: msg)
    }
    
    func compare_by_id(id: Int, completion: (data: [Shoe]?, msg: String) -> Void) {
        let compareURL = NSURL(string: Static.base_url + "compare/" + toString(id))!
        var response: NSURLResponse?
        var request = NSURLRequest(URL: compareURL)
        var error: NSErrorPointer = nil
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        
        let json = JSON(data: data!)
        var msg = toString(json["msg"])
        var ids = json["data"]
        var shoes : [Shoe] = [Shoe]()
        for (index: String, id: JSON) in ids {
            var currURL = NSURL(string: Static.dataset_url + toString(id) + ".jpg")!
            var thumbURL = NSURL(string: Static.dataset_url + toString(id) + "_sm.jpg")!
            shoes.append(Shoe(id: id.int!, url: currURL, thumb_url: thumbURL))
        }
        completion(data: shoes, msg: msg)
    }
    
    func upload(image: UIImage, completion: (data: [Shoe]?, msg: String, id: String) -> Void) {
        println(image.imageOrientation.rawValue)
        var rotated : UIImage
        if image.imageOrientation.rawValue == 0 {
            rotated = image.imageRotatedByDegrees(-90.0, flip: false)
        }
        else {
            rotated = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.Up)!
            //rotated = image.imageRotatedByDegrees(180.0, flip: false)
        }
        //var rotated = image
        var imageData = UIImageJPEGRepresentation(rotated, 0.5)!
        let uploadURL = NSURL(string: Static.base_url + "upload")!
        var request = NSMutableURLRequest(URL: uploadURL)
        request.HTTPMethod = "POST"
        
        // Set Content-Type in HTTP header.
        let boundaryConstant = "Boundary-WiggyfreshWiggyfreshWiggyfresh"; // This should be auto-generated.
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        
        let fileName = "file.jpg"
        let mimeType = "image/jpeg"
        let fieldName = "file"
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var error: NSError?
        var dataString = "--\(boundaryConstant)\r\n"
        dataString += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
        dataString += "Content-Type: \(mimeType)\r\n\r\n"
        
        println(dataString)
        
        var body = NSMutableData.alloc()
        
        var requestBodyData = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        body.appendData(requestBodyData)
        body.appendData(imageData)
        body.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(string: "--\(boundaryConstant)--\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        request.HTTPBody = body

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