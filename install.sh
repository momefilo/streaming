#!/bin/bash
Key=$2
Cam=$1
if [ "$Key" = "" ]
then
  echo "Script mit YT-Key und CamID aufrufen!"
  exit
else
  echo $Key > key.txt
fi
if [ "$Cam" = "" ]
then
  echo "Script mit YT-Key und CamID aufrufen!"
  exit
fi
Device="/dev/video$Cam"
if [ -e $Device ]
then
  echo "$Device"
else
  echo "cam-fehler $Device"
  exit
fi

serviceText="[Unit]
Wants=network.target
After=network-online.target
BindsTo=dev-video${Cam}.device
After=dev-video${Cam}.device
[Service]
ExecStart=/usr/bin/stream_csi.sh
Restart=always
RestartSec=4
[Install]
WantedBy=multi-user.target"

befehlText='#!/bin/bash
read key < /home/momefilo/key.txt
libcamera-vid --inline --nopreview -t 0 --hflip --vflip --framerate 25 --codec h264 -o - | ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -thread_queue_size 1024 -use_wallclock_as_timestamps 1 -i pipe:0 -c:v copy -c:a aac -preset fast -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/"$key"'
#csi-cam ohne IR-Filter
#libcamera-vid --tuning-file /usr/share/libcamera/ipa/rpi/vc4/ov5647_noir.json --inline --nopreview -t 0 --hflip --vflip --framerate 25 --codec h264 -o - | ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -thread_queue_size 1024 -use_wallclock_as_timestamps 1 -i pipe:0 -c:v copy -c:a aac -preset fast -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/"$key"'
#usb-cam
#ffmpeg -re  -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -f v4l2 -input_format mjpeg -video_size 1024x768 -framerate 25 -i /dev/video0 -vcodec h264 -pix_fmt yuv420p -preset ultrafast -g 20 -b:v 2500k -bufsize 512k -b:a 160k -c:a aac -ac 2 -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/"$key"
#intel-maschine
#ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -vaapi_device /dev/dri/renderD128 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -f v4l2 -input_format mjpeg -video_size 1024x768 -framerate "$rate" -i /dev/video0 -vcodec h264 -pix_fmt yuv420p -preset ultrafast -g 20 -b:v 2500k -vf scale="$width:$height" -bufsize 512k -b:a 160k -c:a aac -ac 2 -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/"$key"

sudo apt update
sudo apt install ffmpeg -y

echo "   create service"
#sudo sed -i '/ACTION=="remove", GOTO="systemd_end"/a KERNEL=="video0", SYMLINK="video0", TAG+="systemd"' /lib/udev/rules.d/99-systemd.rules
Datei="/lib/udev/rules.d/99-systemd.rules"
Suche="ACTION==\"remove\", GOTO=\"systemd_end\""
Einsatz="KERNEL==\"video${Cam}\", SYMLINK=\"video${Cam}\", TAG+=\"systemd\""
sudo sed -i "/$Suche/a $Einsatz" "$Datei"

sudo echo "$serviceText" > stream_csi.service
sudo mv stream_csi.service /etc/systemd/system/

sudo echo "$befehlText" > stream_csi.sh
sudo chmod +x stream_csi.sh
sudo mv stream_csi.sh /usr/bin/

sudo systemctl daemon-reload
sudo systemctl enable stream_csi.service
sudo reboot
