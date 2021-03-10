//
//  PostViewController.swift
//  Instagram Clone
//
//  Created by Andranik Karapetyan on 5/31/20.
//  Copyright © 2020 Andranik Karapetyan. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var comment: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PostImage(_ sender: Any)
    {
    //-/ check if chosen image exists
        if let image = imageToPost.image
        {
    //-/ Create Parse Object to post to parse
            let post = PFObject(className: "Post")
            
            post ["message"] = comment.text
            post["userid"] = PFUser.current()?.objectId
            
    //-/ Check image png data
            if let imageData = image.pngData()
            {
    //-/ Create an Activity Indicator
                let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                
                activityIndicator.center = self.view.center;
                
                activityIndicator.hidesWhenStopped = true;
                
                activityIndicator.style = UIActivityIndicatorView.Style.medium
                
                view.addSubview(activityIndicator)
                
                activityIndicator.startAnimating()
                
                self.view.isUserInteractionEnabled = false;
                
    //-/ Create an Parse File Object for the image using image dat
                let imageFile  = PFFileObject(name: "image.png", data: imageData)
                post["imageFile"] = imageFile
                
    //-/ Save in Background
                post.saveInBackground { (success, error) in
                    
    //-/ Stop activity indicator in save completion block
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true;
                    
    //-/ Display an alert for success and failure - displayAlert() method predefined to display alert
                    if success
                    {
                        self.displayAlert(title: "Image Posted!", message: "Your image has been posted successfully")
                        self.comment.text = ""
                        self.imageToPost.image = nil
                    }
                    else
                    {
                        self.displayAlert(title: "Image could not be posted", message: "Please try again later")
                    }
                }
            }
        }

    }
    
    @IBAction func ChooseImage(_ sender: Any)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageToPost.image = image
        }
        
        self.dismiss(animated: true, completion: nil    )
    }
}
