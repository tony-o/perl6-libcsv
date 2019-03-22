#!/bin/bash

cd src 

gcc -c -fPIC csvwrap.c -o csvwrap.o
gcc -shared -Wl,-soname,csvwrap.so.1 -lcsv -o csvwrap.so.1.0.0 csvwrap.o

cd ..

echo 'If you'"'"'re running locally you may need to add this dir to LD_LIBRARY_PATH'
echo '  to do that, run: export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:'`pwd`'"'
 
