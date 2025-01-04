#!/bin/bash
read key < /home/momefilo/key_intel
ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -vaapi_device /dev/dri/renderD128 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -f v4l2 -input_format mjpeg -video_size 1024x768 -framerate "$rate" -i /dev/video0 -vcodec h264 -pix_fmt yuv420p -preset ultrafast -g 20 -b:v 2500k -vf scale="$width:$height" -bufsize 512k -b:a 160k -c:a aac -ac 2 -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/"$key"
