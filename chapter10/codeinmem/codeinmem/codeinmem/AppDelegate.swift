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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var edtSN: NSTextField!

    @IBAction func onAbout(_ sender: AnyObject) {
        //window.level =  Int(CGWindowLevelForKey(.BaseWindowLevelKey))
        let msg = NSAlert()
        msg.messageText = "crackme by fei_cong@hotmail.com"
        msg.addButton(withTitle: "ok")
        msg.runModal()
        exit(0)
    }
    
    @IBAction func onCheck(_ sender: AnyObject) {
        do {
            let rabbit = try Rabbit(key: "codeinmemory!@#$", iv: "code.mem")
            let encdata = Data(base64Encoded: "Styk1JFdcBc=", options: [])
            //bWFjYm9vayE=
            /*
             let decrypted = try! rabbit.encrypt((encdata!.arrayOfBytes()))
             let str0 = decrypted.toBase64()
             NSLog(str0!)
             */
            
            let decrypted = rabbit.decrypt((encdata!))
            var mysn = String(bytes: decrypted, encoding: String.Encoding.utf8)!
            mysn += getMacAddr()
            //NSLog(mysn)
            let sn_ = self.edtSN.stringValue
            if sn_.isEmpty || sn_.characters.count < 6 {
                self.edtSN.becomeFirstResponder()
                let err = NSAlert()
                err.messageText = "serial number format error!"
                err.addButton(withTitle: "ok")
                err.runModal()
            }
            
            if sn_ != mysn {
                //mysn = ""
                let err = NSAlert()
                err.messageText = "serial number error!"
                err.addButton(withTitle: "ok")
                err.runModal()
            } else {
                let msg = NSAlert()
                msg.messageText = "serial number ok!"
                msg.addButton(withTitle: "ok")
                msg.runModal()
            }
        } catch _ {
            let err = NSAlert()
            err.messageText = "init data error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            exit(-1)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //window.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        
        //window.level =  Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
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
                    let result = addr.replacingOccurrences(of: ":", with: "")
                    return result//!.toHexString()
                }
            }
        }
        return ""
    }
    
}

