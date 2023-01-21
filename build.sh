#sync rom aneh
repo init --depth=1 --no-repo-verify -u https://github.com/xdroid-CAF/xd_manifest -b eleven -g default,-mips,-darwin,-notdefault
git clone https://github.com/hklknz/Local-Manifests --depth 1 -b tissot-xdcaf-eleven .repo/local_manifests
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
export BUILD_BROKEN_DUP_RULES=true
export RELAX_USES_LIBRARY_CHECK=true
RELAX_USES_LIBRARY_CHECK=true
export BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES=true
export BROKEN_ENFORCE_SYSPROP_OWNER=true
export BROKEN_MISSING_REQUIRED_MODULES=true
export BROKEN_VENDOR_PROPERTY_NAMESPACE=true
lunch xdroid_tissot-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
make xd -j8  > reading
retVal=$?
timeEnd
statusBuild
