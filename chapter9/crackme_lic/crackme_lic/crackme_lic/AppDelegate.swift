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
import JSONLib
import AppKit

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
    
    @IBOutlet weak var edtMachineCode: NSTextField!
    
    @IBOutlet weak var btnAbout: NSButton!
    
    @IBOutlet weak var btnReg: NSButton!
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let err = NSAlert()
        err.messageText = "crackme by fei_cong@hotmail.com"
        err.addButton(withTitle: "ok")
        err.runModal()
        exit(0)
    }
    
    struct RegInfo {
        var username = ""
        var sn = ""
        var machinecode = ""
    }
    
    @IBAction func OnClean(_ sender: AnyObject) {
        let licname = NSHomeDirectory() + "/Documents/.crackme.lic"
        unlink(licname)
        
        self.window.title = "crackme unregisterd"
        
        
        self.edtUserName.stringValue = ""
        self.edtSN.stringValue = ""
        self.edtMachineCode.stringValue = ""
        
    }
    
    @IBAction func onReg(_ sender: AnyObject) {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        let filetypelist = "lic,txt,license,dat"
        let fileTypeArray: [String] = filetypelist.components(separatedBy: ",")
        
        myFiledialog.prompt = "Open"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.resolvesAliases = true
        myFiledialog.title = "license file."
        myFiledialog.message = "open crackme's license file" + "(" + filetypelist + ")"
        myFiledialog.allowedFileTypes = fileTypeArray
        
        let ret = myFiledialog.runModal()
        if ret != NSFileHandlingPanelOKButton {
            return
        }
        let chosenfile = myFiledialog.url // Pathname of the file
        
        if (chosenfile == nil) {
            return
        }
        
        NSLog("read license file: " + chosenfile!.absoluteString)
        var str = ""
        do {
            str = try String(contentsOf: chosenfile!, encoding: String.Encoding.utf8)
        } catch {
            str = ""
        }
        if str.isEmpty {
            let err = NSAlert()
            err.messageText = "read license file error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        var reg_info : RegInfo = RegInfo()
        if checkLicense(str, reginfo: &reg_info) {
            self.window.title = "crackme registerd by " + reg_info.username
        
            self.edtUserName.stringValue = reg_info.username
            self.edtSN.stringValue = reg_info.sn
            self.edtMachineCode.stringValue = reg_info.machinecode
            
            let licname = NSHomeDirectory() + "/Documents/.crackme.lic"
            do {
                try str.write(toFile: licname, atomically: true, encoding: String.Encoding.utf8)
                NSLog("save license file ok!")
            } catch {
                NSLog("save license file error!")
            }
            
            let msg = NSAlert()
            msg.messageText = "register ok!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            self.window.title = "crackme unregisterd"
            
            
            self.edtUserName.stringValue = ""
            self.edtSN.stringValue = ""
            self.edtMachineCode.stringValue = ""
            
            let err = NSAlert()
            err.messageText = "register error!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    func checkLicense(_ str : String, reginfo : inout RegInfo) -> Bool {
        
        let str_begin = "--------------license file begin----------------\n"
        let str_end = "\n--------------license file end----------------"
        if (!str.hasPrefix(str_begin) ||
            (!str.hasSuffix(str_end))){
            return false
        }
        var rstr = str.replacingOccurrences(of: str_begin, with: "")
        rstr = rstr.replacingOccurrences(of: str_end, with: "")
        /*
         let encstr = str.aesEBCEncrypt("crackmechecklice")
         NSLog(encstr!.base64StringReturn)
         */
        rstr = rstr.replacingOccurrences(of: "\n", with: "")
        NSLog("license file content: " + rstr)
        
        let aeskey = "crackmechecklice"
        let jsonstr = rstr.aesEBCDecryptFromBase64(aeskey)
        if jsonstr == nil || jsonstr!.isEmpty {
            return false
        }
        let jsvalue = JSValue.parse(jsonstr!)
        if jsvalue.error != nil {
            return false
        }
        let json = jsvalue.value!
        if json.object == nil {
            return false
        }
        /*
        let json : JSON = [
            "username" : "xxx",
            "sn" : "xxxxxxxxx",
            "machinecode" : "xxxxxx"
        ]
         */
        let username_ = json["username"].string
        let sn_ = json["sn"].string
        let machinecode_ = json["machinecode"].string
        if (username_ == nil) || (sn_ == nil) || (machinecode_ == nil) {
            return false
        }
        let username = username_!
        let decsn = sn_!.aesEBCDecryptFromBase64(aeskey)
        if decsn == nil {
            return false
        }
        let sn = decsn!
        let machinecode = machinecode_!
        if username.isEmpty || sn.isEmpty || machinecode.isEmpty {
            return false
        }
        if username.characters.count < 6 {
            return false
        }
        if (sn.isEmpty || sn.characters.count != 19) ||
            (sn[4...4] != "-") ||
            (sn[9...9] != "-") ||
            (sn[14...14] != "-") {
            return false
        }
        
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
        if sn.uppercased() != hash.uppercased() {
            return false
        }
    
        let mach_code = getMacAddr()
        if mach_code.uppercased() != machinecode.uppercased() {
            return false
        }
    
        reginfo.username = username
        reginfo.sn = sn
        reginfo.machinecode = machinecode
        
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let licname = NSHomeDirectory() + "/Documents/.crackme.lic"
        do {
            let str = try String(contentsOfFile: licname, encoding: String.Encoding.utf8)
            var reg_info : RegInfo = RegInfo()
            if checkLicense(str, reginfo: &reg_info) {
                self.window.title = "crackme registerd by " + reg_info.username
                
                self.edtUserName.stringValue = reg_info.username
                self.edtSN.stringValue = reg_info.sn
                self.edtMachineCode.stringValue = reg_info.machinecode
                
            }
        } catch {
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    //another way http://ju.outofmemory.cn/entry/82506
    func getMacAddr() -> String {
        let theTask = Process()
        let taskOutput = Pipe()
        theTask.launchPath = "/sbin/ifconfig"
        theTask.standardOutput = taskOutput
        theTask.standardError = taskOutput
        theTask.arguments = ["en0"]
        
        theTask.launch()
        theTask.waitUntilExit()
        
        let taskData = taskOutput.fileHandleForReading.readDataToEndOfFile()
        
        if let stringResult = NSString(data: taskData, encoding: String.Encoding.utf8.rawValue) {
            if stringResult != "ifconfig: interface en0 does not exist" {
                let f = stringResult.range(of: "ether")
                if f.location != NSNotFound {
                    let sub = stringResult.substring(from: f.location + f.length)
                    let addr = sub[1...18]
                    //NSLog(addr)
                    let result = addr.replacingOccurrences(of: ":", with: "").data(using: String.Encoding.utf8)!.base64String
                    return result
                }
            }
        }
        return ""
    }

}

