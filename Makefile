.PHONY: coverage codegen docs format lint setup tools

coverage: test
	Scripts/coverage generate-html

codegen:
	mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

docs: codegen
	
	xcodebuild docbuild -scheme StytchCore -configuration Release -sdk iphoneos$$(xcodebuild -showsdks | grep iphoneos | sed 's/\(.*iphoneos\)\(.*\)/\2/') -destination generic/platform=iOS -derivedDataPath .build
	$$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Release-iphoneos/StytchCore.doccarchive --output-path .build/docs

format:
	mint run swiftformat .

lint:
	mint run swiftlint lint --quiet
	mint run swiftformat --lint --quiet .

setup:
	brew bundle

test: codegen
	swift test --enable-code-coverage

tools:
	mint bootstrap
