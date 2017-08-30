#!/bin/bash
#Purpose = test transcoder
# Comments: update parameters to test against your files
# Structure of json:
# 
# {
# "user_id":"3f68e4a4-74bc-4c2d-bf5c-09f8fd501b7d", //shoudld be unique
# "media_id":"10f536b1-acf4-4c80-aafd-b074419ecf17", //shoudld be unique
# "content_type":"video\/mp4", //modify for your mime type
# "s3path":"3f68e4a4-74bc-4c2d-bf5c-09f8fd501b7d\/10f536b1-acf4-4c80-aafd-b074419ecf17\/", //s3 folder path -> user_id/media_id/
# "s3file_name":"VID_20141116_084415.mp4", //file name to be transcoded
# "s3file_basename_prefix":"VID_20141116_084415", file name prefix
# "is_video":1, // 0 for image or audio
# "is_audio":0, // 1 for audio
# "memreastranscoder":true //legacy parameter
# }

curl -X POST -F 'action=transcode' -F 'json={"user_id":"3f68e4a4-74bc-4c2d-bf5c-56f8fd501b7d","media_id":"99f536b1-acf4-4c80-aafd-b074419ecf17","content_type":"video\/mp4","s3path":"3f68e4a4-74bc-4c2d-bf5c-09f8fd501b7d\/10f536b1-acf4-4c80-aafd-b074419ecf17\/","s3file_name":"VID_20141116_084415.mp4","s3file_basename_prefix":"VID_20141116_084415","is_video":1,"is_audio":0,"memreastranscoder":true}' http://127.0.0.1
