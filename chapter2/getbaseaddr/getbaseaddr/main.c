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

#include <sys/types.h>
#include <sys/ptrace.h>
#include <sys/sysctl.h>

#include <mach/mach.h>
#include <mach/mach_init.h>
#include <mach/mach_vm.h>

#include "libkern/OSCacheControl.h"

//src code by malokch.
mach_vm_address_t get_basic_address(){
    mach_vm_size_t region_size = 0;
    mach_vm_address_t region = 0;
    mach_port_t task = 0;
    int ret = 0;
    
    ret = task_for_pid(mach_task_self(), getpid(), &task);
    if (ret != 0)
    {
        printf("task_for_pid() message %s!\n", mach_error_string(ret));
        return 0;
    }
    
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    vm_region_flavor_t flavor = VM_REGION_BASIC_INFO_64;
    if ((ret = mach_vm_region(mach_task_self(), &region, &region_size, flavor,
                              (vm_region_info_t)&info,
                              (mach_msg_type_number_t*)&info_count,
                              (mach_port_t*)&task)) != KERN_SUCCESS)
    {
        printf("mach_vm_region() error: %s!\n",mach_error_string(ret));
        return 0;
    }
    return region;
}

int main(int argc, const char * argv[])
{
    mach_vm_address_t address = get_basic_address();
    
    printf("Target pid     : %d\n", getpid());
    printf("Base address   : %llx\n", address);
    
    return 0;
}
