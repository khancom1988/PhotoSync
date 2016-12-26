//
//  OAuth.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/26/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation
import UIKit

class User {
    var user_name:String?
    var user_id:String?
}

class Oauth  {
    
    public static var `default`: Oauth { return defaultOauth }
    private static var defaultOauth:Oauth = Oauth()

    var oauth_consumer_key:String?
    var oauth_secret_key:String?
    var oauth_callback:String?
    var requestMethod:RequestType = .eGET
    
    let oauth_signature_method = "HMAC-SHA1"
    let oauth_version = "1.0"
    
    let request_token_URL = URL(string: "https://www.flickr.com/services/oauth/request_token")!
    let authorization_URL = URL(string: "https://www.flickr.com/services/oauth/authorize")!
    let access_token_URL = URL(string: "https://www.flickr.com/services/oauth/access_token")!

    private var oauth_nonce = Utility.getNonce()
    private var oauth_timestamp = Utility.getTimestamp()
    
    private var oauth_token:String?
    private var oauth_verifier:String?
    private var oauth_token_secret:String?
    
    private var user = User()
    
    public typealias oauthCallBack = (Bool,String) -> ()

    public var callBack: oauthCallBack?
    

    var accessToken:String?{
        return self.oauth_token
    }
    
    var consumer_key:String?{
        return self.oauth_consumer_key
    }
    
    var user_ID:String?{
        return self.user.user_id
    }
    
    var user_name:String?{
        return self.user.user_name
    }

    public func requestToken() -> Void{
        
        assert((oauth_secret_key != nil), "SECRET KEY CAN'T BE NIL")
        assert((oauth_consumer_key != nil), "CONSUMER KEY CAN'T BE NIL")
        assert((oauth_callback != nil), "CALLBACK URL CAN'T BE NIL")
        
        self.oauth_nonce = Utility.getNonce()
        self.oauth_timestamp = Utility.getTimestamp()

        if let oauth_signature  = self.sign(url: self.request_token_URL){

            let request_token_URL_string = self.request_token_URL.absoluteString
            var mutableUrlString = request_token_URL_string + "?"
            mutableUrlString.append("oauth_nonce=" + self.oauth_nonce)
            mutableUrlString.append("&oauth_timestamp=" + self.oauth_timestamp)
            mutableUrlString.append("&oauth_consumer_key=" + self.oauth_consumer_key!)
            mutableUrlString.append("&oauth_signature_method=" + self.oauth_signature_method)
            mutableUrlString.append("&oauth_version=" + self.oauth_version)
            mutableUrlString.append("&oauth_signature=" + oauth_signature)
            mutableUrlString.append("&oauth_callback=" + self.oauth_callback!)
            
            HttpClient.requestWith(url: mutableUrlString, completionHandler:{(error,data) -> Void in
               
                if (error == nil){
                    let response = String(data: data!, encoding: String.Encoding.utf8)
                    let parameters = response?.dictionaryBySplitting("&", keyValueSeparator: "=")
                    if let oauthToken = parameters?["oauth_token"] , let oauthTokenSecret = parameters?["oauth_token_secret"]{
                        self.oauth_token = oauthToken.safeStringByRemovingPercentEncoding
                        self.oauth_token_secret = oauthTokenSecret
                        self.authorize()
                    }
                    else if let fail_reason = parameters?["oauth_problem"]{
                        self.callBackWithStatus(false, "Authozization failed, reason : " + fail_reason)
                    }
                    else{
                        self.callBackWithStatus(false, "Authozization failed")
                    }
                }
            })
            
        }
        
    }
    
    public func handleOpenURL(_ url:URL) -> Bool {
        
        let callback = url.absoluteString
        if callback.contains(self.oauth_callback!){
            
            let tokenString = callback.replacingOccurrences(of: self.oauth_callback! + "?", with: "")
            
            let parameters = tokenString.dictionaryBySplitting("&", keyValueSeparator: "=")
            
            if let oauthToken = parameters["oauth_token"] , let oauthVerifier = parameters["oauth_verifier"]{
                self.oauth_token = oauthToken.safeStringByRemovingPercentEncoding
                self.oauth_verifier = oauthVerifier.safeStringByRemovingPercentEncoding
                self.fetchAccessToken()
            }
            else if let fail_reason = parameters["oauth_problem"]{
                self.callBackWithStatus(false, "Authozization failed, reason : " + fail_reason)
            }
            else{
                self.callBackWithStatus(false, "Authozization failed")
            }
        }

        return true
    }

    
    private func sign(url:URL) -> String?{
        
        guard let consumerSecretKey = self.oauth_secret_key, let consumerKey = self.oauth_consumer_key, let callBack = self.oauth_callback else {
            return nil
        }
        
        let encodedTokenSecret = self.oauth_token_secret?.urlEncodedString
        let encodedConsumerSecret = consumerSecretKey.urlEncodedString
        
        
        let request_url_string = url.absoluteString
        
        let encodedURL = request_url_string.urlEncodedString
        let percentEncoded_oauth_callback = ("oauth_callback=" + callBack.escapeStr)
        let percentageEncodedConsumerKey = ("oauth_consumer_key=" + consumerKey.escapeStr)
        let percentageEncoded_oauth_nonce = ("oauth_nonce=" + oauth_nonce.escapeStr)
        let percentageEncoded_oauth_signature_method = ("oauth_signature_method=" + oauth_signature_method.escapeStr)
        let percentageEncoded_oauth_timestamp = ("oauth_timestamp=" + oauth_timestamp.escapeStr)
        
        var percentageEncoded_oauth_token:String? = nil
        
        if let token = self.oauth_token{
            percentageEncoded_oauth_token = ("oauth_token=" + token.escapeStr)
        }

        var percentageEncoded_oauth_verifier:String? = nil
        if let verifier = self.oauth_verifier{
            percentageEncoded_oauth_verifier = ("oauth_verifier=" + verifier.escapeStr)

        }
        
        let percentageEncoded_oauth_version = ("oauth_version=" + "1.0".escapeStr)
        
        var parameterString = ""
        
        if let encoded_oauth_Token = percentageEncoded_oauth_token, let encoded_oauth_verifier = percentageEncoded_oauth_verifier{
            parameterString = percentageEncodedConsumerKey + "&" + percentageEncoded_oauth_nonce + "&" + percentageEncoded_oauth_signature_method + "&" + percentageEncoded_oauth_timestamp + "&" + encoded_oauth_Token + "&" + encoded_oauth_verifier + "&" + percentageEncoded_oauth_version
        }
        else{
            parameterString = percentEncoded_oauth_callback + "&" + percentageEncodedConsumerKey + "&" + percentageEncoded_oauth_nonce + "&" + percentageEncoded_oauth_signature_method + "&" + percentageEncoded_oauth_timestamp + "&" + percentageEncoded_oauth_version

        }
        
        let encodedParameterString = parameterString.urlEncodedString
        
        let signatureBaseString = "\(requestMethod.description)&\(encodedURL)&\(encodedParameterString)"
        
        var signingKey = ""
        
        if let token = encodedTokenSecret{
            signingKey = "\(encodedConsumerSecret)&\(token)"
        }
        else{
            signingKey = encodedConsumerSecret + "&"
        }
        
        
        return signatureBaseString.hmac(algorithm: CryptoAlgorithm.SHA1, key: signingKey)
        
//        let key = signingKey.data(using: .utf8)!
//        let msg = signatureBaseString.data(using: .utf8)!
//        
//        if let sha1 = HMAC.sha1(key: key, message: msg){
//            return sha1.base64EncodedString(options: [])
//            
//        }
//        return nil
    }
    
    private func authorize() -> Void{
    
        let authorization_URL_string = self.authorization_URL.absoluteString
        var mutableUrlString = authorization_URL_string + "?"
        mutableUrlString.append("oauth_token=" + self.oauth_token!)
        mutableUrlString.append("&perms=" + "read")
        if let url = URL(string: mutableUrlString), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: { (ok) in
                
            })
        }
    }
    
    private func fetchAccessToken() -> Void {
        
        self.oauth_nonce = Utility.getNonce()
        self.oauth_timestamp = Utility.getTimestamp()

        if let oauth_signature  = self.sign(url: self.access_token_URL){
            
            let access_token_URL_string = self.access_token_URL.absoluteString
            var mutableUrlString = access_token_URL_string + "?"
            mutableUrlString.append("oauth_nonce=" + self.oauth_nonce)
            mutableUrlString.append("&oauth_timestamp=" + self.oauth_timestamp)
            mutableUrlString.append("&oauth_verifier=" + self.oauth_verifier!)
            mutableUrlString.append("&oauth_consumer_key=" + self.oauth_consumer_key!)
            mutableUrlString.append("&oauth_signature_method=" + self.oauth_signature_method)
            mutableUrlString.append("&oauth_version=" + self.oauth_version)
            mutableUrlString.append("&oauth_token=" + self.oauth_token!)
            mutableUrlString.append("&oauth_signature=" + oauth_signature)
            
            HttpClient.requestWith(url: mutableUrlString, completionHandler:{(error,data) -> Void in
                
                if (error == nil){
                   
                    let response = String(data: data!, encoding: String.Encoding.utf8)
                   
                    let parameters = response?.dictionaryBySplitting("&", keyValueSeparator: "=")
                  
                    if let oauth_token = parameters?["oauth_token"],
                       
                        let oauth_token_secret = parameters?["oauth_token_secret"],
                        let user_id = parameters?["user_nsid"],
                        let user_name = parameters?["username"]{

                        self.oauth_token = oauth_token.safeStringByRemovingPercentEncoding
                        self.oauth_token_secret = oauth_token_secret.safeStringByRemovingPercentEncoding
                        self.user.user_id = user_id.safeStringByRemovingPercentEncoding
                        self.user.user_name = user_name.safeStringByRemovingPercentEncoding
                        self.callBackWithStatus(true, "")
                    }
                    else if let fail_reason = parameters?["oauth_problem"]{
                        self.callBackWithStatus(false, "Authozization failed, reason : " + fail_reason)
                    }
                    else{
                        self.callBackWithStatus(false, "Authozization failed")
                    }
                }
            })
            
        }
    }
    
    private func callBackWithStatus(_ status:Bool, _ message:String) -> Void{
        self.oauth_token = nil
        self.oauth_token_secret = nil
        self.oauth_verifier = nil

        if (self.callBack != nil){
            self.callBack?(status, message)
        }
    }
}
