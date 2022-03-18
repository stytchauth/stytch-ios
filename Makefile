bootstrap-tools:
	mint bootstrap --link

format:
	mint run swiftformat .

lint:
	mint run swiftlint lint

setup:
	brew bundle
