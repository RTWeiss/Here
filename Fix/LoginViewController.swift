////
//  LoginViewController.swift
//  Here
//
//  Created by Zackery leman on 8/2/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    private let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUp: UIButton!
    var nickname: String!
    
    
    struct StoryBoard {
        static let loggingInSegue = "loggingIn"
    }
    
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meteor.addObserver(self, forKeyPath: "connected", options: NSKeyValueObservingOptions.New, context: nil)
        self.confirmPassword.hidden = true
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        var observingOption = NSKeyValueObservingOptions.New
        meteor.addObserver(self, forKeyPath:"websocketReady", options: observingOption, context:nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        
        if (keyPath == "connected" && meteor.websocketReady) {
            let (dictionary, error) = Locksmith.loadDataForUserAccount(GlobalConstants.singleUserAccount)
            if let result = dictionary {
                email.text = (result.allKeys as [String]).last
                password.text = (result.allValues as [String]).last
                signIn()
            } else {
                println(error)
            }
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        if self.confirmPassword.hidden {
            //Show hidden field
            self.confirmPassword.hidden = false
        } else {

            if password.text == confirmPassword.text {
                //Check connection
                if !meteor.websocketReady {
                    let notConnectedAlert = UIAlertView(title: "Connection Error", message: "Can't find the server, try again", delegate: nil, cancelButtonTitle: "OK")
                    notConnectedAlert.show()
                    return
                }
                
                self.meteor.signupWithEmail(email.text, password:password.text, fullname: email.text)
                    {(response, error) in
                        if (error != nil) {
                            
                            var alert = UIAlertController(title: "Sign up Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            return
                            
                        }
                        
                        let parameters = [("\(arc4random())"),self.meteor.userId]
                        
                        self.meteor.callMethodName("addUserName", parameters:parameters, responseCallback:{( response,  error) in
                            if (error != nil) {
                                println("Failed at adding username")
                                println("\(error.description)")
                                
                                return
                            }
                            println("Sucess at adding userName")
                        });
                        
                        
                        self.handleSuccessfulAuth()
                }
                
                
            } else {
                
                var alert = UIAlertController(title: "Sign up Error", message: "Passwords do not match. Please re-enter passwords.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    
    
    
    
    @IBAction func didTapLoginButton(sender: AnyObject) {
        
        signIn()
    }
    
    func signIn(){
        if !meteor.websocketReady {
            let notConnectedAlert = UIAlertView(title: "Connection Error", message: "Can't find the server, try again", delegate: nil, cancelButtonTitle: "OK")
            notConnectedAlert.show()
            return
        }
        
        meteor.logonWithEmail(self.email.text, password: self.password.text) {(response, error) -> Void in
            
            if error != nil {
                self.handleFailedAuth(error)
                return
            }
            self.handleSuccessfulAuth()
        }
    }
    
    func handleSuccessfulAuth() {
        
        if let error = Locksmith.saveData([email.text: password.text], forUserAccount: GlobalConstants.singleUserAccount){
            println(error)
        } 
        performSegueWithIdentifier(StoryBoard.loggingInSegue, sender: nil)
        
    }
    
    func handleFailedAuth(error: NSError) {
        UIAlertView(title: "Here", message:error.localizedDescription, delegate: nil, cancelButtonTitle: "Try Again").show()
    }

    

    
}


