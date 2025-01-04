#!/bin/bash
echo "<!DOCTYPE html>" > index.html
while read p; do
	echo "$p" >> index.html
done < html_begin.txt

anfang='<iframe width="1024" height="768" src="https://www.youtube.com/embed/'
rest='?autoplay=1&mute=1" title="csi" frameborder="5" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>'
while read p; do
	echo "$anfang$p$rest" >> index.html
done < embed_code_html.txt

echo "</body></html>" >> index.html

sudo mv index.html /var/www/html/
