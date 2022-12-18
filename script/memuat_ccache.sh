#!/usr/bin/env bash

cd $WORKDIR
mkdir -p ~/.config/rclone
echo "$RCLONECONFIG_DRIVE" > ~/.config/rclone/rclone.conf

# Lingkungan Utama
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
nama_perangkat=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)

rclone copy --drive-chunk-size 256M --stats 1s build:ccache/$nama_perangkat/$name_rom/ccache.tar.gz $WORKDIR -P

tar xzf ccache.tar.gz
rm -rf ccache.tar.gz
