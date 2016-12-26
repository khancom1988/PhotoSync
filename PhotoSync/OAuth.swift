//
//  OAuth.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/26/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation

class Oauth {
    
    public class func sign(_ url:String,_ consumerKey:String,_ secretKey:String, _ oauth_nonce:String, _ oauth_timestamp:String, _ oauth_callback:String, _ oauth_signature_method:String, _ method:String, _ token:String?) -> String?{
    
        if let request_token_URL = URL(string: url){
            
            let encodedTokenSecret = token?.urlEncodedString
            let encodedConsumerSecret = secretKey.urlEncodedString

            
            let encodedURL = request_token_URL.absoluteString.urlEncodedString
            let percentEncoded_oauth_callback = ("oauth_callback=" + oauth_callback.escapeStr)
            let percentageEncodedConsumerKey = ("oauth_consumer_key=" + consumerKey.escapeStr)
            let percentageEncoded_oath_nonce = ("oauth_nonce=" + oauth_nonce.escapeStr)
            let percentageEncoded_oath_signature_method = ("oauth_signature_method=" + oauth_signature_method.escapeStr)
            let percentageEncoded_oath_timestamp = ("oauth_timestamp=" + oauth_timestamp.escapeStr)
            let percentageEncoded_oauth_version = ("oauth_version=" + "1.0".escapeStr)
            
            let parameterString = percentEncoded_oauth_callback + "&" + percentageEncodedConsumerKey + "&" + percentageEncoded_oath_nonce + "&" + percentageEncoded_oath_signature_method + "&" + percentageEncoded_oath_timestamp + "&" + percentageEncoded_oauth_version
            
            
            let encodedParameterString = parameterString.urlEncodedString
            
            let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"

            var signingKey = ""
            
            if encodedTokenSecret != nil{
                signingKey = "\(encodedConsumerSecret)&\(encodedTokenSecret)"
            }
            else{
                signingKey = encodedConsumerSecret + "&"
            }
            

            let key = signingKey.data(using: .utf8)!
            let msg = signatureBaseString.data(using: .utf8)!
            
            if let sha1 = HMAC.sha1(key: key, message: msg){
                return sha1.base64EncodedString(options: [])
                
            }
        }
        return nil
    }
    
    public class func prepareParametersWithValues(_ consumerKey:String,_ secretKey:String, _ oauth_nonce:String, _ oauth_timestamp:String, _ oauth_callback:String, _ oauth_signature_method:String, _ method:String, _ token:String?) -> [String:String]?{
        /*
 
         - .0 : "Authorization"
         - .1 : "OAuth oauth_callback=\"oauth-swift%3A%2F%2Foauth-callback%2Fflickr\", oauth_consumer_key=\"61cbac5b962cbeb41853338b6c6f32bb\", oauth_nonce=\"122A359F\", oauth_signature=\"obEcCwVvwcjKeANH6q%2FuNV%2FUn8c%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1482735391\", oauth_version=\"1.0\""

    */
        
//        let oauth_nonce = Utility.getNonce()
//        let oauth_timestamp = Utility.getTimestamp()

        let percentEncoded_oauth_callback = ("oauth_callback=" + oauth_callback.escapeStr)
        let percentageEncodedConsumerKey = ("oauth_consumer_key=" + consumerKey.escapeStr)
        let percentageEncoded_oath_nonce = ("oauth_nonce=" + oauth_nonce.escapeStr)
        let percentageEncoded_oath_signature_method = ("oauth_signature_method=" + oauth_signature_method.escapeStr)
        let percentageEncoded_oath_timestamp = ("oauth_timestamp=" + oauth_timestamp.escapeStr)
        let percentageEncoded_oauth_version = ("oauth_version=" + "1.0".escapeStr)
        
        if let oauth_signature = Oauth.sign("https://www.flickr.com/services/oauth/request_token", consumerKey, secretKey, oauth_nonce, oauth_timestamp, oauth_callback, oauth_signature_method, method, nil){
            
            let parameterString = "OAuth " + percentEncoded_oauth_callback + "," + percentageEncodedConsumerKey + "," + percentageEncoded_oath_nonce + "," + percentageEncoded_oath_signature_method + "," + percentageEncoded_oath_timestamp + "," + percentageEncoded_oauth_version + "," + "oauth_signature=" + oauth_signature
            return ["Authorization":parameterString]
        
        }
        
        return nil
    }
    
}
