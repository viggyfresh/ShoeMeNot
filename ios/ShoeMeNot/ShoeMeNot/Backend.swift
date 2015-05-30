//
//  Backend.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import Foundation

class Backend {
    private struct Static {
        static var ip = "http://128.12.10.36"
        static var port = "5000"
        static var base_url = ip + ":" + port + "/"
    }
    
    let processingQueue = NSOperationQueue()
    
    func discover(completion: (data: JSON?) -> Void) {
        let discoverURL = NSURL(string: Static.base_url + "discover")!
        println(discoverURL.absoluteString)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(discoverURL, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                completion(data: nil)
            }
            let json = JSON(data: data)
            completion(data: json)
        })
        task.resume()
    }
}