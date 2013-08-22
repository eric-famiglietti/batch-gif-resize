#!/bin/bash

# This script resizes GIFs to 210x150. First it crops the image to a 7:5
# aspect ratio. Then it resizes the image to 210x150.
# This script uses ImageMagick.

FILES="./gifs/*.gif"

for FILE in $FILES
do
  BASENAME=$(basename $FILE)
  INPUT=$FILE
  TEMP="temp.gif"
  OUTPUT="./gifs_resized/${BASENAME}"

  WIDTH="210"
  HEIGHT="158"
  RATIO=`echo "${WIDTH}/${HEIGHT}" | bc -l`

  # Get first frame of animation.
  convert $INPUT[0] $TEMP

  # Get width and height of image.
  INPUT_WIDTH=`identify -format '%w' $TEMP`
  INPUT_HEIGHT=`identify -format '%h' $TEMP`

  # Calculate ratio.
  INPUT_RATIO=`echo "${INPUT_WIDTH}/${INPUT_HEIGHT}" | bc -l`

  # Resize image to correct size.
  if [ `echo "${INPUT_RATIO}!=${RATIO}" | bc -l` ];
  then
    if [ `echo "${INPUT_RATIO}<${RATIO}" | bc -l` -eq 1 ];
    then
      # Adjust height to match ratio. Resize image.
      TEMP_HEIGHT=`echo "${INPUT_WIDTH}/${RATIO}" | bc -l`
      Y_OFFSET=`echo "(${INPUT_HEIGHT}-${TEMP_HEIGHT})/2" | bc -l`
      convert $INPUT -coalesce -repage 0x0 -crop "${INPUT_WIDTH}x${TEMP_HEIGHT}+0+${Y_OFFSET}" +repage $TEMP
      convert -size "${INPUT_WIDTH}x${TEMP_HEIGHT}" $TEMP -resize "${WIDTH}x${HEIGHT}" $OUTPUT
    else
      # Adjust width to match reatio. Resize image.
      TEMP_WIDTH=`echo "${INPUT_HEIGHT}*${RATIO}" | bc -l`
      X_OFFSET=`echo "(${INPUT_WIDTH}-${TEMP_WIDTH})/2" | bc -l`
      convert $INPUT -coalesce -repage 0x0 -crop "${TEMP_WIDTH}x${INPUT_HEIGHT}+${X_OFFSET}+0" +repage $TEMP
      convert -size "${TEMP_WIDTH}x${INPUT_HEIGHT}" $TEMP -resize "${WIDTH}x${HEIGHT}" $OUTPUT
    fi
  else
    # Ratios match. Resize image.
    convert -size "${INPUT_WIDTH}x${INPUT_HEIGHT}" $INPUT -resize "${WIDTH}x${HEIGHT}" $OUTPUT
  fi
done

# Clean up.
rm $TEMP
