#!/bin/bash

./lua.sh sdk/dragonfruit/dragonc.lua $1 `dirname $1`/._out.s $3
./asm.sh `dirname $1`/._out.s $2
rm `dirname $1`/._out.s