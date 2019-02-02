#!/bin/bash

DOWNLOAD_DIR='downloads'
mkdir -p $DOWNLOAD_DIR

if ! axel_loc="$(type -p axel)" || [ -z $axel_loc ]; then
  cd $DOWNLOAD_DIR;
	while read line; do curl -JO "$line"; done < ../PDF.txt
	while read line; do curl -JO "$line"; done < ../SD.txt
	#while read line; do curl -JO "$line"; done < ../HD.txt
else
	while read line; do axel -n 2 -a -o $DOWNLOAD_DIR "$line"; done < PDF.txt
	while read line; do axel -n 5 -a -o $DOWNLOAD_DIR "$line"; done < SD.txt
	#while read line; do axel -n 5 -a -o $DOWNLOAD_DIR "$line"; done < HD.txt
fi