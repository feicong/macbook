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
import JSONLib
import CryptoSwift
import Alamofire

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

    @IBOutlet weak var edtUserName: NSTextField!
    
    @IBOutlet weak var edtSN: NSTextField!
    
    @IBOutlet weak var edtContent: NSTextField!

    @IBOutlet weak var status: NSTextField!
    
    @IBOutlet weak var btnRead: NSButton!
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let msg = NSAlert()
        msg.messageText = "crackme by fei_cong@hotmail.com"
        msg.addButton(withTitle: "ok")
        msg.runModal()
        exit(0)
    }
    
    @IBAction func onRead(_ sender: AnyObject) {
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
        let bundleid = mainBundle.bundleIdentifier!
        NSLog("file hash:" + hash)
        NSLog("bundleid:" + bundleid)
        
        
        self.status.textColor = NSColor.black
        self.edtContent.stringValue = ""
        self.status.stringValue = "reading..."
        usleep(100)
        
        let url = URL(string: "https://raw.githubusercontent.com/feicong/macbook/master/chapter9/crackme_net/config.json")
        let mutableURLRequest = NSMutableURLRequest(url: url!)
        mutableURLRequest.httpMethod = "GET"
        
        //mutableURLRequest.HTTPBody = self.createJson()
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        Alamofire.request(mutableURLRequest as! URLRequestConvertible).validate().responseString{
        /*
        Alamofire.request(.GET, "https://raw.githubusercontent.com/feicong/macbook/master/chapter9/crackme_net/config.json", parameters: [:])
            .responseString*/
             (response) in
                switch response.result {
                case .success:
                    if let ret = String.init(data: response.data!, encoding: String.Encoding.utf8) {
                        //self.edtContent.stringValue = ret
                        //NSLog(ret)
                        
                        let jsvalue = JSValue.parse(ret)
                        if jsvalue.error != nil {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = jsvalue.error!.description
                            return
                        }
                        let json = jsvalue.value!
                        if json.object == nil {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "parse response error!"
                            return
                        }
                        
                        let status_ = json["status"].string
                        if status_ != "0" {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "no service!"
                            return
                        }
                        let id_ = json["id"].string
                        let filehash_ = json["filehash"].string
                        if (id_?.uppercased() != bundleid.uppercased()) || (filehash_?.uppercased() != hash.uppercased()) {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "file damaged!"
                            return
                        }
                        
                        self.getData()
                    } else {
                        self.status.textColor = NSColor.red
                        self.status.stringValue = "read error!" + " code: " + (response.response?.statusCode.description)!
                    }
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    self.status.textColor = NSColor.red
                    self.status.stringValue = "read error!" + " description: " + error.localizedDescription
            }
                
        }
    }
    
    func getData() {
        let url = URL(string: "https://raw.githubusercontent.com/feicong/macbook/master/chapter9/crackme_net/data.json")
        let mutableURLRequest = NSMutableURLRequest(url: url!)
        mutableURLRequest.httpMethod = "GET"
        
        //mutableURLRequest.HTTPBody = self.createJson()
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        Alamofire.request(mutableURLRequest as! URLRequestConvertible).validate().responseString{
        /*Alamofire.request(.GET, "https://raw.githubusercontent.com/feicong/macbook/master/chapter9/crackme_net/data.json", parameters: [:])
            .responseString {  */
                (response) in
                switch response.result {
                case .success:
                    if let ret = String.init(data: response.data!, encoding: String.Encoding.utf8) {
                        //self.edtContent.stringValue = ret
                        //NSLog(ret)
                        let jsvalue = JSValue.parse(ret)
                        if jsvalue.error != nil {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = jsvalue.error!.description
                            return
                        }
                        
                        let json = jsvalue.value!
                        if json.object == nil {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "parse response error!"
                            return
                        }
                        
                        let status = json["status"].string
                        if status != "0" {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "no service!"
                            return
                        }
                        if let data = json["data"].string {
                            self.edtContent.stringValue = data
                            
                            self.status.textColor = NSColor.green
                            self.status.stringValue = "read ok!"
                        } else {
                            self.status.textColor = NSColor.red
                            self.status.stringValue = "get data error!"
                        }
                    }
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    self.status.textColor = NSColor.red
                    self.status.stringValue = "read error!" + " description: " + error.localizedDescription
                }
        }
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
        let key : [UInt8] = [UInt8]("crackme!".utf8)
        let hmacmd5data : [UInt8] = try! HMAC(key: key, variant: .md5).authenticate([UInt8](username.utf8))
        //Authenticator.hmac(key: key, variant: .md5).authenticate([UInt8](username.utf8))
        let hmacmd5 = hmacmd5data.toHexString()
        let hmacsha1data : [UInt8] = try! HMAC(key: key, variant: .sha1).authenticate([UInt8](username.utf8))
        //Authenticator.hmac(key: key, variant: .sha1).authenticate([UInt8](username.utf8))
        let hmacsha1 = hmacsha1data.toHexString()
        
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
        self.edtUserName.becomeFirstResponder()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

