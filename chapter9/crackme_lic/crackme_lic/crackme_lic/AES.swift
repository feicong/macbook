//
//  AES.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/11.
//  Copyright © 2015年 秦 道平. All rights reserved.
//
//  key 满足 16(AES128)/24(AES192)/32(AES256) 位
//  只支持 ECB/CBC 模式， cbc 模式必须要 IV,只支持 PKCS7Padding
//  raw 的长度必须大于3个字符
import Foundation
import CCommonCrypto


extension Data {
    // MARK: cbc
    fileprivate func aesCBC(_ operation:CCOperation,key:String, iv:String? = nil) -> Data? {
        guard [16,24,32].contains(key.lengthOfBytes(using: String.Encoding.utf8)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_length = Swift.max(input_bytes.count * 2, 16)
        var encrypt_bytes = [UInt8](repeating: 0,
                                    count: encrypt_length)
        
        let iv_bytes = (iv != nil) ? iv?.bytes : nil
        let status = CCCrypt(UInt32(operation),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key_bytes,
                             key.lengthOfBytes(using: String.Encoding.utf8),
                             iv_bytes,
                             input_bytes,
                             input_bytes.count,
                             &encrypt_bytes,
                             encrypt_bytes.count,
                             &encrypt_length)
        if status == Int32(kCCSuccess) {
            return Data(bytes: UnsafePointer<UInt8>(encrypt_bytes), count: encrypt_length)
        }
        return nil
    }
    /// Encrypt data in CBC Mode, iv will be filled with zero if not specificed
    public func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        return aesCBC(UInt32(kCCEncrypt), key: key, iv: iv)
    }
    /// Decrypt data in CBC Mode ,iv will be filled with zero if not specificed
    public func aesCBCDecrypt(_ key:String,iv:String? = nil)->Data?{
        return aesCBC(UInt32(kCCDecrypt), key: key, iv: iv)
    }
    // MARK: ecb
    fileprivate func aesEBC(_ operation:CCOperation, key:String) -> Data? {
        guard [16,24,32].contains(key.lengthOfBytes(using: String.Encoding.utf8)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_length = Swift.max(input_bytes.count * 2, 16)
        var encrypt_bytes = [UInt8](repeating: 0,
                                    count: encrypt_length)
        let status = CCCrypt(UInt32(operation),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode),
                             key_bytes,
                             key.lengthOfBytes(using: String.Encoding.utf8),
                             nil,
                             input_bytes,
                             input_bytes.count,
                             &encrypt_bytes,
                             encrypt_bytes.count,
                             &encrypt_length)
        if status == Int32(kCCSuccess) {
            return Data(bytes: UnsafePointer<UInt8>(encrypt_bytes), count: encrypt_length)
        }
        return nil
    }
    /// Encrypt data in EBC Mode
    public func aesEBCEncrypt(_ key:String) -> Data? {
        return aesEBC(UInt32(kCCEncrypt), key: key)
        
    }
    /// Decrypt data in EBC Mode
    public func aesEBCDecrypt(_ key:String) -> Data? {
        return aesEBC(UInt32(kCCDecrypt), key: key)
    }
}
extension String{
    // MARK: cbc
    /// Encrypt string in CBC mode, iv will be filled with Zero if not specificed
    public func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        let data = self.data(using: String.Encoding.utf8)
        //        print(data!.hexString)
        return data?.aesCBCEncrypt(key, iv: iv)
    }
    /// Decrypt a hexadecimal string in CBC Mode, iv will be filled with Zero if not specificed
    public func aesCBCDecryptFromHex(_ key:String,iv:String? = nil) ->String?{
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        //        print(raw_data.hexString)
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    /// Decrypt a base64 string in CBC mode, iv will be filled with Zero if not specificed
    public func aesCBCDecryptFromBase64(_ key:String, iv:String? = nil) ->String? {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions())
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    // MARK: ebc
    /// Encrypt a string in EBC Mode
    public func aesEBCEncrypt(_ key:String) -> Data? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.aesEBCEncrypt(key)
    }
    /// Decrypt a hexadecimal string in EBC Mode
    public func aesEBCDecryptFromHex(_ key:String) -> String? {
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesEBCDecrypt(key) else {
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    /// Decrypt a base64 string in EBC Mode
    public func aesEBCDecryptFromBase64(_ key:String) -> String? {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions())
        guard let raw_data = data?.aesEBCDecrypt(key) else {
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
}
