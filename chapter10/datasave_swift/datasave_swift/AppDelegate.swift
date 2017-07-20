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
import KeychainSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var edtUserName: NSTextField!
    
    @IBOutlet weak var edtSN: NSTextField!
    
    @IBAction func onAbout(_ sender: AnyObject) {
        let msg = NSAlert()
        msg.messageText = "crackme by fei_cong@hotmail.com"
        msg.addButton(withTitle: "ok")
        msg.runModal()
        exit(0)
    }
    
    @IBAction func onNSUserDefaultsWrite(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue
        let sn = self.edtSN.stringValue
        
        if !username.isEmpty && !sn.isEmpty {
            let defaults = UserDefaults.standard
            defaults.set(username, forKey: "username")
            defaults.set(sn, forKey: "sn")
            defaults.synchronize()
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onNSUserDefaultsRead(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "username") != nil) && (defaults.object(forKey: "sn") != nil) {
            let username = defaults.object(forKey: "username") as! String
            let sn = defaults.object(forKey: "sn") as! String
            self.edtUserName.stringValue = username
            self.edtSN.stringValue = sn
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }

    @IBAction func onCoreDataWrite(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue
        let sn = self.edtSN.stringValue
        
        if !username.isEmpty && !sn.isEmpty {
            let fReq = NSFetchRequest<NSFetchRequestResult>(entityName: "USERINFO")
            let result = try! self.managedObjectContext.fetch(fReq)
            //remove all first
            for resultItem : Any in result {
                let userinfoItem = resultItem as! USERINFO
                self.managedObjectContext.delete(userinfoItem)
            }
            
            let newItem : USERINFO = NSEntityDescription.insertNewObject(forEntityName: "USERINFO", into: managedObjectContext) as! USERINFO
            newItem.username = username
            newItem.sn = sn
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onCoreDataRead(_ sender: AnyObject) {
        let fReq = NSFetchRequest<NSFetchRequestResult>(entityName: "USERINFO")
        let result = try! self.managedObjectContext.fetch(fReq)
        if result.count > 0 {
            for resultItem : Any in result {
                let userinfoItem = resultItem as! USERINFO
                self.edtUserName.stringValue = userinfoItem.username!
                self.edtSN.stringValue = userinfoItem.sn!
                //NSLog(userinfoItem.username!)
                //NSLog(userinfoItem.sn!)
                
                let msg = NSAlert()
                msg.messageText = "done!"
                msg.addButton(withTitle: "ok")
                msg.runModal()
                return
            }
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onPlistfileWrite(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue
        let sn = self.edtSN.stringValue
        
        if !username.isEmpty && !sn.isEmpty {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let filePath = documentsDirectory + "userinfo.plist"
            let plist = NSMutableDictionary()
            plist.setValue(username, forKey: "username")
            plist.setValue(sn, forKey: "sn")
            plist.write(toFile: filePath, atomically: true)
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onPlistfileRead(_ sender: AnyObject) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory + "userinfo.plist"
        let exists = FileManager.default.fileExists(atPath: filePath)
        if exists == false {
            let err = NSAlert()
            err.messageText = "userinfo.plist not exists!"
            err.addButton(withTitle: "ok")
            err.runModal()
            return
        }
        let plist = NSMutableDictionary(contentsOfFile: filePath)
        let username = plist!.value(forKey: "username") as? String
        let sn = plist!.value(forKey: "sn") as? String
        if username != nil && sn != nil {
            self.edtUserName.stringValue = username!
            self.edtSN.stringValue = sn!
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onKeychainWrite(_ sender: AnyObject) {
        let username = self.edtUserName.stringValue
        let sn = self.edtSN.stringValue
        
        if !username.isEmpty && !sn.isEmpty {
            let keychain = KeychainSwift()
            keychain.set(username, forKey: "username")
            keychain.set(sn, forKey: "sn")
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    @IBAction func onKeychainRead(_ sender: AnyObject) {
        let keychain = KeychainSwift()
        let username = keychain.get("username")
        let sn = keychain.get("sn")
        if username != nil && sn != nil {
            self.edtUserName.stringValue = username!
            self.edtSN.stringValue = sn!
            
            let msg = NSAlert()
            msg.messageText = "done!"
            msg.addButton(withTitle: "ok")
            msg.runModal()
        } else {
            let err = NSAlert()
            err.messageText = "username or serinal is empty!"
            err.addButton(withTitle: "ok")
            err.runModal()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //window.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "fc.datasave_swift" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("fc.datasave_swift")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "datasave_swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try (self.applicationDocumentsDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("CocoaAppCD.storedata")
            do {
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            if failError != nil {
                dict[NSUnderlyingErrorKey] = failError
            }
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.shared().presentError(error)
            abort()
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

