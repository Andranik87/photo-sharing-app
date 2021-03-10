//
//  ViewController.swift
//  Instagram Clone
//
//  Created by Andranik Karapetyan on 5/6/20.
//  Copyright © 2020 Andranik Karapetyan. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupORLoginButton: UIButton!
    @IBOutlet weak var switchLoginModeButton: UIButton!
    
    var signupModeActve = true;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil
        {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        //-/ Hide Navigation Bar
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func SignUpORLogin(_ sender: Any)
    {
        
        if emailField.text == "" || passwordField.text == ""
        {
            displayAlert(title: "Error in form", message: "Please enter an email AND password")
        }
        else
        {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            activityIndicator.center = self.view.center;
            
            activityIndicator.hidesWhenStopped = true;
            
            activityIndicator.style = UIActivityIndicatorView.Style.medium
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            self.view.isUserInteractionEnabled = false;
            
            if (signupModeActve)
            {
                print ("Signing Up......")
                
                let user = PFUser()
                
                user.username = emailField.text
                user.password = passwordField.text
                user.email = emailField.text

                user.signUpInBackground
                { (success, error) in
                    
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true;
                    
                    if let error = error
                    {
                      // let errorString = error.userInfo["error"] as? NSString
                      // Show the errorString somewhere and let the user try again.
                        self.displayAlert(title: "Could not sign you up", message: error.localizedDescription)
                        print(error)
                    }
                    else
                    {
                      // Hooray! Let them use the app now.
                        print("signed up!")
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                }
            }
            else
            {
                
            //-/ Login user using PFUser static mathod - with email/usernae and password
                PFUser.logInWithUsername(inBackground: emailField.text!, password: passwordField.text!, block:
                {(user, error) in
                    
            //-/ Stop activity Indicator in completion block
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true;
                    
            //-/ Handle success/failure using user value
                    if user != nil
                    {
                        print("Login Sucessful")
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                    else
                    {
                        var errorText = "Unknown error: please try again"
                        
                        if let error = error
                        {
            //-/ Retrieve error message text for use with an error message display
                            errorText = error.localizedDescription
                        }
                        self.displayAlert(title: "Could not sign you up", message: errorText)
                    }
                        
                })
            }
        }
    }

    @IBAction func SwitchLoginMode(_ sender: Any) {
        if (signupModeActve)
        {
            signupModeActve = false
            
            signupORLoginButton.setTitle("Log In", for: [])
            
            switchLoginModeButton.setTitle("Sign Up", for: [])
        }
        else
        {
            signupModeActve = true
            
            signupORLoginButton.setTitle("Sign Up", for: [])
            
            switchLoginModeButton.setTitle("Log In", for: [])
        }
    }
}

