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
#include <mach/task.h>
#include <mach/mach_init.h>
#include <stdbool.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/ptrace.h>

static bool amibeingdebugged_1();
static bool amibeingdebugged_2();

static bool amibeingdebugged_1() {
    mach_msg_type_number_t count = 0;
    exception_mask_t masks[EXC_TYPES_COUNT];
    mach_port_t ports[EXC_TYPES_COUNT];
    exception_behavior_t behaviors[EXC_TYPES_COUNT];
    thread_state_flavor_t flavors[EXC_TYPES_COUNT];
    
    exception_mask_t mask = EXC_MASK_ALL & ~(EXC_MASK_RESOURCE | EXC_MASK_GUARD);
    kern_return_t result = task_get_exception_ports(mach_task_self(), mask, masks, &count, ports, behaviors, flavors);
    if (result == KERN_SUCCESS) {
        for (mach_msg_type_number_t portIndex = 0; portIndex < count; portIndex++) {
            if (MACH_PORT_VALID(ports[portIndex])) {
                return true;
            }
        }
    }
    return false;
}

static bool amibeingdebugged_2() {
    // Returns true if the current process is being debugged (either
    // running under the debugger or has a debugger attached post facto).

    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

//always return false.
static bool amibeingdebugged_3(){
    if(ptrace(PT_TRACE_ME, 0, 0, 0) == -1)
        return true;
    ptrace(PT_DETACH, 0, 0, 0);
    return false;
}

int main(int argc, const char * argv[]) {
    //ptrace(PT_DENY_ATTACH, 0, 0, 0);
    if (amibeingdebugged_1()) {
        printf("debugged in amibeingdebugged_1\n");
    } else {
        printf("amibeingdebugged_1 ok\n");
    }
    if (amibeingdebugged_2()) {
        printf("debugged in amibeingdebugged_2\n");
    } else {
        printf("amibeingdebugged_2 ok\n");
    }
    if (amibeingdebugged_3()) {
        printf("debugged in amibeingdebugged_3\n");
    } else {
        printf("amibeingdebugged_3 ok\n");
    }
    return 0;
}
