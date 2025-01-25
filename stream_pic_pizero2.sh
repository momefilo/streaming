#!/bin/bash
read key < /home/momefilo/streaming/key_pizero2
ffmpeg -re  -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -loop 1 -i /home/momefilo/streaming/bild.jpg -vcodec h264 -pix_fmt yuv420p -preset ultrafast -g 20 -b:v 2500k -bufsize 512k -b:a 160k -c:a aac -ac 2 -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/"$key"
