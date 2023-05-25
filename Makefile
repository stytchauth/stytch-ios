MACOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk macosx' | sed 's/\(.*macosx\)\(.*\)/\2/')
IOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk iphoneos' | sed 's/\(.*iphoneos\)\(.*\)/\2/')
WATCHOS_VERSION := $(shell xcodebuild -showsdks | grep -m 1 'sdk watchos' | sed 's/\(.*watchos\)\(.*\)/\2/')

IS_CI=$(shell [ ! -z "$$CI" ] && echo "1")
ARCH=arch -$(shell [ $(IS_CI) ] && echo "x86_64" || echo "arm64")
PIPEFAIL=set -o pipefail
XCPRETTY=bundle exec xcpretty
TEST=$(PIPEFAIL) && $(ARCH) xcodebuild test -disableAutomaticPackageResolution -skipPackageUpdates -project StytchDemo/StytchDemo.xcodeproj -scheme StytchCoreTests -sdk
HOSTING_BASE_PATH=$(shell echo stytch-swift/$$REF | sed 's:/$$::')

.PHONY: coverage
coverage:
	@if [ ! -f $$(Scripts/coverage instr-profile-path) ]; then $(MAKE) test; fi
	$(ARCH) Scripts/coverage generate-html
	$(ARCH) Scripts/coverage generate-json

.PHONY: codegen
codegen:
	$(ARCH) mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

.PHONY: demo
demo:
	Scripts/demo setup
	bundle exec --gemfile=StytchDemo/Gemfile Scripts/demo start

.PHONY: docs
docs: codegen
	$(ARCH) xcodebuild clean docbuild -scheme StytchCore -configuration Release -sdk iphoneos$(IOS_VERSION) -destination generic/platform=iOS -derivedDataPath .build | $(XCPRETTY)

.PHONY: docs-site
docs-site: docs
	$(ARCH) $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs --hosting-base-path $(HOSTING_BASE_PATH)

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
	$(TEST) macosx$(MACOS_VERSION) -destination "OS=$(MACOS_VERSION),platform=macOS" | $(XCPRETTY)

.PHONY: test-ios
test-ios: codegen
	$(TEST) iphonesimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=iPhone 14 Pro" | $(XCPRETTY)

.PHONY: test-tvos
test-tvos: codegen
	$(TEST) appletvsimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=Apple TV" | $(XCPRETTY)

.PHONY: test-watchos
test-watchos: codegen
	$(TEST) watchsimulator$(WATCHOS_VERSION) -destination "OS=$(WATCHOS_VERSION),name=Apple Watch Ultra (49mm)" | $(XCPRETTY)

.PHONY: tools
tools:
	$(ARCH) mint bootstrap

.PHONY: xc-framework
xc-framework:
	$(ARCH) mint run swift-create-xcframework --zip --xc-setting SKIP_INSTALL=NO --xc-setting BUILD_LIBRARY_FOR_DISTRIBUTION=YES
