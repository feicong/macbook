//
//  MyObject.m
//  amibeinghooked
//
//  Created by macbook on 6/14/16.
//  Copyright © 2016 macbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyObject.h"

//source from: https://segmentfault.com/a/1190000003950284
static inline bool isDiff(const char *func, SEL _cmd) {
    char buff[256] = {'\0'};
    if (strlen(func) > 2) {
        char* s = strstr(func, " ") + 1;
        char* e = strstr(func, "]");
        memcpy(buff, s, sizeof(char) * (e - s) );
        const char *realname = sel_getName(_cmd);
        return (strcmp(buff, realname) != 0);
    }
    return false;
}

#define ALERT_IF_METHOD_REPLACED {if (isDiff(__PRETTY_FUNCTION__, _cmd)) { \
            printf("objc method hooked\n"); \
            /*exit(-1);*/ \
        }}

@implementation MyObject

- (void) dosth
{
    ALERT_IF_METHOD_REPLACED
}

- (void) dosth2
{
    [self dosth2];
}

@end

