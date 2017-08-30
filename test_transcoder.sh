#!/bin/bash
#Purpose = test transcoder

curl -X GET 'http://127.0.0.1/locations?action=transcode&json={"user_id":"3f68e4a4-74bc-4c2d-bf5c-09f8fd501b7d","media_id":"10f536b1-acf4-4c80-aafd-b074419ecf17","content_type":"video\/mp4","s3path":"3f68e4a4-74bc-4c2d-bf5c-09f8fd501b7d\/10f536b1-acf4-4c80-aafd-b074419ecf17\/","s3file_name":"VID_20141116_084415.mp4","s3file_basename_prefix":"VID_20141116_084415","is_video":1,"is_audio":0,"memreastranscoder":true}'

