//
//  DrawViewController.swift
//  ShoeMeNot
//
//  Created by Neal Khosla on 5/28/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var originalImage: UIImage!
    
    var lastPoint = CGPoint.zeroPoint
    var red: CGFloat = 255.0
    var green: CGFloat = 255.0
    var blue: CGFloat = 255.0
    var brushWidth: CGFloat = 25.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var height: CGFloat!
    var width: CGFloat!
    
    var backend = Backend()
    
    var shoes: [Shoe] = [Shoe]()
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
        width = UIScreen.mainScreen().bounds.width
        height = width * 1.333
        imageView.contentMode = .ScaleAspectFit
        imageView.image = originalImage
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(imageView)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 6
        swiped = true
        if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(imageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func reset(sender: AnyObject) {
        imageView.image = originalImage
    }
    
    @IBAction func retakePhoto(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func uploadImage(sender: AnyObject) {
        backend.upload(imageView.image!, completion: { (data, msg, id) -> Void in
            println(msg)
            // TODO: to save id to history database
            self.shoes = data!
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("ResultsSegue", sender: nil)
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ResultsSegue" {
            if let destVC = segue.destinationViewController as? ResultsViewController {
                destVC.shoes = self.shoes
            }
        }
    }
}

