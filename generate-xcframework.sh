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
    RELEASE_FOLDER="Release-appletvos"
    ;;
    "tvOS Simulator")
    RELEASE_FOLDER="Release-appletvsimulator"
    ;;
    "watchOS")
    RELEASE_FOLDER="Release-watchos"
    ;;
    "watchOS Simulator")
    RELEASE_FOLDER="Release-watchsimulator"
    ;;
    "macOS")
    RELEASE_FOLDER="Release"
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
            DEFINES_MODULE=YES \
            CLONE_HEADERS=YES \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
            SWIFT_INSTALL_OBJC_HEADER=YES \
            OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" \
            OTHER_LDFLAGS="-ObjC" \
            REMOVE_HEADERS_FROM_EMBEDDED_BUNDLES=NO \
            VALIDATE_PRODUCT=YES


    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    HEADERS_PATH="$FRAMEWORK_PATH/Headers"
    mkdir -p $MODULES_PATH
    mkdir -p $HEADERS_PATH

    BUILD_PRODUCTS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${NAME}_${NAME}.bundle"
    VARIANT_NAME=${RELEASE_FOLDER/"Release"/""}
    VARIANT_HEADERS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/IntermediateBuildFilesPath/GeneratedModuleMaps$VARIANT_NAME"
    INCLUDES_PATH="$RELEASE_PATH/include"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ] 
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $NAME { export * }" > $MODULES_PATH/module.modulemap
    fi

    # Copy headers
    if [ -d $VARIANT_HEADERS_PATH ]
    then
        cp $VARIANT_HEADERS_PATH/$NAME-Swift.h $HEADERS_PATH/
    fi

    if [ -d $INCLUDES_PATH ]
    then
        cp -r $INCLUDES_PATH/* $HEADERS_PATH/
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
    -framework Release-appletvos.xcarchive/Products/usr/local/lib/$NAME.framework \
    -debug-symbols ${PWD}/Release-appletvos.xcarchive/dSYMs/$NAME.framework.dSYM \
    -framework Release-appletvsimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
    -debug-symbols ${PWD}/Release-appletvsimulator.xcarchive/dSYMs/$NAME.framework.dSYM \
    -framework Release-watchos.xcarchive/Products/usr/local/lib/$NAME.framework \
    -debug-symbols ${PWD}/Release-watchos.xcarchive/dSYMs/$NAME.framework.dSYM \
    -framework Release-watchsimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
    -debug-symbols ${PWD}/Release-watchsimulator.xcarchive/dSYMs/$NAME.framework.dSYM \
    -framework Release.xcarchive/Products/usr/local/lib/$NAME.framework \
    -debug-symbols ${PWD}/Release.xcarchive/dSYMs/$NAME.framework.dSYM \
    -output $NAME.xcframework