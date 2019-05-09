//
//  LoginVC FOR TESTING ONLY.swift
//  TicChatToe
//
//  Created by Hunter Boleman on 4/27/19.
//  Copyright © 2019 Ricky Bernal. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Button Event for Sign-Up
    @IBAction func doSignUp(_ sender: Any) {
        // Checks for valid text entry
        if (isNotEmpty() == true){
            registerUser();
        }
    }
    
    // Button Event for Login
    @IBAction func doLogin(_ sender: Any) {
        // Checks for valid text entry
        if (isNotEmpty() == true){
            loginUser();
        }
    }
    
    // Registers User
    func registerUser() {
        // initialize a user object
        let newUser = PFUser()
        
        // set user properties
        newUser.username = usernameField.text
        //newUser.email = emailField.text
        newUser.password = passwordField.text
        
        // call sign up function on the object
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                self.alertDisplay(strTitle: "Alert!", strMessage: "Registration did not work, please try again later.")
            } else {
                print("User Registered successfully")
                // manually segue to logged in view
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    // Logs in User
    func loginUser() {
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                print("User log in failed: \(error.localizedDescription)")
                self.alertDisplay(strTitle: "Alert!", strMessage: "Invalid login, or server is down.")
            } else {
                print("User logged in successfully")
                // display view controller that needs to shown after successful login
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    //------------------------------ Extra Functions ------------------------------//
    
    // Logic for Testing if a Text Field is Empty or Not
    func isNotEmpty() -> Bool{
        if (usernameField.text?.isEmpty == true && passwordField.text?.isEmpty == true){
            let alertController = UIAlertController(title: "Empty Fields!", message: "Please enter both a username and password", preferredStyle: .alert)
            // create a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // handle cancel response here. Doing nothing will dismiss the view.
            }
            // add the cancel action to the alertController
            alertController.addAction(cancelAction)
            
            // create an OK action
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
            return false;
        }
        else if (usernameField.text?.isEmpty == true) {
            let alertController = UIAlertController(title: "Enter Username!", message: "Please enter a username!", preferredStyle: .alert)
            // create a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // handle cancel response here. Doing nothing will dismiss the view.
            }
            // add the cancel action to the alertController
            alertController.addAction(cancelAction)
            
            // create an OK action
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
            return false;
        }
        else if (passwordField.text?.isEmpty == true) {
            let alertController = UIAlertController(title: "Enter Password!", message: "Please enter a password!", preferredStyle: .alert)
            // create a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // handle cancel response here. Doing nothing will dismiss the view.
            }
            // add the cancel action to the alertController
            alertController.addAction(cancelAction)
            
            // create an OK action
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
            return false;
        }
        return true;
    }
    
    // Function Used By "isNotEmpty" to Easilty Call Alerts
    func alertDisplay(strTitle: String, strMessage: String){
        // Creates Alert Object
        let alertController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: .alert)
        // Creates a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        // Adds the cancel action to the alertController
        alertController.addAction(cancelAction)
        // Creates an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // Adds the OK action to the alert controller
        alertController.addAction(OKAction)
        // Shows the alert
        present(alertController, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
        }
    }
    
    
}
