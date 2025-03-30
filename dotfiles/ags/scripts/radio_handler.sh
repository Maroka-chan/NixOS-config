#!/usr/bin/env bash

player=mpv

tmp_path=/tmp/eww/radio
pipe=${tmp_path}/pipe

start_radio () {
  $player --no-video --display-tags='icy-title,Title' --quiet "$1" > >(grep --line-buffered -i "Title") &
  radiopid=$!
  eww update isMusicPlaying=true
}

kill_radio () {
  if [ -n "${radiopid+x}" ]; then
    if grep -qFx "$radiopid" <(jobs -rp); then
       kill "$radiopid"
    fi
    unset radiopid
  fi
}

cleanup () {
  kill_radio
  rm -rf -- "$tmp_path"
}


trap cleanup EXIT

test -d ${tmp_path} || mkdir -p ${tmp_path}

if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

while true
do
  if read -r line <$pipe; then
    message=($line)
    case ${message[0]} in
      play)
        kill_radio
        start_radio "${message[1]}"
        ;;
      stop)
        kill_radio
        eww update isMusicPlaying=false
        ;;
    esac
  fi
done

