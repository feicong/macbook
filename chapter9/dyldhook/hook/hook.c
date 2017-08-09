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

#include <stdio.h>

#import <dlfcn.h>
#import <stdarg.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <stdint.h>
#import <fcntl.h>
#import <string.h>

static int (*orig_open)(const char *, int, ...) = NULL;
static ssize_t (*orig_read)(int, void *, size_t) = NULL;
static int (*orig_close)(int) = NULL;

typedef int (*orig_open_type)(const char *, int, ...);
typedef ssize_t (*orig_read_type)(int, void *, size_t);
typedef int (*orig_close_type)(int);

__attribute__((constructor))
void init_funcs()
{
    printf("--------init funcs.--------\n");
    void * handle = dlopen("libSystem.dylib", RTLD_NOW);
    
    orig_open = (orig_open_type) dlsym(handle, "open");
    if(!orig_open) {
        printf("get open() addr error");
        exit(-1);
    }
    orig_read = (orig_read_type) dlsym(handle, "read");
    if(!orig_read) {
        printf("get open() addr error");
        exit(-1);
    }
    orig_close = (orig_close_type) dlsym(handle, "close");
    if(!orig_close) {
        printf("get open() addr error");
        exit(-1);
    }
    
    printf("--------init done--------\n");
}

int open(const char *path, int oflag, ...) {
    va_list ap = {0};
    mode_t mode = 0;
    
    if ((oflag & O_CREAT) != 0) {
        // mode only applies to O_CREAT
        va_start(ap, oflag);
        mode = va_arg(ap, int);
        va_end(ap);
        printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
        return orig_open(path, oflag, mode);
    } else {
        printf("Calling real open('%s', %d)\n", path, oflag);
        return orig_open(path, oflag, mode);
    }
}

ssize_t read(int fd, void *buf, size_t sz) {
    printf("Calling real read(%d)\n", fd);
    ssize_t sz_ = orig_read(fd, buf, sz);
    if (sz_ == sz) {
        memset(buf, 97, sz);
    }
    return sz_;
}

int close(int fd) {
    printf("Calling real close(%d)\n", fd);
    return orig_close(fd);
}

//cc -flat_namespace -dynamiclib -o ./libhook.dylib hook/hook.c
