//
//  SHA1.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/26/16.
//  Copyright © 2016 BML. All rights reserved.
//

import Foundation

class SHA1 {
    
    private var message: [UInt8]
    
    fileprivate let h:[UInt32] = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]
    
    init(_ message: Data) {
        self.message = message.bytes
    }
    init(_ message: Array<UInt8>) {
        self.message = message
    }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ message: [UInt8], _ blockSize: Int, _ allowance: Int) -> Array<UInt8> {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (Byte with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % blockSize != (blockSize - allowance) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += Array<UInt8>(repeating: 0, count: counter)
        
        return tmpMessage
    }
    
    
    func calculate() -> Array<UInt8> {
        var tmpMessage = self.prepare(self.message, 64, 64 / 8)
        
        // hash values
        var hh = h
        
        // append message length, in a 64-bit big-endian integer. So now the message length is a multiple of 512 bits.
        tmpMessage += (self.message.count * 8).bytes(64 / 8)
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        for chunk in BytesSequence(data: tmpMessage, chunkSize: chunkSizeBytes) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15, big-endian
            // Extend the sixteen 32-bit words into eighty 32-bit words:
            var M:[UInt32] = [UInt32](repeating: 0, count: 80)
            for x in 0..<M.count {
                switch (x) {
                case 0...15:
                    
                    let memorySize = MemoryLayout<UInt32>.size
                    let start = chunk.startIndex + (x * memorySize)
                    let end = start + memorySize
                    let le = chunk[start..<end].toUInt32
                    M[x] = le.bigEndian
                    
                    break
                default:
                    M[x] = rotateLeft(M[x-3] ^ M[x-8] ^ M[x-14] ^ M[x-16], n: 1)
                    break
                }
            }
            
            var A = hh[0]
            var B = hh[1]
            var C = hh[2]
            var D = hh[3]
            var E = hh[4]
            
            // Main loop
            for j in 0...79 {
                var f: UInt32 = 0
                var k: UInt32 = 0
                
                switch (j) {
                case 0...19:
                    f = (B & C) | ((~B) & D)
                    k = 0x5A827999
                    break
                case 20...39:
                    f = B ^ C ^ D
                    k = 0x6ED9EBA1
                    break
                case 40...59:
                    f = (B & C) | (B & D) | (C & D)
                    k = 0x8F1BBCDC
                    break
                case 60...79:
                    f = B ^ C ^ D
                    k = 0xCA62C1D6
                    break
                default:
                    break
                }
                
                let temp = (rotateLeft(A,n: 5) &+ f &+ E &+ M[j] &+ k) & 0xffffffff
                E = D
                D = C
                C = rotateLeft(B, n: 30)
                B = A
                A = temp
                
            }
            
            hh[0] = (hh[0] &+ A) & 0xffffffff
            hh[1] = (hh[1] &+ B) & 0xffffffff
            hh[2] = (hh[2] &+ C) & 0xffffffff
            hh[3] = (hh[3] &+ D) & 0xffffffff
            hh[4] = (hh[4] &+ E) & 0xffffffff
        }
        
        // Produce the final hash value (big-endian) as a 160 bit number:
        var result = Array<UInt8>()
        result.reserveCapacity(hh.count / 4)
        hh.forEach {
            let item = $0.bigEndian
            result += [UInt8(item & 0xff), UInt8((item >> 8) & 0xff), UInt8((item >> 16) & 0xff), UInt8((item >> 24) & 0xff)]
        }
        
        return result
    }
    
    private func rotateLeft(_ v:UInt32, n:UInt32) -> UInt32 {
        return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
    }
}

fileprivate struct BytesSequence<D: RandomAccessCollection>: Sequence where D.Iterator.Element == UInt8, D.IndexDistance == Int, D.SubSequence.IndexDistance == Int, D.Index == Int {
    let data: D
    let chunkSize: D.IndexDistance
    
    func makeIterator() -> AnyIterator<D.SubSequence> {
        var offset = data.startIndex
        return AnyIterator {
            let end = Swift.min(self.chunkSize, self.data.count - offset)
            let result = self.data[offset..<offset + end]
            offset = offset.advanced(by: result.count)
            if !result.isEmpty {
                return result
            }
            return nil
        }
    }
    
}

open class HMAC {
    
    let key:[UInt8] = []
    
    class internal func sha1(key: Data, message: Data) -> Data? {
        let blockSize = 64
        var key = key.bytes
        let message = message.bytes
        
        if (key.count > blockSize) {
            key = SHA1(key).calculate()
        }
        else if (key.count < blockSize) { // padding
            key = key + [UInt8](repeating: 0, count: blockSize - key.count)
        }
        
        var ipad = [UInt8](repeating: 0x36, count: blockSize)
        for idx in key.indices {
            ipad[idx] = key[idx] ^ ipad[idx]
        }
        
        var opad = [UInt8](repeating: 0x5c, count: blockSize)
        for idx in key.indices {
            opad[idx] = key[idx] ^ opad[idx]
        }
        
        let ipadAndMessageHash = SHA1(ipad + message).calculate()
        let mac = SHA1(opad + ipadAndMessageHash).calculate()
        
        return Data(bytes: UnsafePointer<UInt8>(mac), count: mac.count)
        
    }
}
