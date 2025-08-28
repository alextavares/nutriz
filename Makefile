ADB_SERIAL ?=
# App/package and default serials
APP_ID ?= com.nutritracker.app
RUN_SERIAL ?= emulator-5554
IDLE_SERIAL ?= emulator-5556

# Optional AVD names for starting emulators (use `make emu-list` to discover)
AVD1 ?=
AVD2 ?=

.PHONY: analyze apk-debug apk-release build-and-install build-and-install-release test \
        emu-list emu-start-two app-run-one app-run-one-fast app-stop app-stop-both \
        compare-all

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

compare-all: compare-home compare-search compare-progress compare-profile

# ---- Emulator helpers ----
emu-list:
	@echo "==> Available emulators (AVDs)" && ./scripts/flutter_invoke.sh emulators || true
	@echo "\n==> Connected devices" && adb devices -l || true

# Start two specific AVDs (pass AVD1=... AVD2=...). Then wait for RUN/IDLE serials.
emu-start-two:
	@if [ -z "$(AVD1)" ] || [ -z "$(AVD2)" ]; then \
		echo "Usage: make emu-start-two AVD1=<name> AVD2=<name>"; \
		echo "Hint: run 'make emu-list' to see AVD names."; \
		exit 1; \
	fi
	@echo "==> Launching $(AVD1)" && ./scripts/flutter_invoke.sh emulators --launch "$(AVD1)" || true
	@echo "==> Launching $(AVD2)" && ./scripts/flutter_invoke.sh emulators --launch "$(AVD2)" || true
	@echo "==> Waiting for devices: $(RUN_SERIAL), $(IDLE_SERIAL)"; \
	  adb -s "$(RUN_SERIAL)" wait-for-device || true; \
	  adb -s "$(IDLE_SERIAL)" wait-for-device || true

# Install + run app on RUN_SERIAL and keep it stopped on IDLE_SERIAL
app-run-one:
	@$(MAKE) build-and-install ADB_SERIAL=$(RUN_SERIAL)
	@echo "==> Starting $(APP_ID) on $(RUN_SERIAL)"; \
	  adb -s "$(RUN_SERIAL)" shell monkey -p "$(APP_ID)" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || \
	  adb -s "$(RUN_SERIAL)" shell am start -n "$(APP_ID)/.MainActivity" >/dev/null 2>&1 || true
	@echo "==> Stopping $(APP_ID) on $(IDLE_SERIAL)"; \
	  adb -s "$(IDLE_SERIAL)" shell am force-stop "$(APP_ID)" >/dev/null 2>&1 || true
	@echo "App running on $(RUN_SERIAL); stopped on $(IDLE_SERIAL)."

# Run/stop without rebuilding or installing
app-run-one-fast:
	@echo "==> Starting $(APP_ID) on $(RUN_SERIAL)"; \
	  adb -s "$(RUN_SERIAL)" shell monkey -p "$(APP_ID)" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || \
	  adb -s "$(RUN_SERIAL)" shell am start -n "$(APP_ID)/.MainActivity" >/dev/null 2>&1 || true
	@echo "==> Stopping $(APP_ID) on $(IDLE_SERIAL)"; \
	  adb -s "$(IDLE_SERIAL)" shell am force-stop "$(APP_ID)" >/dev/null 2>&1 || true

# Stop the app on a specific device: make app-stop SERIAL=emulator-5556
app-stop:
	@if [ -z "$(SERIAL)" ]; then echo "Usage: make app-stop SERIAL=<adb-serial>"; exit 1; fi
	@adb -s "$(SERIAL)" shell am force-stop "$(APP_ID)"

app-stop-both:
	@adb -s "$(RUN_SERIAL)"  shell am force-stop "$(APP_ID)" >/dev/null 2>&1 || true
	@adb -s "$(IDLE_SERIAL)" shell am force-stop "$(APP_ID)" >/dev/null 2>&1 || true
