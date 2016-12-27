//
//  Flickr.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/27/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation
/*
 https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=c9dfe5e7dd2402ad645894373cd611f6&user_id=78616652%40N04&per_page=20&page=1&format=json&nojsoncallback=1
*/
class Flickr: NSObject {
    
    public class func getPublicPhotos(_ oauth:Oauth, _ pageInfo:PageInfo, callback:@escaping (_ error:NSError?,_ results:[PhotoInfo]?) -> Void) ->Void{
        
        var mutableUrlString = "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos"
        mutableUrlString.append("&api_key=" + oauth.consumer_key!)
        mutableUrlString.append("&user_id=" + oauth.user_ID!)
        mutableUrlString.append("&per_page=" + String(pageInfo.pageSize))
        mutableUrlString.append("&page=" + String(pageInfo.pageNumber))
        mutableUrlString.append("&format=json&nojsoncallback=1")

        HttpClient.requestWith(url: mutableUrlString, completionHandler:{ (error,data) -> Void in
            
            if error == nil{
                
                if let response = data{
                    
                    do{
                        guard let resultsDictionary = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],let stat = resultsDictionary["stat"] as? String else{
                            let APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                            callback(APIError, nil)
                            return
                        }
                        var result:[PhotoInfo]? = nil
                        var APIError:NSError? = nil
                        if stat == "ok"{
                            if let photos = resultsDictionary["photos"] as? [String:AnyObject]{
                                
                                if let photoItems = photos["photo"] as? [AnyObject]{
                                    result = []
                                    for photo in photoItems{
                                        let photoInfo = PhotoInfo()
                                        photoInfo.updateWithValues(values: photo as! [String : AnyObject])
                                        result?.append(photoInfo)
                                    }
                                }
                                else{
                                    APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"No photos found"])
                                }
                            }
                        }
                        else{
                            APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        }
                        callback(APIError, result)
                    }
                    catch _ {
                        let APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        callback(APIError, nil)
                        return
                    }
                }
                else{
                    let APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    callback(APIError, nil)
                 }
                
            }
            else{
                callback(error as NSError?, nil)
            }
            
        })
    }
}
