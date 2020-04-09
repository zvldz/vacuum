#!/usr/bin/env bash
if [ -d /mnt/data/rockrobo/rrlog ]; then
  items=/mnt/data/rockrobo/rrlog/*
  for item in $items
  do
    if [ -d "$item" ]; then
      echo "Removing directory '$item'..."
      rm -fr "$item"
    elif [ -f "$item" ]; then
      if [[ "$item" == *".log" ]]; then
        echo "Shrinking log '$item'..."
        echo "$(tail -50 "$item")" > $item
      else
        echo "Removing file '$item'..."
        rm "$item"
      fi
    fi
  done
fi