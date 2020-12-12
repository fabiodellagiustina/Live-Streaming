# Tests stream

## RTMP module - RTMP

1 successful start out of 3, with bad video quality but low latency:
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i stream.sdp -map 0 -f flv rtmp://localhost/hls/stream
```

Audio-only usually, sometimes also video:
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i stream.sdp -map 0 -max_muxing_queue_size 4096 -f flv rtmp://localhost/hls/stream
```

Always works, bad video quality:
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i stream.sdp -map 0 -max_muxing_queue_size 1024 -f flv rtmp://localhost/hls/stream
```

__CHOSEN__:
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i stream.sdp -map 0 -max_muxing_queue_size 1024 -f flv rtmp://localhost/hls/stream

rtmp://hls.fabiodellagiustina.it/hls/stream
```


## No RTMP module - HLS

__CHOSEN__:
```
ffmpeg -protocol_whitelist file,udp,rtp -i /var/www/html/stream.sdp -map 0 -max_muxing_queue_size 1024 -r 30 -vsync 2 -f hls /var/www/html/hls/stream.m3u8

https://hls.fabiodellagiustina.it/hls/stream.m3u8
```
