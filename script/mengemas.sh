#!/usr/bin/env bash

pesan() {
    echo -e "\e[1;32m$*\e[0m"
}

pesan_telegram() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d parse_mode="HTML" \
    -d text="$1"
}

function enviroment() {
    perangkat=$(grep lunch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
    nama_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
    nama_file=$(cd $WORKDIR/rom/$nama_rom/out/target/product/$perangkat && ls *.zip)
    brach=$(grep init $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
    rel_date=$(date "+%Y%m%d")
    DATE_L=$(date +%d\ %B\ %Y)
    DATE_S=$(date +"%T")
}

function upload_rom() {
pesan Mengunggah ROM...

cd $WORKDIR/rom/$nama_rom

nama_file=$(basename out/target/product/$perangkat/*.zip)
tautan=https://cirrus-ci.com/build/$CIRRUS_BUILD_ID

cd $WORKDIR/rom/$nama_rom/out/target/product/$perangkat

curl -T $nama_file temp.sh; echo

rm -rf $nama_file

echo -e \
"
<b>Building selesai...</b>
<b>==============================</b>
<b>ROM :</b> <b>${nama_rom} | ${brach}</b>
<b>Nama file :</b> <b><code>"${nama_file}"</code></b>
<b>Lama build : "$(grep "#### build completed successfully" $WORKDIR/rom/$nama_rom/build.log -m 1 | cut -d '(' -f 2)"</b>
<b>Size : "$(ls -lh *zip | cut -d ' ' -f5)"</b>
<b>Download Link :</b> <a href=\"${tautan}\">Here</a>
<b>Tanggal : "$(date +%d\ %B\ %Y)"</b>
<b>Zona waktu : "$(date +%T)"</b>
<b>==============================</b>
<b>📕 MD5 :</b> <code>"$(md5sum *zip | cut -d' ' -f1)"</code>
<b>📘 SHA1 :</b> <code>"$(sha1sum *zip | cut -d' ' -f1)"</code>
<b>==============================</b>
<b>🌀 Maintainer : <a href=\"${maintainer}\">$USER</a></b>
" > tg.html
TG_TEXT=$(< tg.html)
pesan_telegram "$TG_TEXT"

echo
pesan Mengunggah ROM berhasil...
echo
echo Tautan Unduhan: ${tautan}
echo
echo
}

function upload_ccache() {
    cd $WORKDIR
    compress() {
        tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
    }
    time compress ccache 1
    rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.gz build:ccache/$perangkat/$nama_rom -P
    rm -rf ccache.tar.gz
    pesan Mengunggah ccache berhasil...
}

function upload() {
enviroment
sukses=$(grep '#### build completed successfully' $WORKDIR/rom/$nama_rom/build.log -m1 || true)
if [[ $sukses == *'#### build completed successfully'* ]]; then
    pesan Build selesai 100% sukses ✅
    echo
    upload_rom
    pesan Upload ccache..
    upload_ccache
else
    pesan Build belum selesai, Unggah ccache saja ❌
    pesan Upload ccache..
    upload_ccache
fi
}

upload
