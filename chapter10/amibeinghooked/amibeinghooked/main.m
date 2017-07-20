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
#import "objc/runtime.h"
#import "objc/message.h"
#import "MyObject.h"

static void testMethodSwizzing() {
    Method ori_method = class_getInstanceMethod([MyObject class], @selector(dosth));
    Method replace_method = class_getInstanceMethod([MyObject class], @selector(dosth2));
    method_exchangeImplementations(ori_method, replace_method);
    
    [[[MyObject alloc] init ]dosth];
}

static bool isDyldHooked() {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        printf("DYLD_INSERT_LIBRARIES: %s\n", env);
    }
    return (env != NULL);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        testMethodSwizzing();
        if (isDyldHooked()) {
            printf("dyld hooked\n");
        }
    }
    return 0;
}
