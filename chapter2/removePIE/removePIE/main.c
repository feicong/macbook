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
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <mach-o/loader.h>

//src by piaoyun.
int main(int argc, char *argv[]){
    struct mach_header currentHeader;
    FILE *fp;
    
    if(argc < 1)
    {
        printf("Please enter the filename binary: in the format removePIE filename.\n");
        return EXIT_FAILURE;
    }
    if((fp = fopen(argv[1], "rb+")) == NULL)
    {
        printf("Error, unable to open file.\n");
        return EXIT_FAILURE;
    }
    
    if (0 == fread(&currentHeader, sizeof(currentHeader), 1, fp))
    {
        printf("Error reading MACH-O header.\n");
        return EXIT_FAILURE;
    }
    
    if(currentHeader.magic == MH_MAGIC || currentHeader.magic == MH_MAGIC_64){
        printf("patch MH_MAGIC/MH_MAGIC_64.\n");
        currentHeader.flags &= ~MH_PIE;
        
        fseek(fp, 0, SEEK_SET);
        if((fwrite(&currentHeader, sizeof(currentHeader), 1, fp)) == (int)NULL)
        {
            printf("Error writing to file.\n");
        }
        printf("ASLR has been disabled for %s\n", argv[1]);
        fclose(fp);
        
        return EXIT_SUCCESS;
    }
    else if(currentHeader.magic == MH_CIGAM || currentHeader.magic == MH_CIGAM_64) // big endian
    {
        printf("patch MH_CIGAM/MH_CIGAM_64.\n");
        uint32_t flags = OSSwapInt32(currentHeader.flags);
        flags  &= ~MH_PIE;
        currentHeader.flags = OSSwapInt32(flags);
        
        fseek(fp, 0, SEEK_SET);
        if((fwrite(&currentHeader, sizeof(currentHeader), 1, fp)) == (int)NULL)
        {
            printf("Error writing to file.\n");
        }
        printf("ASLR has been disabled for %s\n", argv[1]);
        fclose(fp);
        
        return EXIT_SUCCESS;
    }
    else	//FAT_MAGIC/FAT_CIGAM
    {
        printf("not supported.\n");
        return EXIT_FAILURE;
    }
    
    return EXIT_FAILURE;
}
