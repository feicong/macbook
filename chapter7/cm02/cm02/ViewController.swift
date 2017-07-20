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

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var macSerialNumber: String {
            let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
            if (platformExpert == 0) {
                return "Unknown"
            }
            
            let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString!, kCFAllocatorDefault, 0)
            
            return serialNumberAsCFString!.takeUnretainedValue() as! String
            
        }
        
        machineCode.stringValue = macSerialNumber;
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func showDialog(info: String, text: String) -> Void {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = info
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.informational
        myPopup.addButton(withTitle: "OK")
        myPopup.runModal()
    }
    
    @IBAction func onCheckBtnClicked(_ sender: AnyObject) {
        if (keyCode.stringValue == (machineCode.stringValue.data(using: String.Encoding.utf8)?.base64EncodedString(options: .lineLength76Characters))!) {
            showDialog(info: "注册成功", text: "恭喜你，注册成功！！！")
        } else {
            showDialog(info: "注册失败", text: "注册失败，请重试。")
        }
    }

    @IBOutlet weak var machineCode: NSTextField!

    @IBOutlet weak var keyCode: NSTextField!
}

