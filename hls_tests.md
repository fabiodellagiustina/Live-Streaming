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


# RTMP module - HLS

Changed folder permissions for `tmp/hls` into `ubuntu:ubuntu`. <br/> Before:
```
root@hls-server:/tmp# ls -la
total 48
drwxrwxrwt 12 root     root 4096 Dec 12 22:46 .
drwxr-xr-x 20 root     root 4096 Dec 10 17:58 ..
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .font-unix
drwx------  2 www-data root 4096 Dec 12 22:31 hls
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .ICE-unix
drwx------  3 root     root 4096 Dec 12 22:31 snap.lxd
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-logind.service-OIewfi
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-resolved.service-YVxl9f
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-timesyncd.service-2FuCpi
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .Test-unix
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .X11-unix
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .XIM-unix
root@hls-server:/tmp# ls -la /var/www/html/
hls/        index.html  stream.sdp  
root@hls-server:/tmp# ls -la /var/www/html/
total 20
drwxr-xr-x 3 ubuntu ubuntu 4096 Dec 12 17:17 .
drwxr-xr-x 3 root   root   4096 Dec 10 18:14 ..
drwxrwxr-x 2 ubuntu ubuntu 4096 Dec 12 22:18 hls
-rw-rw-r-- 1 ubuntu ubuntu  693 Dec 11 22:41 index.html
-rw-rw-r-- 1 ubuntu ubuntu  384 Dec 12 16:57 stream.sdp
root@hls-server:/tmp#

```

After:
```
root@hls-server:/tmp# ls -la
total 48
drwxrwxrwt 12 root     root 4096 Dec 12 22:46 .
drwxr-xr-x 20 root     root 4096 Dec 10 17:58 ..
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .font-unix
drwx------  2 UBUNTU   UBUNTU 4096 Dec 12 22:31 hls
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .ICE-unix
drwx------  3 root     root 4096 Dec 12 22:31 snap.lxd
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-logind.service-OIewfi
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-resolved.service-YVxl9f
drwx------  3 root     root 4096 Dec 12 22:31 systemd-private-1b2a51873b714761aa8281ed8ccaa1fe-systemd-timesyncd.service-2FuCpi
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .Test-unix
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .X11-unix
drwxrwxrwt  2 root     root 4096 Dec 12 22:31 .XIM-unix
root@hls-server:/tmp# ls -la /var/www/html/
hls/        index.html  stream.sdp  
root@hls-server:/tmp# ls -la /var/www/html/
total 20
drwxr-xr-x 3 ubuntu ubuntu 4096 Dec 12 17:17 .
drwxr-xr-x 3 root   root   4096 Dec 10 18:14 ..
drwxrwxr-x 2 ubuntu ubuntu 4096 Dec 12 22:18 hls
-rw-rw-r-- 1 ubuntu ubuntu  693 Dec 11 22:41 index.html
-rw-rw-r-- 1 ubuntu ubuntu  384 Dec 12 16:57 stream.sdp
root@hls-server:/tmp#

```

File `nginx.conf`:
```
user www-data;
#user ubuntu;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

rtmp {
        server {
                listen 1935;

                chunk_size 4000;

                application hls {
                        live on;
                        hls on;
                        interleave on;
                        hls_path /tmp/hls;
                        hls_fragment 3;
                        hls_playlist_length 60;
                }
        }
}

http {
        default_type application/octect-stream;

        server {
                listen 80;

                location / {
                        root /tmp/hls;
                }

                types {
                        application/vnd.apple.mpegurl m3u8;
                        video/mp2t ts;
                        text/html html;
                }
        }

```

## Video, no audio working
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i /var/www/html/stream.sdp -map 0 -r 30 -vcodec libx264 -vprofile baseline -acodec libmp3lame -ar 44100 -ac 1 -max_muxing_queue_size 1024 -f flv rtmp://localhost:1935/hls/stream
```

## Video and audio (CHOSEN)
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i /var/www/html/stream.sdp -r 30 -map 0 -vcodec libx264 -vprofile baseline -acodec aac -max_muxing_queue_size 1024 -f flv rtmp://localhost:1935/hls/stream
```

## Video and audio (w/ timestamps)
```sh
ffmpeg -protocol_whitelist file,udp,rtp -i /var/www/html/stream.sdp -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: text='%{localtime}': x=(w-tw)/2: y=h-(2*lh): fontcolor=white: box=1: boxcolor=0x00000000@1: fontsize=30" -r 30 -map 0 -vcodec libx264 -vprofile baseline -acodec aac -max_muxing_queue_size 1024 -f flv rtmp://localhost:1935/hls/stream
```

NB: check `-probesize 1000k` performance/effectivness.

## Video and audio, automatic start

In `/etc/nginx/nginx.conf`, the correct RTMP configuration:
```
rtmp {
        server {
                listen 1935;

                chunk_size 4000;

                application src {
                        live on;
                        allow publish all;
                        #deny publish all;
                        exec_static usr/bin/ffmpeg -protocol_whitelist file,udp,rtp -i /var/www/html/stream.sdp -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: text='%{localtime}': x=(w-tw)/2: y=h-(2*lh): fontcolor=white: box=1: boxcolor=0x00000000@1: fontsize=30" -r 30 -map 0 -vcodec libx264 -vprofile baseline -acodec aac -max_muxing_queue_size 1024 -f flv rtmp://localhost/hls/stream;
                }

                application hls {
                        live on;
                        hls on;
                        interleave on;
                        hls_path /tmp/hls;
                        hls_fragment 3;
                        hls_playlist_length 60;
                }
        }
}
```

**Note:** Resulting HLS stream has ~35 seconds of playback delay.

# Delay study

Changed configuration in janus.jcfg. Added line `log_timestamps` debug.

## WebRTC Peer Connection statistics

Added following code after line 292 in `streamingtest.js`:
```js
document.getElementById('stats-btn').onclick = function() {
   alert("button was clicked");
   window.setInterval(function() {
     streaming.webrtcStuff.pc.getStats(null).then(stats => {
       let statsOutput = "";

       stats.forEach(report => {
         statsOutput += `<h2>Report: ${report.type}</h3>\n<strong>ID:</strong> ${report.id}<br>\n` +
                        `<strong>Timestamp:</strong> ${report.timestamp}<br>\n`;

         // Now the statistics for this report; we intentially drop the ones we
         // sorted to the top above

         Object.keys(report).forEach(statName => {
           if (statName !== "id" && statName !== "timestamp" && statName !== "type") {
             statsOutput += `<strong>${statName}:</strong> ${report[statName]}<br>\n`;
           }
         });
       });

       // document.querySelector("#stats-box").innerHTML = statsOutput;
       document.getElementById("stats-box").innerHTML = statsOutput;
     });
   }, 1000);
}​;​
```

In case want to see WebRTC statistics provided by Firefox (while connection on):
```
about:webrtc
```

In case want to see WebRTC statistics provided by Chrome (while connection on):
```
chrome://webrtc-internals/
```
