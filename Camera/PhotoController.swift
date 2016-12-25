//
//  PhotoController.swift
//  Camera
//
//  Created by Kevin Yan on 12/3/16.
//  Copyright © 2016 Kevin Yan. All rights reserved.
//

import UIKit

class PhotoController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Use UIImagePicker to get a UI to load photos. UIImagePicker also has the ability to take pictures, videos, and load them
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
           
            self.present(imagePicker, animated:false, completion: nil)
            
            
        }
    }
}
