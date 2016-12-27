//
//  FlickrObj.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/27/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation
import UIKit


public enum ImageType: String {
    case eThumbnail = "s"
    case eOrginal = "b"
}

class FlickrObj: NSObject {
    var photoInfo:NSOrderedSet = NSOrderedSet()
    var stat:String?
}

class PhotoInfo:NSObject{
    
    var id:String?
    var owner:String?
    var secret:String?
    var server:String?
    var farm:NSNumber?
    var title:String?
    var ispublic:NSNumber?
    var isfriend:NSNumber?
    var isfamily:NSNumber?
    
    var thumbnail : UIImage?
    var orginalImage : UIImage?

    func updateWithValues(values:[String:AnyObject]) -> Void {
        let variableNames = Mirror(reflecting: self).children.flatMap { $0.label }
        for (key,value) in values {
            if variableNames.contains(key){
                self.setValue(value, forKey: key)
            }
        }
    }
    
    func flickrImageURL(_ size:ImageType = ImageType.eThumbnail) -> URL? {
        
        guard let farm = self.farm, let server = self.server, let id = self.id, let secret = self.secret  else {
            return nil
        }
        
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }

    
    func downLoadPhotoWithSize(size:ImageType = ImageType.eThumbnail, callBack callback:@escaping (_ image:UIImage?,_ error:NSError?, _ photoInfo:PhotoInfo) -> Void) -> Void{
        
        if let url = self.flickrImageURL(size), Oauth.default.authorized == true {
           
            HttpClient.requestWith(url: url.absoluteString, completionHandler:{(error,data) -> Void in
                if let imageData = data, let image = UIImage(data: imageData) {
                    switch size{
                    case .eOrginal:
                        self.orginalImage = image
                        break
                    case .eThumbnail:
                        self.thumbnail = image
                        break
                    }
                    callback(image, nil, self)
                }
                else{
                    let APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Image not found"])
                    callback(nil, APIError, self)
                }
            })
        }
        else{
            let APIError = NSError(domain: "FlickrError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Bad Url"])
            callback(nil, APIError, self)

        }
    }

}

class PageInfo:NSObject{
   
    var pageNumber = 1
    var pageSize = 20
    
    init(pageNumber:Int , pageSize:Int){
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
}
