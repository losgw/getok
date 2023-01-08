#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/xdroid-CAF/xd_manifest -b twelve -g default,-mips,-darwin,-notdefault
git clone https://github.com/aslenofarid/local_manifest --depth 1 -b xdroid .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build rom
source $CIRRUS_WORKING_DIR/script/config
timeStart

source build/envsetup.sh
export TZ=Asia/Jakarta
export KBUILD_BUILD_USER=$KBUILD_BUILD_USER
export KBUILD_BUILD_HOST=$KBUILD_BUILD_HOST
export BUILD_USERNAME=$KBUILD_BUILD_USER
export BUILD_HOSTNAME=$KBUILD_BUILD_HOST
lunch xdroid_X00TD-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
make xd -j8  > reading

retVal=$?
timeEnd
statusBuild
