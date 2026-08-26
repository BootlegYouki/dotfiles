#!/bin/bash
if [ "$1" == "get" ]; then
    b=$(v4l2-ctl -d /dev/video0 -C brightness 2>/dev/null | awk '{print $2}')
    c=$(v4l2-ctl -d /dev/video0 -C contrast 2>/dev/null | awk '{print $2}')
    s=$(v4l2-ctl -d /dev/video0 -C saturation 2>/dev/null | awk '{print $2}')
    sh=$(v4l2-ctl -d /dev/video0 -C sharpness 2>/dev/null | awk '{print $2}')
    g=$(v4l2-ctl -d /dev/video0 -C gamma 2>/dev/null | awk '{print $2}')
    
    # Defaults in case camera is disconnected
    b=${b:-0}
    c=${c:-32}
    s=${s:-64}
    sh=${sh:-3}
    g=${g:-100}
    
    echo "{\"brightness\": $b, \"contrast\": $c, \"saturation\": $s, \"sharpness\": $sh, \"gamma\": $g}"
elif [ "$1" == "set" ]; then
    v4l2-ctl -d /dev/video0 -c $2=$3
elif [ "$1" == "test" ]; then
    pgrep guvcview >/dev/null || guvcview &
fi
