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
    
    @IBOutlet var cameraOverlay: UIView!
    var imagePicker: UIImagePickerController!
    var pictureTaken: UIImage!
    var photoAlreadyTaken: Bool!
    var usedCameraRoll: Bool!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoAlreadyTaken = false
        usedCameraRoll = false
    }
    
    override func viewDidAppear(animated: Bool) {
        if photoAlreadyTaken! {
            photoAlreadyTaken = false
            self.dismissViewControllerAnimated(false, completion: nil)
            return
        }
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
            
            photoAlreadyTaken = false
            self.presentViewController(imagePicker, animated: false, completion: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "DrawSegue" {
            let drawVc = segue.destinationViewController as! DrawViewController
            drawVc.hidesBottomBarWhenPushed = true
            drawVc.originalImage = pictureTaken
            photoAlreadyTaken = false
        }
    }
    
    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            self.dismissViewControllerAnimated(false, completion: nil)
            photoAlreadyTaken = true
            usedCameraRoll = true
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.mediaTypes = [kUTTypeImage as NSString]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: false, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        tabBarController?.selectedIndex = 0
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        imagePicker.takePicture()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(false, completion: nil)
        
        if mediaType == (kUTTypeImage as! String) {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if usedCameraRoll! {
                if image.size.width > image.size.height {
                    var temp : CGImageRef = image.CGImage
                    image = UIImage(CGImage: temp, scale: 1, orientation: UIImageOrientation.Right)!
                }
            }
            else {
                if (image.imageOrientation == UIImageOrientation.Up || image.imageOrientation == UIImageOrientation.Down) {
                    var temp : CGImageRef = image.CGImage
                    image = UIImage(CGImage: temp, scale: 1, orientation: UIImageOrientation.Right)!
                }
            }
            
            photoAlreadyTaken = true
            pictureTaken = image
            performSegueWithIdentifier("DrawSegue", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
        photoAlreadyTaken = false
    }
    
}