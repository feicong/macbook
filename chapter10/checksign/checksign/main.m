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
#import <Security/CSCommon.h>
#import <Security/SecStaticCode.h>
#import <Security/SecCode.h>
#import <Security/Security.h>


NSString *getCertSummaryFromFile(NSString *exefilePath) {
    NSString *ret = @"";
    SecStaticCodeRef ref = NULL;
    NSString *urlStr = [[NSString alloc] initWithFormat: @"file://%@", exefilePath];
    NSURL * url = [[NSURL alloc] initWithString: urlStr];
    OSStatus status = SecStaticCodeCreateWithPath((__bridge CFURLRef)url, kSecCSDefaultFlags, &ref);
    if (noErr != status || NULL == ref) {
        NSLog(@"code create path error");
        return ret;
    }
    
    CFDictionaryRef dictRef = NULL;
    status = SecCodeCopySigningInformation(ref, kSecCSSigningInformation, &dictRef);
    if (noErr != status || NULL == dictRef) {
        NSLog(@"dict is nil");
        return ret;
    }
    
    NSArray *cerArray = (NSArray *)CFDictionaryGetValue(dictRef, kSecCodeInfoCertificates);
    if (nil == cerArray || 0 == [cerArray count]) {
        NSLog(@"cert is nil");
        return ret;
    }
    
    SecCertificateRef cert = (__bridge SecCertificateRef)[cerArray firstObject];
    CFStringRef subjectSummary = SecCertificateCopySubjectSummary(cert);
    
    return (__bridge NSString *)subjectSummary;
}

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
            NSLog(@"[%d]", (int)status);
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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            NSLog(@"usage: checksign file:///Applications/xxx.app/Contents/MacOS/xxx");
            return 0;
        }
        //NSString *str = @"file:///Applications/Thunder.app/Contents/MacOS/Thunder";
        NSString *str = [NSString stringWithCString:argv[1] encoding:(NSUTF8StringEncoding)];
        if (checkCodeSign(str)) {
            NSMutableString *ss = [NSMutableString stringWithString:@"subject summary is "];
            [ss appendString:getCertSummaryFromFile(str)];
            NSLog(@"%@", ss);
        }
    }
    
    return 0;
}
