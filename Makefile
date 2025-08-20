ADB_SERIAL ?=

.PHONY: analyze apk-debug apk-release build-and-install build-and-install-release test

analyze:
	./scripts/flutter_invoke.sh analyze

apk-debug:
	./scripts/flutter_invoke.sh pub get && ./scripts/flutter_invoke.sh build apk --debug

apk-release:
	./scripts/flutter_invoke.sh pub get && ./scripts/flutter_invoke.sh build apk --release

test:
	./scripts/flutter_invoke.sh test --coverage

build-and-install:
	@bash scripts/build_install.sh $(if $(ADB_SERIAL),--serial $(ADB_SERIAL),)

build-and-install-release:
	@bash scripts/build_install.sh --release $(if $(ADB_SERIAL),--serial $(ADB_SERIAL),)
