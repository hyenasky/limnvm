#!/bin/bash

./lua sdk/dragonfruit/dragonc.lua $1 `dirname $1`/._out.s $3
./asm `dirname $1`/._out.s $2
rm `dirname $1`/._out.s