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

compare-home:
	./scripts/compare_capture.sh --screen home --mode dark --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554}
	./scripts/compare_capture.sh --screen home --mode light --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554}
	./scripts/gen_compare_html.sh home

compare-search:
	./scripts/compare_capture.sh --screen search --mode dark --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/compare_capture.sh --screen search --mode light --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/gen_compare_html.sh search

compare-progress:
	./scripts/compare_capture.sh --screen progress --mode dark --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/compare_capture.sh --screen progress --mode light --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/gen_compare_html.sh progress

compare-profile:
	./scripts/compare_capture.sh --screen profile --mode dark --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/compare_capture.sh --screen profile --mode light --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true
	./scripts/gen_compare_html.sh profile


# i18n capture for Home (dark only) across locales
LOCALES ?= en-US es-ES pt-BR
compare-home-i18n:
	@for L in $(LOCALES); do \
		echo "==> Capturing Home for locale $$L (dark)"; \
		./scripts/compare_capture.sh --screen home_$${L} --mode dark --locale $$L --nutri-serial $${NUTRI_SERIAL:-emulator-5556} --yazio-serial $${YAZIO_SERIAL:-emulator-5554} || true; \
		./scripts/gen_compare_html.sh home_$${L}; \
	done
