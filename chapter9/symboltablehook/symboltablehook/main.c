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

#import <dlfcn.h>
#import <stdarg.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <stdint.h>
#import <fcntl.h>
#import <string.h>

#import "fishhook.h"

static int (*orig_open)(const char *, int, ...);
static ssize_t (*orig_read)(int, void *, size_t);
static int (*orig_close)(int);

int my_open(const char *path, int oflag, ...) {
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

ssize_t my_read(int fd, void *buf, size_t sz) {
    printf("Calling real read(%d)\n", fd);
    ssize_t sz_ = orig_read(fd, buf, sz);
    if (sz_ == sz) {
        memset(buf, 97, sz);
    }
    return sz_;
}

int my_close(int fd) {
    printf("Calling real close(%d)\n", fd);
    return orig_close(fd);
}

int main(int argc, char * argv[]) {
    rebind_symbols((struct rebinding[3]){
        {
            "open", my_open, (void *)&orig_open},
        {"read", my_read, (void *)&orig_read},
        {"close", my_close, (void *)&orig_close}
    }, 3);
    
    int fd = open(argv[0], O_RDONLY);
    uint32_t magic_number = 0;
    read(fd, (void*)&magic_number, 4);
    printf("Mach-O Magic Number: %x\n", magic_number);
    
    close(fd);
    
    return 0;
}

//cc fishhook.c main.c -o ./symboltablehook
