#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/VoidUI-Tiramisu/manifest -b aosp-13 -g default,-mips,-darwin,-notdefault
git clone https://github.com/hklknz/Local-Manifests --depth 1 -b hklknz-patch-1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build rom
source $CIRRUS_WORKING_DIR/script/config
timeStart
source build/envsetup.sh
export TZ=Asia/Tokyo
export KBUILD_BUILD_USER=Honoka
export KBUILD_BUILD_HOST=HonkCI
export BUILD_USERNAME=Honoka
export BUILD_HOSTNAME=HonkCI
lunch aosp_tissot-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
mka bacon -j8  > reading
retVal=$?
timeEnd
statusBuild
