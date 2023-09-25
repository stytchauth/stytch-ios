#!/bin/bash
# see: https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414/26

set -x
set -e

# Pass scheme name as the first argument to the script
NAME=$1

# Build the scheme for all platforms that we plan to support
for PLATFORM in "iOS" "iOS Simulator" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator" "macOS"; do

    case $PLATFORM in
    "iOS")
    RELEASE_FOLDER="Release-iphoneos"
    ;;
    "iOS Simulator")
    RELEASE_FOLDER="Release-iphonesimulator"
    ;;
    "tvOS")
    RELEASE_FOLDER="Release-tvos"
    ;;
    "tvOS Simulator")
    RELEASE_FOLDER="Release-tvsimulator"
    ;;
    "watchOS")
    RELEASE_FOLDER="Release-watchos"
    ;;
    "watchOS Simulator")
    RELEASE_FOLDER="Release-watchsimulator"
    ;;
    "macOS")
    RELEASE_FOLDER="Release-macos"
    ;;
    esac

    ARCHIVE_PATH=$RELEASE_FOLDER

    # Rewrite Package.swift so that it declaras dynamic libraries, since the approach does not work with static libraries
    perl -i -p0e 's/type: .static,//g' Package.swift
    perl -i -p0e 's/type: .dynamic,//g' Package.swift
    perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' Package.swift

    xcodebuild archive \
            -workspace . \
            -scheme $NAME \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath ".build" \
            -configuration Release \
            -allowProvisioningUpdates \
            CLONE_HEADERS=YES \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
            SWIFT_INSTALL_OBJC_HEADER=YES \
            OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" \
            OTHER_LDFLAGS="-ObjC" \
            REMOVE_HEADERS_FROM_EMBEDDED_BUNDLES=NO


    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${NAME}_${NAME}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ] 
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $NAME { export * }" > $MODULES_PATH/module.modulemap
        # TODO: Copy headers
    fi

    # Copy resources bundle, if exists 
    if [ -e $RESOURCES_BUNDLE_PATH ] 
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi

done

xcodebuild -create-xcframework \
-framework Release-iphoneos.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-iphoneos.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-iphonesimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-iphonesimulator.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-tvos.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-tvos.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-tvsimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-tvsimulator.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-watchos.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-watchos.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-watchsimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-watchsimulator.xcarchive/dSYMs/$NAME.framework.dSYM \
-framework Release-macos.xcarchive/Products/usr/local/lib/$NAME.framework \
-debug-symbols ${PWD}/Release-macos.xcarchive/dSYMs/$NAME.framework.dSYM \
-output $NAME.xcframework