//
//  ViewController2.swift
//  Camera
//
//  Created by Kevin Yan on 11/27/16.
//  Copyright © 2016 Kevin Yan. All rights reserved.
//
// Use AVFoundation

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, UITextFieldDelegate{

    //Camera
    var captureSession = AVCaptureSession() //coordinate data flow
    var cameraPreview = AVCaptureVideoPreviewLayer() //displaying the camera
    var captureOutput = AVCaptureStillImageOutput() //use for capturing image
    
    //Album
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var assetCollection: PHAssetCollection!
    var albumChecker : Bool = false
    var image: UIImage!
    var photosAsset: PHFetchResult<PHAssetCollection>!
    
    
    @IBOutlet weak var albumName: UITextField!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let connection = captureOutput.connection(withMediaType: AVMediaTypeVideo)
        if connection != nil {
            captureOutput.captureStillImageAsynchronously(from: connection, completionHandler: {
                buffer, error in
                
                let photoData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let photoImage = UIImage(data: photoData!)!
                UIImageWriteToSavedPhotosAlbum(photoImage, nil, nil, nil)
                
                if self.albumName.text != "" {
                    self.image = UIImage(data: photoData!)
                    self.makeAlbum()
                }
                
            })
        }
    }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraPreview.frame = cameraView.bounds
    }

    //delegate function to close keyboard on return
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool{
        //resigns the keyboard as first responder from the view
        textField.resignFirstResponder()
        return true;
    }
    
    func closeKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        //close keyboard on tap
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "closeKeyboard")
        view.addGestureRecognizer(tapGesture)
        self.albumName.delegate = self;
        
        //monitor available capture devices
        let captureDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        
        for device in (captureDeviceDiscoverySession?.devices)!{
            if(device.position == AVCaptureDevicePosition.back){
                do{
                    let captureDeviceInput = try AVCaptureDeviceInput(device: device)
                    if captureSession.canAddInput(captureDeviceInput){
                        captureSession.addInput(captureDeviceInput)
                        
                        if captureSession.canAddOutput(captureOutput){
                            captureSession.addOutput(captureOutput)
                            captureSession.startRunning()
                            
                            cameraPreview = AVCaptureVideoPreviewLayer(session: captureSession)
                            cameraPreview.videoGravity = AVLayerVideoGravityResizeAspectFill; //fill the camera to fit the frame
                            cameraView.layer.addSublayer(cameraPreview)
                        }
                    }
                    
                }
                catch{
                    print("error with getting devices")
                }
            }
        }
    }
    
   /* ------album creation--------*/
    

    func makeAlbum() {
        let newAlbumName = albumName.text!
        
        //get album options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", newAlbumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        //if album found
        if let checker: AnyObject = collection.firstObject {
            self.albumChecker = true
            assetCollection = collection.firstObject!
            self.savePhoto()
            
        }
        //if not found, create a new album
        else {
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: newAlbumName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            },
                completionHandler: { success, error in
                    self.albumChecker = success
                
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collectionFetchResult.firstObject!
                        self.savePhoto()
                }
            })
        }
    }
    
    
    func savePhoto(){
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: self.image)
            let placeHolder = request.placeholderForCreatedAsset
            let changeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            changeRequest!.addAssets([placeHolder!] as NSArray)
        }, completionHandler: { success, error in
        })
    }

        
}

