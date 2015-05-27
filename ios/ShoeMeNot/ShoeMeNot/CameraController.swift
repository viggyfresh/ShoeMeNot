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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func useCamera(sender: AnyObject) {
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
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            imageView.image = image
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}