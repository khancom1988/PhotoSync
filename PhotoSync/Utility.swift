//
//  Utility.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation
import UIKit

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

class Utility{
    
    public class func getUUId() -> String {
        return NSUUID().uuidString.lowercased()
    }
    
    public class func getNonce() -> String{
        let uuidString = UUID().uuidString
        return uuidString.substring(to: 8)
    }

    public class func getTimestamp() -> String{
        let timestamp = String(Int64(Date().timeIntervalSince1970))
        return timestamp
    }
    
    public class func themeColor() -> UIColor{
        return UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
    }
    
    public class func calculatePageNumberFor(pageSize:Int, withArrayCount count:Int) -> Int {
        return (abs(count/pageSize) + 1)
    }

}

extension String {
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let data = NSData(bytesNoCopy: result, length: digestLen)

        result.deinitialize()
        
        return data.base64EncodedString(options: [])
    }
    
    var escapeStr:String{
        get{
            let raw: NSString = self as NSString
            let str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,raw,"[]." as CFString!,":/?&=;+!@#$()',*" as CFString!,CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
            return str as! String
        }
    }
    
    var urlEncodedString: String {
        let customAllowedSet =  CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString!
    }

    
    func substring(to offset: String.IndexDistance) -> String{
        return self.substring(to: self.index(self.startIndex, offsetBy: offset))
    }
    
    func dictionaryBySplitting(_ elementSeparator: String, keyValueSeparator: String) -> [String: String] {
        
        var string = self
        if(hasPrefix(elementSeparator)) {
            string = String(characters.dropFirst(1))
        }
        
        var parameters = Dictionary<String, String>()
        
        let scanner = Scanner(string: string)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo(keyValueSeparator, into: &key)
            scanner.scanString(keyValueSeparator, into: nil)
            
            value = nil
            scanner.scanUpTo(elementSeparator, into: &value)
            scanner.scanString(elementSeparator, into: nil)
            
            if let key = key as? String, let value = value as? String {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        return parameters
    }

    var safeStringByRemovingPercentEncoding: String {
        return self.removingPercentEncoding ?? self
    }

}

