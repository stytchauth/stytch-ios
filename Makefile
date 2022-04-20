bootstrap-tools:
	mint bootstrap

coverage:
	Scripts/coverage generate-html

codegen:
	mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

documentation:
	xcodebuild docbuild -scheme StytchCore -sdk iphoneos15.4 -destination generic/platform=iOS -derivedDataPath .build
	$$(xcrun --find docc) process-archive transform-for-static-hosting .build/Build/Products/Debug-iphoneos/StytchCore.doccarchive --output-path .build/docs

format:
	mint run swiftformat .

lint:
	mint run swiftlint lint --quiet
	mint run swiftformat --lint --quiet .

setup:
	brew bundle
