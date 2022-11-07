#!/bin/bash
# Checks for common types of media files which are usually prohibited.
for type in mp3 txt wav wma aac ogg flv flac mp4 mpg mpeg mov m4a avi gif jpg jpeg png bmp img exe msi bat sh
do
  sudo find /home -name *.$type
done
