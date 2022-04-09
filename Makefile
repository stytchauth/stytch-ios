bootstrap-tools:
	mint bootstrap --link

codegen:
	mint run sourcery --templates Resources/Sourcery/Templates --sources Sources --output Sources --parseDocumentation

format:
	mint run swiftformat .

lint:
	mint run swiftlint lint

setup:
	brew bundle
