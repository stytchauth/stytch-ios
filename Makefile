.PHONY: coverage codegen docs format lint setup test tests tools

coverage:
	@if [ ! -f $$(Scripts/coverage instr-profile-path) ]; then $(MAKE) test; fi
	arch -arm64 Scripts/coverage generate-html

codegen:
	arch -arm64 mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

docs: codegen
	arch -arm64 xcodebuild docbuild -scheme StytchCore -configuration Release -sdk iphoneos$$(xcodebuild -showsdks | grep iphoneos | sed 's/\(.*iphoneos\)\(.*\)/\2/') -destination generic/platform=iOS -derivedDataPath .build
	arch -arm64 $$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs

format:
	arch -arm64 mint run swiftformat .

lint:
	arch -arm64 mint run swiftlint lint --quiet
	arch -arm64 mint run swiftformat --lint .

setup:
	arch -arm64 brew bundle

test tests: codegen
	arch -arm64 swift test --enable-code-coverage

tools:
	arch -arm64 mint bootstrap
