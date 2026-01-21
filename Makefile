MACOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk macosx' | sed 's/\(.*macosx\)\(.*\)/\2/')
IOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk iphoneos' | sed 's/\(.*iphoneos\)\(.*\)/\2/')
WATCHOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk watchos' | sed 's/\(.*watchos\)\(.*\)/\2/')

IS_CI=$(shell [ ! -z "$$CI" ] && echo "1")
ARCH=arch -arm64
PIPEFAIL=set -o pipefail
XCPRETTY=bundle exec xcpretty
TEST=$(PIPEFAIL) && $(ARCH) xcodebuild test -disableAutomaticPackageResolution -skipPackageUpdates -project Stytch/Stytch.xcodeproj -scheme StytchCoreTests -sdk
UI_UNIT_TESTS=$(PIPEFAIL) && $(ARCH) xcodebuild test -disableAutomaticPackageResolution -skipPackageUpdates -project Stytch/Stytch.xcodeproj -scheme StytchUIUnitTests -sdk
HOSTING_BASE_PATH=$(shell echo stytch-ios/$$REF | sed 's:/$$::')

.PHONY: coverage
coverage:
	@if [ ! -f $$(Scripts/coverage instr-profile-path) ]; then $(MAKE) test; fi
	$(ARCH) Scripts/coverage generate-html
	$(ARCH) Scripts/coverage generate-json

.PHONY: codegen
codegen:
	$(ARCH) mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

.PHONY: docs
docs: codegen
	$(ARCH) xcodebuild clean docbuild -scheme StytchCore -configuration Release -sdk iphoneos$(IOS_VERSION) -destination generic/platform=iOS -derivedDataPath .build | $(XCPRETTY)
	$(ARCH) xcodebuild clean docbuild -scheme StytchUI -configuration Release -sdk iphoneos$(IOS_VERSION) -destination generic/platform=iOS -derivedDataPath .build | $(XCPRETTY)

.PHONY: docs-site
docs-site: docs
	mkdir -p .build/docs/StytchCore
	mkdir -p .build/docs/StytchUI
	$(ARCH) $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs/StytchCore --hosting-base-path $(HOSTING_BASE_PATH)/StytchCore/
	$(ARCH) $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchUI.doccarchive --output-path .build/docs/StytchUI --hosting-base-path $(HOSTING_BASE_PATH)/StytchUI/

.PHONY: format
format:
	$(ARCH) mint run swiftformat .

.PHONY: lint
lint:
	$(ARCH) mint run swiftlint lint --quiet --strict
	$(ARCH) mint run swiftformat --lint .

.PHONY: setup
setup:
	$(ARCH) brew bundle
	@if [ ! $$NO_BUNDLE ]; then $(ARCH) bundle install; fi

.PHONY: test-all
test-all: codegen
	$(MAKE) test
	$(MAKE) test-ios
	$(MAKE) test-tvos
	$(MAKE) test-watchos

.PHONY: test tests test-macos
test tests test-macos: codegen
	@xcodebuild -showsdks
	@xcrun simctl list devices
	$(TEST) macosx -destination "platform=macOS" -enableCodeCoverage YES -derivedDataPath .build | $(XCPRETTY)

.PHONY: test-ios
test-ios: codegen
	@xcodebuild -showsdks
	@xcrun simctl list devices
	$(TEST) iphonesimulator18.5 -destination "OS=18.5,name=iPhone 16 Pro" | $(XCPRETTY)
	$(UI_UNIT_TESTS) iphonesimulator18.5 -destination "OS=18.5,name=iPhone 16 Pro" | $(XCPRETTY)

.PHONY: test-tvos
test-tvos: codegen
	@xcodebuild -showsdks
	@xcrun simctl list devices
	$(TEST) appletvsimulator18.4-destination "OS=18.5,name=Apple TV 4K (3rd generation)" | $(XCPRETTY)

.PHONY: test-watchos
test-watchos: codegen
	@xcodebuild -showsdks
	@xcrun simctl list devices
	$(TEST) watchsimulator11.5 -destination "OS=11.5,name=Apple Watch Ultra 2 (49mm)" | $(XCPRETTY)

.PHONY: tools
tools:
	$(ARCH) mint bootstrap
