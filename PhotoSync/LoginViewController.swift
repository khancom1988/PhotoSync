//
//  LoginViewController.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
   
    deinit {
        Oauth.default.callBack = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func loginButtonAction(_ sender: Any) {
        
        Oauth.default.oauth_callback = "oauth-photosync://oauth-callback/flickr"
        Oauth.default.oauth_consumer_key = "61cbac5b962cbeb41853338b6c6f32bb"
        Oauth.default.oauth_secret_key = "8c54fa4f64924a8a"
        Oauth.default.requestMethod = .eGET
        Oauth.default.requestToken()
        
        Oauth.default.callBack = {(success, message) -> Void in
        
            if (success){
                self.dismiss(animated: true, completion: { 
                    Oauth.default.callBack = nil
                })
            }
            else{
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}
