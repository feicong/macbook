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
import AudioToolbox


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var edtFileHash: NSTextField!
    
    @IBOutlet weak var edtContent: NSTextField!
    
    @IBAction func onCalcHash(_ sender: AnyObject) {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        let filetypelist = ""
        let fileTypeArray: [String] = filetypelist.components(separatedBy: ",")
        
        myFiledialog.prompt = "Open"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.resolvesAliases = true
        myFiledialog.title = "pic file."
        myFiledialog.message = "open whoisshe executable file" + "(" + filetypelist + ")"
        myFiledialog.allowedFileTypes = fileTypeArray
        
        let ret = myFiledialog.runModal()
        if ret != NSFileHandlingPanelOKButton {
            return
        }
        let chosenfile = myFiledialog.url // Pathname of the file
        
        if (chosenfile == nil) {
            return
        }
        
        NSLog("file path: " + chosenfile!.absoluteString)
        let filedata = try? Data(contentsOf: chosenfile!)
        if filedata == nil {
            let err = NSAlert()
            err.messageText = "read file data error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        self.edtFileHash.stringValue = filedata!.md5().toHexString()
    }
    
    @IBAction func onPicOpen(_ sender: AnyObject) {
        let filehash = self.edtFileHash.stringValue
        if filehash.isEmpty {
            self.edtFileHash.becomeFirstResponder()
            
            let err = NSAlert()
            err.messageText = "file hash is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        let filetypelist = "jpg,png,jpeg,bmp"
        let fileTypeArray: [String] = filetypelist.components(separatedBy: ",")
        
        myFiledialog.prompt = "Open"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.resolvesAliases = true
        myFiledialog.title = "pic file."
        myFiledialog.message = "open whoisshe's pic file" + "(" + filetypelist + ")"
        myFiledialog.allowedFileTypes = fileTypeArray
        
        let ret = myFiledialog.runModal()
        if ret != NSFileHandlingPanelOKButton {
            return
        }
        let chosenfile = myFiledialog.url // Pathname of the file
        
        if (chosenfile == nil) {
            return
        }
        
        NSLog("file path: " + chosenfile!.absoluteString)
        
        let whodata = try? Data(contentsOf: chosenfile!)
        if whodata == nil {
            let err = NSAlert()
            err.messageText = "read pic data error!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        //https://www.example-code.com/swift/chacha20.asp
        do {
                let chacha = try ChaCha20(key: filehash, iv: "whoisshe")
            
            let encrypted = try! chacha.encrypt(whodata!).toBase64()
            
            self.edtContent.stringValue = encrypted!
            //NSLog(encrypted!)
            
            let soundID = SystemSoundID(kSystemSoundID_UserPreferredAlert)
            AudioServicesPlaySystemSound(soundID)
            //AudioServicesPlayAlertSound(soundID)
            
            /*
             let msg = NSAlert()
             msg.messageText = "done!"
             msg.addButtonWithTitle("ok")
             msg.runModal()
             */

        } catch _ {}
    }
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let err = NSAlert()
        err.messageText = "app by fei_cong@hotmail.com"
        err.addButton(withTitle: "ok")
        err.runModal()
        exit(0)
    }

    @IBAction func onClean(_ sender: AnyObject) {
        self.edtFileHash.stringValue = ""
        self.edtContent.stringValue = ""
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        let content = self.edtContent.stringValue
        if content.isEmpty {
            self.edtContent.becomeFirstResponder()
            
            let err = NSAlert()
            err.messageText = "pic save path is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        
        let fileSavePanel = NSSavePanel()
        fileSavePanel.title = "Save File"
        fileSavePanel.nameFieldStringValue = "whoisshe.dat"
        fileSavePanel.canCreateDirectories = true
        fileSavePanel.showsResizeIndicator = true
        fileSavePanel.allowsOtherFileTypes = true
        fileSavePanel.isExtensionHidden = false
        fileSavePanel.nameFieldStringValue = ""
        /*
        fileSavePanel.beginSheetModalForWindow(self.window) { (ret) in
            if ret == NSFileHandlingPanelOKButton {
                if let selectURL = fileSavePanel.URL {
                    do {
                        try content.writeToURL(selectURL, atomically: true, encoding: NSUTF8StringEncoding)
                        
                        let msg = NSAlert()
                        msg.messageText = "done!"
                        msg.addButtonWithTitle("ok")
                        msg.runModal()
                    } catch {
                        let err = NSAlert()
                        err.messageText = "save file error!"
                        err.addButtonWithTitle("ok")
                        err.runModal()
                    }
                }
            }
        }
        */
        let ret = fileSavePanel.runModal()
        if (ret != NSFileHandlingPanelOKButton) {
            return
        }
        
        if let selectURL = fileSavePanel.url {
            do {
                try content.write(to: selectURL, atomically: true, encoding: String.Encoding.utf8)
                
                let msg = NSAlert()
                msg.messageText = "done!"
                msg.addButton(withTitle: "ok")
                msg.runModal()
            } catch {
                let err = NSAlert()
                err.messageText = "save file error!"
                err.addButton(withTitle: "ok")
                err.runModal()
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.edtFileHash.becomeFirstResponder()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    
}

