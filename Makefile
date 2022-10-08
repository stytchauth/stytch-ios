IOS_VERSION=$(xcodebuild -showsdks | grep iphoneos | sed 's/\(.*iphoneos\)\(.*\)/\2/')
WATCHOS_VERSION=$(xcodebuild -showsdks | grep watchos | sed 's/\(.*watchos\)\(.*\)/\2/')

ARM64=arch -arm64
PIPEFAIL=set -o pipefail
XCPRETTY=bundle exec xcpretty

.PHONY: coverage codegen docs format lint setup test tests test-ios test-macos test-tvos test-watchos tools

coverage:
	@if [ ! -f $$(Scripts/coverage instr-profile-path) ]; then $(MAKE) test; fi
	$(ARM64) Scripts/coverage generate-html
	$(ARM64) Scripts/coverage generate-json

codegen:
	$(ARM64) mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

demo:
	Scripts/demo setup
	bundle exec --gemfile=StytchDemo/Gemfile Scripts/demo start

docs: codegen
	$(ARM64) xcodebuild docbuild -scheme StytchCore -configuration Release -sdk iphoneos$(IOS_VERSION) -destination generic/platform=iOS -derivedDataPath .build | $(XCPRETTY)

docs-site: docs
	$(ARM64) $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs --hosting-base-path stytch-swift

format:
	$(ARM64) mint run swiftformat .

lint:
	$(ARM64) mint run swiftlint lint --quiet --strict
	$(ARM64) mint run swiftformat --lint .

setup:
	$(ARM64) brew bundle
	$(ARM64) bundle install

test tests test-macos: codegen
	$(ARM64) swift test --enable-code-coverage

test-ios: codegen
	$(PIPEFAIL) && $(ARM64) xcodebuild test -project StytchDemo/StytchDemo.xcodeproj -scheme StytchCoreTests -sdk iphonesimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=iPhone 14 Pro" | $(XCPRETTY)

test-tvos: codegen
	$(PIPEFAIL) && $(ARM64) xcodebuild test -project StytchDemo/StytchDemo.xcodeproj -scheme StytchCoreTests -sdk appletvsimulator$(IOS_VERSION) -destination "OS=$(IOS_VERSION),name=Apple TV" | $(XCPRETTY)

test-watchos: codegen
	$(PIPEFAIL) && $(ARM64) xcodebuild test -project StytchDemo/StytchDemo.xcodeproj -scheme StytchCoreTests -sdk watchsimulator$(WATCHOS_VERSION) -destination "OS=$(WATCHOS_VERSION),name=Apple Watch Ultra (49mm)" | $(XCPRETTY)

tools:
	$(ARM64) mint bootstrap
