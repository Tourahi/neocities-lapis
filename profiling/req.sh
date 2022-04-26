#!/bin/sh

a=0
while [ "$a" -lt 10 ]
do
   curl -w "@curl-format.txt" -o . -s "http://localhost:9090/cat" >> "res.txt"
   a=`expr $a + 1`
done
