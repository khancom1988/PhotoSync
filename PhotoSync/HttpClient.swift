//
//  HttpClient.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

public enum RequestType: Int {
    case eGET = 0
    case ePUT
    case ePOST
    case eDELETE
    
    var description:String{
        switch self {
        case .eGET:
            return "GET"
        case .ePUT:
            return "PUT"
        case .ePOST:
            return "POST"
        case .eDELETE:
            return "DELETE"

        }
    }
}

public enum MyError: Error {
    case badURL
    var localizedDescription:String?{
        switch self {
        case .badURL:
            return "Bad URL"
        }
    }
}

class HttpClient: NSObject {

    public class func requestWith(url: String, requestType:RequestType = .eGET,  parameters:[String:AnyObject?]? = nil, headers:[String:String]? = nil, completionHandler:@escaping (_ error:Error?,_ result:Data?) -> Void){
        
        guard let serverUrl = URL(string: url) else {
            completionHandler(MyError.badURL, nil)
            return
        }
        
        var urlRequest = URLRequest(url: serverUrl)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if requestType == .ePOST{
            if let requestHeaders = headers{
                for (key,value) in requestHeaders{
                    urlRequest.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
       
        urlRequest.httpMethod = requestType.description
        
        Connection().connnectWithUrl(urlRequest: urlRequest, completionHandler:{ (error,data) -> Void in
            completionHandler(error, data)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
}

fileprivate class Connection: NSObject{
    
    private var dataTask:URLSessionDataTask?
    private var uploadTask:URLSessionUploadTask?
    private var completionHandler:((Error?,Data?)-> Void)?
    
    fileprivate override init() {
        
        
    }
    
    func connnectWithUrl(urlRequest:URLRequest, completionHandler:@escaping(_ error:Error?, _ data:Data?) -> Void) -> Void {
        
        self.completionHandler = completionHandler

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            if let completionHandler = self.completionHandler{
                completionHandler(error, data)
            }
        })
        dataTask?.resume()

    }
    
    func cancleTask() -> Void {
        dataTask?.cancel()
    }
    
}
