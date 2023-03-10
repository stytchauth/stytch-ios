IOS_VERSION := $(shell xcodebuild -showsdks | grep iphoneos | sed 's/\(.*iphoneos\)\(.*\)/\2/')
WATCHOS_VERSION := $(shell xcodebuild -showsdks | grep watchos | sed 's/\(.*watchos\)\(.*\)/\2/')

IS_CI=$(shell [ ! -z "$$CI" ] && echo "1")
ARCH=arch -$(shell [ $(IS_CI) ] && echo "x86_64" || echo "arm64")
PIPEFAIL=set -o pipefail
XCPRETTY=bundle exec xcpretty
TEST=$(PIPEFAIL) && $(ARCH) xcodebuild test -disableAutomaticPackageResolution -skipPackageUpdates -project StytchDemo/StytchDemo.xcodeproj -scheme StytchCoreTests -sdk
HOSTING_BASE_PATH=$(shell echo stytch-swift/$$REF | sed 's:/$$::')

.PHONY: coverage codegen docs format lint setup test tests test-ios test-macos test-tvos test-watchos tools

coverage:
	@if [ ! -f $$(Scripts/coverage instr-profile-path) ]; then $(MAKE) test; fi
	$(ARCH) Scripts/coverage generate-html
	$(ARCH) Scripts/coverage generate-json

codegen:
	$(ARCH) mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

demo:
	Scripts/demo setup
	bundle exec --gemfile=StytchDemo/Gemfile Scripts/demo start

docs: codegen
	$(ARCH) xcodebuild clean docbuild -scheme StytchCore -configuration Release -sdk iphoneos$(IOS_VERSION) -destination generic/platform=iOS -derivedDataPath .build | $(XCPRETTY)

docs-site: docs
	$(ARCH) $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs --hosting-base-path $(HOSTING_BASE_PATH)

format:
	$(ARCH) mint run swiftformat .

lint:
	$(ARCH) mint run swiftlint lint --quiet --strict
	$(ARCH) mint run swiftformat --lint .

setup:
	$(ARCH) brew bundle
	@if [ ! $$NO_BUNDLE ]; then $(ARCH) bundle install; fi

test-all: codegen
	$(MAKE) test
	$(MAKE) test-ios
	$(MAKE) test-tvos
	$(MAKE) test-watchos

test tests test-macos: codegen
	$(ARCH) swift test --enable-code-coverage --disable-automatic-resolution --skip-update

test-ios: codegen
	$(TEST) iphonesimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=iPhone 14 Pro" | $(XCPRETTY)

test-tvos: codegen
	$(TEST) appletvsimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=Apple TV" | $(XCPRETTY)

test-watchos: codegen
	$(TEST) watchsimulator$(WATCHOS_VERSION) -destination "OS=$(WATCHOS_VERSION),name=Apple Watch Ultra (49mm)" | $(XCPRETTY)

tools:
	$(ARCH) mint bootstrap

xc-framework:
	$(ARCH) mint run swift-create-xcframework --zip --xc-setting SKIP_INSTALL=NO --xc-setting BUILD_LIBRARY_FOR_DISTRIBUTION=YES
