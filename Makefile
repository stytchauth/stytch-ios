bootstrap-tools:
	mint bootstrap

coverage:
	Scripts/coverage generate-html

codegen:
	mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

format:
	mint run swiftformat .

lint:
	mint run swiftlint lint --quiet
	mint run swiftformat --lint --quiet .

setup:
	brew bundle
