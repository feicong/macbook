//
//  Extension.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/11.
//  Copyright © 2015年 秦 道平. All rights reserved.

import Foundation

/**
 * Index
 */
extension Int {
    public subscript(digitIndex: Int) -> Int {
        var decimalBase = 1
        for _ in 1...digitIndex {
            decimalBase *= 10
        }
        return (self / decimalBase) % 10
    }
}

extension UInt {
    public subscript(digitIndex: Int) -> UInt {
        var decimalBase:UInt = 1
        for _ in 1...digitIndex {
            decimalBase *= 10
        }
        return (self / decimalBase) % 10
    }
}

extension UInt8 {
    public subscript(digitIndex: Int) -> UInt8 {
        var decimalBase:UInt8 = 1
        for _ in 1...digitIndex {
            decimalBase *= 10
        }
        return (self / decimalBase) % 10
    }
}
extension Data {
    public func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = 0
        for i in 0 ..< count {
            copyBytes(to: &byte, from: i..<index(after: i))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
    public var hexString : String {
        return self.hexadecimalString()
    }
    public var base64String:String {
        return self.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
    /// Array of UInt8
    public func arrayOfBytes() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
}
extension String {
    /// Array of UInt8
    public var arrayOfBytes:[UInt8] {
        let data = self.data(using: String.Encoding.utf8)!
        return data.arrayOfBytes()
    }
    public var bytes:UnsafeRawPointer{
        let data = self.data(using: String.Encoding.utf8)!
        return (data as NSData).bytes
    }
    /// Get data from hexadecimal string
    func dataFromHexadecimalString() -> Data? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        guard let regex = try? NSRegularExpression(pattern: "^[0-9a-f]*$", options: NSRegularExpression.Options.caseInsensitive) else{
            return nil
        }
        let trimmedStringLength = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
        let found = regex.firstMatch(in: trimmedString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, trimmedStringLength))
        if found == nil || found?.range.location == NSNotFound || trimmedStringLength % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        
        //        let data = NSMutableData(capacity: trimmedStringLength / 2)
        
        var data = Data(capacity: trimmedStringLength / 2)
        
        for index in trimmedString.characters.indices {
            let next_index = trimmedString.index(after: index)
            let byteString = trimmedString.substring(with: index ..< next_index)
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            //            data.append([num] as [UInt8], length: 1)
            data.append(num)
        }
        
        //        return data as Data?
        return data
    }
}
