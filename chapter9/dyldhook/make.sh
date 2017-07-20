#!/bin/bash

cc hookapp/main.c -o ./app 
cc -flat_namespace -dynamiclib -o ./libhook.dylib hook/hook.c
