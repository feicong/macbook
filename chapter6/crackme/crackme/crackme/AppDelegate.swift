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
import Arcane

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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var edtSN: NSTextField!
    
    @IBOutlet weak var edtUserName: NSTextField!
    
    @IBOutlet weak var btnAbout: NSButton!
    @IBOutlet weak var btnClean: NSButtonCell!
    
    @IBOutlet weak var btnReg: NSButton!
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let err = NSAlert()
        err.messageText = "crackme by fei_cong@hotmail.com"
        err.addButton(withTitle: "ok")
        err.runModal()
        exit(0)
    }
    
    @IBAction func onClean(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "sn")
        
        self.window.title = "crackme unregistered"
        self.edtUserName.stringValue = ""
        self.edtSN.stringValue = ""
        
        self.edtUserName.isEnabled = true
        self.edtSN.isEnabled = true
        self.btnReg.isEnabled = true
    }
    
    @IBAction func onReg(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue;
        if username.isEmpty {
            self.edtUserName.becomeFirstResponder()
            let err = NSAlert()
            err.messageText = "user name is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        let sn = self.edtSN.stringValue;
        if sn.isEmpty {
            self.edtSN.becomeFirstResponder()
            let err = NSAlert()
            err.messageText = "serial number is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        if (sn.characters.count != 19) ||
            (sn[4...4] != "-") ||
            (sn[9...9] != "-") ||
            (sn[14...14] != "-") {
            self.edtSN.becomeFirstResponder()
            let err = NSAlert()
            err.messageText = "serial number format is wrong!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(sn.uppercased(), forKey: "sn")
        
        if true == checkSN(username, sn: sn) {
            self.window.title = "crackme registered by " + username
            
            self.edtUserName.isEnabled = false
            self.edtSN.isEnabled = false
            self.btnReg.isEnabled = false
            
            let err = NSAlert()
            err.messageText = "serial ok!"
            err.addButton(withTitle: "ok")
            err.runModal()
            
        } else {
            self.window.title = "crackme unregistered"
            self.edtUserName.isEnabled = true
            self.edtSN.isEnabled = true
            self.btnReg.isEnabled = true
            
            let err = NSAlert()
            err.messageText = "serial number error!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
        
    func checkSN(_ username: String, sn: String) -> Bool {
        let md5 = Hash.MD5(username)!
        let sha1 = Hash.SHA1(username)!
        let hmacmd5 = HMAC.MD5(username, key: "crackme!")!
        let hmacsha1 = HMAC.SHA1(username, key: "crackme!")!
        
        let v0 = md5[0...0]
        let v1 = md5[4...4]
        let v2 = md5[8...8]
        let v3 = md5[12...12]
        
        let v4 = sha1[0...0]
        let v5 = sha1[4...4]
        let v6 = sha1[8...8]
        let v7 = sha1[12...12]
        
        let v8 = hmacmd5[0...0]
        let v9 = hmacmd5[4...4]
        let v10 = hmacmd5[8...8]
        let v11 = hmacmd5[12...12]
        
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
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "username") != nil) && (defaults.object(forKey: "sn") != nil) {
            let username = defaults.object(forKey: "username") as! String
            let sn = defaults.object(forKey: "sn") as! String
            self.edtUserName.stringValue = username
            self.edtSN.stringValue = sn
            
            if true == checkSN(username, sn: sn) {
                self.window.title = "crackme registered by " + (username as String)
                self.edtUserName.stringValue = (username as String)
                self.edtSN.stringValue = (sn as String)
                
            }
        } else {
            self.window.title = "crackme unregistered"
            //self.edtUserName.stringValue = ""
            //self.edtSN.stringValue = ""
            
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

