#sync rom welll
repo init --depth=1 --no-repo-verify -u https://github.com/DerpFest-12/manifest.git -b 12.1 -g default,-mips,-darwin,-notdefault
git clone https://github.com/hklknz/Local-Manifests --depth 1 -b tissot-derp .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build roms
source $CIRRUS_WORKING_DIR/script/config
timeStart

source build/envsetup.sh
export TZ=Asia/Jakarta
export KBUILD_BUILD_USER=Honoka
export KBUILD_BUILD_HOST=Cloud
export BUILD_USERNAME=Honoka
export BUILD_HOSTNAME=Cloud
lunch derp_tissot-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
make derp -j8  > reading

retVal=$?
timeEnd
statusBuild
