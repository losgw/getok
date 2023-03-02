#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/bananadroid/android_manifest.git -b 13 -g default,-mips,-darwin,-notdefault
git clone https://github.com/hklknz/Local-Manifests --depth 1 -b tissot-bananadroidCoreGApps .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build roms
source $CIRRUS_WORKING_DIR/script/config
timeStart
source build/envsetup.sh
export TZ=Asia/Tokyo
export KBUILD_BUILD_USER=hklknz
export KBUILD_BUILD_HOST=Roselia-CI
export BUILD_USERNAME=hklknz
export BUILD_HOSTNAME=Roselia-CI
lunch banana_tissot-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
m banana -j8  > reading
retVal=$?
timeEnd
statusBuild
