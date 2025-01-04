#!/bin/bash

serviceText="[Unit]
Wants=network.target
After=network-online.target
BindsTo=dev-video0.device
After=dev-video0.device
[Service]
ExecStart=/usr/bin/stream_csi.sh
Restart=always
RestartSec=4
[Install]
WantedBy=multi-user.target"

befehlText='#!/bin/bash
read key < /home/momefilo/key.txt
libcamera-vid --tuning-file /usr/share/libcamera/ipa/rpi/vc4/ov5647_noir.json --inline --nopreview -t 0 --hflip --vflip --framerate 25 --codec h264 -o - | ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -thread_queue_size 1024 -use_wallclock_as_timestamps 1 -i pipe:0 -c:v copy -c:a aac -preset fast -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/"$key"'

key=$1
if [ "$key" = "" ]
then
  echo "Script mit YT-Key aufrufen!"
  exit
else
  echo $key > key.txt
fi

echo "check device"
if [ -e /dev/video0 ]
then
  echo "/dev/video0"
else
  echo "cam-fehler /dev/video0 nicht vorhanden"
  exit
fi

echo "   update"
sudo apt update
#echo "upgrade"
#sudo apt upgrade -y
echo "   install"
sudo apt install ffmpeg -y

echo "   create service"
sudo sed -i '/ACTION=="remove", GOTO="systemd_end"/a KERNEL=="video0", SYMLINK="video0", TAG+="systemd"' /lib/udev/rules.d/99-systemd.rules

sudo echo "$serviceText" > stream_csi.service
sudo mv stream_csi.service /etc/systemd/system/

sudo echo "$befehlText" > stream_csi.sh
sudo chmod +x stream_csi.sh
sudo mv stream_csi.sh /usr/bin/

sudo systemctl daemon-reload
sudo systemctl enable stream_csi.service
sudo reboot