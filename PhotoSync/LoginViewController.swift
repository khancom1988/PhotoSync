//
//  LoginViewController.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
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
        
        
        let oauth_nonce = Utility.getNonce()
        let oauth_timestamp = Utility.getTimestamp()

        if let oauth_signature = Oauth.sign("https://www.flickr.com/services/oauth/request_token", "61cbac5b962cbeb41853338b6c6f32bb", "8c54fa4f64924a8a", oauth_nonce, oauth_timestamp, "oauth-photosync://oauth-callback/flickr", "HMAC-SHA1", "GET", nil){
           
            let url = String(format: "https://www.flickr.com/services/oauth/request_token?oauth_nonce=%@&oauth_timestamp=%@&oauth_consumer_key=%@&oauth_signature_method=HMAC-SHA1&oauth_version=1.0&oauth_signature=%@&oauth_callback=oauth-photosync://oauth-callback/flickr",oauth_nonce,oauth_timestamp,"61cbac5b962cbeb41853338b6c6f32bb",oauth_signature)

            HttpClient.requestWith(url: url, completionHandler:{(error,data) -> Void in
                
            })
            
//            if let params = Oauth.prepareParametersWithValues("61cbac5b962cbeb41853338b6c6f32bb", "8c54fa4f64924a8a", oauth_nonce, oauth_timestamp, "oauth-photosync://oauth-callback/flickr", "HMAC-SHA1", "POST", nil){
//                
//                let url = String(format: "https://www.flickr.com/services/oauth/request_token")
//                HttpClient.requestWith(url: url, requestType: RequestType.ePOST, parameters: nil, headers: params, completionHandler: { (error,data) in
//                    
//                })
//            }
        }
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
            self.passwordTxtField.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
    }
}
