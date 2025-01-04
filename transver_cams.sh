#!/bin/bash
scp embed_code_html.txt pi4:/home/momefilo/
ssh pi4 -t "/home/momefilo/make_html.sh"