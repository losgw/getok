#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/xdroid-oss/xd_manifest -b twelve -g default,-mips,-darwin,-notdefault
git clone https://github.com/hklknz/local_manifest --depth 1 -b tissot .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build roms
source $CIRRUS_WORKING_DIR/script/config
timeStart

source build/envsetup.sh
export TZ=Asia/Jakarta
export KBUILD_BUILD_USER=Honoka$KBUILD_BUILD_USER
export KBUILD_BUILD_HOST=Cloud$KBUILD_BUILD_HOST
export BUILD_USERNAME=Honoka$KBUILD_BUILD_USER
export BUILD_HOSTNAME=Cloud$KBUILD_BUILD_HOST
lunch xdroid_tissot-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
mka bacon -j8  > reading

retVal=$?
timeEnd
statusBuild
