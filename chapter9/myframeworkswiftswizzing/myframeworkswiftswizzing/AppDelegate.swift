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
//  source from:https://www.uraimo.com/2015/10/23/effective-method-swizzling-with-swift/

import Cocoa
import myframeworkswift

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

extension mylib {
    override open static func initialize() {
        
//        struct Static {
//            static var token: Int = 0;
//        }
//        
//        dispatch_once(&Static.token) {
//            let originalSelector = #selector(mylib.hello)
//            let swizzledSelector = #selector(mylib.myhello)
//            
//            let originalMethod = class_getInstanceMethod(self, originalSelector)
//            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
//            
//            method_exchangeImplementations(originalMethod, swizzledMethod)
//        }
        
        DispatchQueue.once(token: "replace.hello") {
            let originalSelector = #selector(mylib.hello)
            let swizzledSelector = #selector(mylib.myhello)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    dynamic func myhello() {
        self.myhello()
        NSLog("hello swift method swizzing.");
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let lib : mylib = mylib()
        lib.hello()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

