//
//  CameraController.swift
//  ShoeMeNot
//
//  Created by Vignesh Venkataraman on 5/26/15.
//  Copyright (c) 2015 Vani Khosla. All rights reserved.
//

import UIKit
import MobileCoreServices

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var newMedia: Bool?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var cameraOverlay: UIView!
    var imagePicker: UIImagePickerController!
    var originalImage: UIImage!
    
    var lastPoint = CGPoint.zeroPoint
    var red: CGFloat = 255.0
    var green: CGFloat = 255.0
    var blue: CGFloat = 255.0
    var brushWidth: CGFloat = 50.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(imageView)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        var width = UIScreen.mainScreen().bounds.width
        var height = width * 1.333
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: width, height: height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = opacity
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
    }
    
    @IBAction func share(sender: AnyObject) {
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false
            NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)
            cameraOverlay.frame = imagePicker.cameraOverlayView!.frame
            imagePicker.cameraOverlayView = cameraOverlay
            cameraOverlay = nil
            var camera_height = UIScreen.mainScreen().bounds.width * 1.333
            var y_adj = (UIScreen.mainScreen().bounds.height - camera_height) / 2.0
            var translate = CGAffineTransformMakeTranslation(0.0, y_adj)
            imagePicker.cameraViewTransform = translate
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    
    }

    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.mediaTypes = [kUTTypeImage as NSString]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        imagePicker.takePicture()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as! String) {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if (image.imageOrientation == UIImageOrientation.Up || image.imageOrientation == UIImageOrientation.Down) {
                var temp : CGImageRef = image.CGImage
                image = UIImage(CGImage: temp, scale: 1, orientation: UIImageOrientation.Right)!
            }
            
            
            originalImage = image
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}