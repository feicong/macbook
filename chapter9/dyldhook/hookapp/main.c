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
#include <unistd.h>
#include <stdint.h>
#import <fcntl.h>

int main(int argc, const char * argv[]) {
    int fd = open(argv[0], O_RDONLY);
    uint32_t magic_number = 0;
    read(fd, (void*)&magic_number, 4);
    printf("Mach-O Magic Number: %x\n", magic_number);
    
    close(fd);
    
    return 0;
}

//cc hookapp/main.c -o ./app
//export DYLD_FORCE_FLAT_NAMESPACE=1
//DYLD_INSERT_LIBRARIES=libhook.dylib ./app
