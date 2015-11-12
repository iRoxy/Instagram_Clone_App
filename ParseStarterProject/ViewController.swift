/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

@available(iOS 8.0, *)
class ViewController: UIViewController {
    
    var signupActive = true
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var mainActionButton: UIButton!
    @IBOutlet var registeredText: UILabel!
    @IBOutlet var secondActionButton: UIButton!
    
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        // check to make sure user has entered a username and password
        if username.text == "" || password.text == ""
        {
            displayAlert("Error in form", message: "Please enter a username and password")
        } else
        {
            // Add activity indicator (spinner)
            activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicatorView.center = self.view.center
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            if signupActive == true
            {
            
            let user = PFUser()
            user.username = username.text
            user.password = password.text
            
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                self.activityIndicatorView.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil
                {
                    // sign up successful
                    
                    self.performSegueWithIdentifier("login", sender: self)
                } else
                {
                    
                    if let errorString = error?.userInfo["error"] as? String {
                        errorMessage = errorString
                    }
                    
                    self.displayAlert("Failed signup", message: errorMessage)
                }
            })
            } else
            {
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicatorView.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if user != nil
                    {
                        // logged in
                        self.performSegueWithIdentifier("login", sender: self)
        
                    } else
                    {
                        if let errorString = error?.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed Login", message: errorMessage)
                    }
                })
            }
            
        }
    }
    
    
    @IBAction func login(sender: AnyObject) {
        if signupActive == true
        {
            mainActionButton.setTitle("Log In", forState: UIControlState.Normal)
            registeredText.text = "Not registered?"
            secondActionButton.setTitle("Sign Up", forState: UIControlState.Normal)
            signupActive = false
        } else
        {
            mainActionButton.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredText.text = "Already registered?"
            secondActionButton.setTitle("Login", forState: UIControlState.Normal)
            signupActive = true
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil
        {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
