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

#import <Foundation/Foundation.h>


BOOL checkCodeSign(NSString *exefilePath) {
    SecStaticCodeRef ref = NULL;
    NSURL *url = [NSURL URLWithString: exefilePath];
    OSStatus status = SecStaticCodeCreateWithPath((__bridge CFURLRef)url, kSecCSDefaultFlags, &ref);
    if (ref == NULL) {
        NSLog(@"SecStaticCodeRef is nil");
        return FALSE;
    }
    if (status != noErr) {
        NSLog(@"SecStaticCodeCreateWithPath function return error");
        return FALSE;
    } else {
        //NSLog(@"the SecStaticCodeRef is [%@]", ref);
    }
    
    CFDictionaryRef dictRef = nil;
    status = SecCodeCopySigningInformation(ref, kSecCSSigningInformation, &dictRef);
    if (status != noErr) {
        NSLog(@"SecCodeCopySigningInformation function return error");
        return FALSE;
    }
    if (nil == dictRef) {
        NSLog(@"dictRef is nil");
        return FALSE;
    } else {
        //NSLog(@"the dict is [%@]", dictRef);
    }
    
    SecRequirementRef req = NULL;
    status = SecRequirementCreateWithString(
                                            CFSTR("anchor apple or anchor apple generic"),
                                            kSecCSDefaultFlags, &req);
    if (status != noErr) {
        NSLog(@"SecRequirementCreateWithString function return error");
        return FALSE;
    }
    if (req == NULL) {
        NSLog(@"req is nil!");
        return FALSE;
    } else {
        //NSLog(@"the req is [%@]", req);
    }
    
    //status = SecStaticCodeCheckValidityWithErrors(ref, kSecCSCheckAllArchitectures, req, NULL);
    status = SecStaticCodeCheckValidity(ref, kSecCSCheckAllArchitectures, req);
    CFRelease(ref);
    CFRelease(req);
    switch (status) {
        case errSecSuccess:
            NSLog(@"signature OK");
            return TRUE;
            break;
        case errSecCSUnsigned:
            NSLog(@"errSecCSUnsigned!");
            break;
        case errSecCSSignatureFailed:
        case errSecCSSignatureInvalid:
            NSLog(@"signature error");
            break;
        case errSecCSSignatureNotVerifiable:
            NSLog(@"signature not verifiable");
            break;
        case errSecCSSignatureUnsupported:
            NSLog(@"signature unsupported");
            break;
        default:
            NSLog(@"[%@]", status);
            NSLog(@"signature state error");
            break;
    }
    
    return FALSE;
    /*
     status = SecStaticCodeCheckValidity(ref, kSecCSCheckAllArchitectures, req);
     CFRelease(ref);
     CFRelease(req);
     if (status != noErr) {
     NSLog(@"SecStaticCodeCheckValidity function return error");
     return FALSE;
     } else {
     NSLog(@"signature OK!");
     }
     
     return TRUE;
     */
}

BOOL checkSandbox(NSString *exefilePath) {
    BOOL isSandboxed = NO;
    if (checkCodeSign(exefilePath)) {
        
        SecStaticCodeRef ref = NULL;
        NSURL *url = [NSURL URLWithString: exefilePath];
        OSStatus status = SecStaticCodeCreateWithPath((__bridge CFURLRef)url, kSecCSDefaultFlags, &ref);
        if (ref == NULL) {
            NSLog(@"SecStaticCodeRef is nil");
            return FALSE;
        }
        if (status != noErr) {
            NSLog(@"SecStaticCodeCreateWithPath function return error");
            return FALSE;
        } else {
            //NSLog(@"the SecStaticCodeRef is [%@]", ref);
        }
        
        static SecRequirementRef req = NULL;
        SecRequirementCreateWithString(
            CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"),
            kSecCSDefaultFlags, &req);
        if (req) {
            OSStatus codeCheckResult = SecStaticCodeCheckValidityWithErrors(ref, kSecCSBasicValidateOnly, req, NULL);
            if (codeCheckResult == errSecSuccess) {
                isSandboxed = YES;
            }
            CFRelease(req);
        }
        CFRelease(ref);
    }
    
    return isSandboxed;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            NSLog(@"usage: checksandbox file:///Applications/xxx.app/Contents/MacOS/xxx");
            return 0;
        }
        //NSString *str = @"file:///Applications/Thunder.app/Contents/MacOS/Thunder";
        NSString *str = [NSString stringWithCString:argv[1] encoding:(NSUTF8StringEncoding)];
        if (checkSandbox(str)) {
            NSLog(@"sandboxed.");
        } else {
            NSLog(@"not sandbox app.");
        }
    }
    
    return 0;
}
