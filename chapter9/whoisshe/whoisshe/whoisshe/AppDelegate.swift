/**
 *
 * LICENSE: GNU Affero General Public License, version 3 (AGPLv3)
 * Copyright 2016 - 2017 fei_cong@hotmail.com 67541967@qq.com
 *
 * This file is part of macbook.
 *   https://github.com/feicong/macbook
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Cocoa
import CryptoSwift

//extension String {
//    subscript (r: Range<Int>) -> String {
//        get {
//            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
//            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound)
//            
//            return self[(startIndex ..< endIndex)]
//        }
//        set {
//            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
//            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound)
//            let strRange = Range(startIndex..<endIndex)
//            self.replaceSubrange(strRange, with: newValue)
//        }
//    }
//}


extension String {
    
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex...endIndex]
        }
    }
}


//http://stackoverflow.com/questions/28144796/swift-simple-xor-encryption
extension String {
    func encodeWithXorByte(_ key: UInt8) -> String {
        return String(bytes: self.utf8.map{$0 ^ key}, encoding: String.Encoding.ascii) ?? ""
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var msg: NSTextField!
    
    @IBOutlet weak var img: NSImageView!
    
    @IBOutlet weak var edtUserName: NSTextField!
    
    @IBOutlet weak var edtSN: NSTextField!
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let msg = NSAlert()
        msg.messageText = "crackme by fei_cong@hotmail.com"
        msg.addButton(withTitle: "ok")
        msg.runModal()
        exit(0)
    }

    @IBAction func onClean(_ sender: AnyObject) {
        self.edtUserName.stringValue = ""
        self.edtSN.stringValue = ""
    }
    
    @IBAction func onLook(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue
        if username.isEmpty {
            self.edtUserName.becomeFirstResponder()
            
            let err = NSAlert()
            err.messageText = "user name is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        let sn = self.edtSN.stringValue
        if sn.isEmpty {
            self.edtSN.becomeFirstResponder()
            
            let err = NSAlert()
            err.messageText = "serial number is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        if !checkSN(username, sn : sn) {
            let err = NSAlert()
            err.messageText = "serial number error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        let mainBundle = Bundle.main
        
        let exeurl = mainBundle.executableURL!
        let filedata = try? Data(contentsOf: exeurl)
        let hash = filedata!.md5().toHexString()
        NSLog("file hash:" + hash)
        /*
        let kk : UInt8 = 95  //xor key
        let dechash = hash.encodeWithXorByte(kk)
         */
        //NSLog("dechash:" + dechash)
        let dechash = hash
        
        let whopath = mainBundle.path(forResource: "whoisshe", ofType: "dat")
        let whodata = try? Data(contentsOf: URL(fileURLWithPath: whopath!))
        if whodata == nil {
            let err = NSAlert()
            err.messageText = "read pic data error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        let whohash = whodata!.md5().toHexString()
        NSLog("data hash:" + whohash)
        let encryptedBase64 = String(data: whodata!, encoding: String.Encoding.utf8)
        if encryptedBase64 == nil {
            let err = NSAlert()
            err.messageText = "decrypt pic data error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }

        //https://www.example-code.com/swift/chacha20.asp
        //if let chacha = ChaCha20(key: dechash, iv: "whoisshe") {
        do{
            let chacha = try ChaCha20(key: dechash, iv: "whoisshe")
            let encdata = Data(base64Encoded: encryptedBase64!, options: [])
            
            let decrypted = try! chacha.decrypt((encdata!))
            let picdata = Data(bytes: decrypted)
            if let img = NSImage(data: picdata) {
                self.img.image = img
                
                self.msg.textColor = NSColor.blue
                self.msg.stringValue = "tell me.who is she?"
                return
            } else {
                NSLog("decrypt pic data error!")
            }
        } catch _ {
        }
        
        self.img.image = NSImage(named: "cry")
        self.msg.textColor = NSColor.red
        self.msg.stringValue = "She's Dead and Gone."
    }
    
    func checkSN(_ username : String, sn : String) -> Bool {
        if username.characters.count < 6 {
            return false
        }
        if (sn.isEmpty || sn.characters.count != 19) ||
            (sn[4...4] != "-") ||
            (sn[9...9] != "-") ||
            (sn[14...14] != "-") {
            return false
        }
        
        let md5 = username.md5()
        let sha1 = username.sha1()
        //let crc32 = username.crc32()
        //let crc16 = username.crc16()
        let key : [UInt8] = [UInt8]("crackme!".utf8)
        let hmacmd5data : [UInt8] = try! HMAC(key: key, variant: .md5).authenticate([UInt8](username.utf8))
        //Authenticator.hmac(key: key, variant: .md5).authenticate([UInt8](username.utf8))
        let hmacmd5 = hmacmd5data.toHexString()
        let hmacsha1data : [UInt8] = try! HMAC(key: key, variant: .sha1).authenticate([UInt8](username.utf8))
        //Authenticator.hmac(key: key, variant: .sha1).authenticate([UInt8](username.utf8))
        let hmacsha1 = hmacsha1data.toHexString()
        //let hmacmd5 = HMAC.MD5(username, key: "crackme!")!
        //let hmacsha1 = HMAC.SHA1(username, key: "crackme!")!
        
        let v0 = md5[1...1]
        let v1 = md5[5...5]
        let v2 = md5[12...12]
        let v3 = md5[13...13]
        
        let v4 = sha1[2...2]
        let v5 = sha1[6...6]
        let v6 = sha1[13...13]
        let v7 = sha1[14...14]
        
        let v8 = hmacmd5[3...3]
        let v9 = hmacmd5[7...7]
        let v10 = hmacmd5[14...14]
        let v11 = hmacmd5[15...15]
        
        let v12 = hmacsha1[0...0]
        let v13 = hmacsha1[4...4]
        let v14 = hmacsha1[8...8]
        let v15 = hmacsha1[12...12]
        
        var hash = v0 + v1 + v2 + v3
        hash += "-"
        hash += v4 + v5 + v6 + v7
        hash += "-"
        hash += v8 + v9 + v10 + v11
        hash += "-"
        hash += v12 + v13 + v14 + v15
        
        //NSLog("hash: " + hash.uppercaseString)
        
        return (sn.uppercased() == hash.uppercased())
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //self.msg.hidden = true
        self.msg.textColor = NSColor.gray
        self.edtUserName.becomeFirstResponder()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

