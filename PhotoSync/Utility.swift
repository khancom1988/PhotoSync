//
//  Utility.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation

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
    
    public class func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    public class func signatureBaseString(consumerKey:String,secretKey:String,token:String?, oauth_nonce:String, oauth_timestamp:String) -> String{
        
        let oauth_signature_method = "HMAC-SHA1"
        
        let percentEncodedBaseUrl = "https://www.flickr.com/services/oauth/request_token".escapeStr
        let percentEncoded_oauth_callback = ("oauth_callback=oauth-photosync://oauth-callback/flickr").escapeStr.urlEncodedString
        let percentageEncodedConsumerKey = ("&oauth_consumer_key=" + consumerKey).escapeStr.urlEncodedString
        let percentageEncoded_oath_nonce = ("&oauth_nonce=" + oauth_nonce).escapeStr.urlEncodedString
        let percentageEncoded_oath_signature_method = ("&oauth_signature_method=" + oauth_signature_method).escapeStr.urlEncodedString
        let percentageEncoded_oath_timestamp = ("&oauth_timestamp=" + oauth_timestamp).escapeStr.urlEncodedString
        let percentageEncoded_oauth_version = ("&oauth_version=" + "1.0").escapeStr.urlEncodedString

        let signatureBaseString = "GET&" + percentEncodedBaseUrl + "&" + percentEncoded_oauth_callback + percentageEncodedConsumerKey + percentageEncoded_oath_nonce + percentageEncoded_oath_signature_method + percentageEncoded_oath_timestamp + percentageEncoded_oauth_version
        
        let signingKey = secretKey + "&"
        
        let msg = signatureBaseString.data(using: .utf8)!
        let key = signingKey.data(using: .utf8)!

        if let sha1 = HMAC.sha1(key: key, message: msg){
            return sha1.base64EncodedString(options: [])

        }
        else{
            return ""
        }
//        return baseString.hmac(algorithm: CryptoAlgorithm.SHA1, key: signing_key)
    }
    
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
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
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

extension Data {
    
    internal init(data: Data) {
        self.init()
        self.append(data)
    }
    
    internal mutating func append(_ bytes: [UInt8]) {
        self.append(bytes, count: bytes.count)
    }
    internal mutating func append(_ byte: UInt8) {
        append([byte])
    }
    internal mutating func append(_ byte: UInt16) {
        append(UInt8(byte >> 0 & 0xFF))
        append(UInt8(byte >> 8 & 0xFF))
    }
    internal  mutating func append(_ byte: UInt32) {
        append(UInt16(byte >>  0 & 0xFFFF))
        append(UInt16(byte >> 16 & 0xFFFF))
    }
    internal mutating func append(_  byte: UInt64) {
        append(UInt32(byte >>  0 & 0xFFFFFFFF))
        append(UInt32(byte >> 32 & 0xFFFFFFFF))
    }
    
    var bytes: [UInt8] {
        return Array(self)
    }
    
}

extension Int {
    public func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

fileprivate func arrayOfBytes<T>(_ value:T, length:Int? = nil) -> [UInt8] {
    let totalBytes = length ?? MemoryLayout<T>.size
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
    var bytes = [UInt8](repeating: 0, count: totalBytes)
    for j in 0..<min(MemoryLayout<T>.size,totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    
    valuePointer.deinitialize()
    valuePointer.deallocate(capacity: 1)
    
    return bytes
}

extension Collection where Self.Iterator.Element == UInt8, Self.Index == Int {
    
    var toUInt32: UInt32 {
        assert(self.count > 3)
        // XXX optimize do the job only for the first one...
        return toUInt32Array()[0]
    }
    
    func toUInt32Array() -> Array<UInt32> {
        var result = Array<UInt32>()
        result.reserveCapacity(16)
        for idx in stride(from: self.startIndex, to: self.endIndex, by: MemoryLayout<UInt32>.size) {
            var val: UInt32 = 0
            val |= self.count > 3 ? UInt32(self[idx.advanced(by: 3)]) << 24 : 0
            val |= self.count > 2 ? UInt32(self[idx.advanced(by: 2)]) << 16 : 0
            val |= self.count > 1 ? UInt32(self[idx.advanced(by: 1)]) << 8  : 0
            val |= self.count > 0 ? UInt32(self[idx]) : 0
            result.append(val)
        }
        
        return result
    }
}
