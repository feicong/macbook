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

#include <stdint.h>

uint64_t foo(uint64_t a1,uint64_t a2,uint64_t a3,uint64_t a4,uint64_t a5,uint64_t a6,uint64_t a7,uint64_t a8,uint64_t a9,uint64_t a10)
{
    printf("a1=%lld,a2=%lld,a3=%lld,a4=%lld,a5=%lld,a6=%lld,a7=%lld,a8=%lld,a9=%lld,a10=%lld\n",
           a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10;
}
