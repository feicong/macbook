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

#import <AppKit/AppKit.h>
#import <Security/Security.h>

int main(int argc, char **argv) 
{
    //http://stackoverflow.com/questions/28177950/how-can-i-enumerate-all-keychain-items-in-my-os-x-application
    @autoreleasepool {
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                                      (__bridge id)kSecMatchLimitAll, (__bridge id)kSecMatchLimit,
                                      nil];
        
        NSArray *secItemClasses = [NSArray arrayWithObjects:
                                   (__bridge id)kSecClassGenericPassword,
                                   (__bridge id)kSecClassInternetPassword,
                                   (__bridge id)kSecClassCertificate,
                                   (__bridge id)kSecClassKey,
                                   (__bridge id)kSecClassIdentity,
                                   nil];
        
        for (id secItemClass in secItemClasses) {
            [query setObject:secItemClass forKey:(__bridge id)kSecClass];
            
            CFTypeRef result = NULL;
            SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            NSLog(@"%@", (__bridge id)result);
            if (result != NULL)
                CFRelease(result);
        }
    }
    return 0;
}

