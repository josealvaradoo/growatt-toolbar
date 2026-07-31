.PHONY: build app dmg clean all

APP_NAME := GrowattToolbarApp
BUNDLE_NAME := Growatt Toolbar
DMG_NAME := GrowattToolbar
VERSION := 0.5.0
BUILD_DIR := .build/release
APP_BUNDLE := $(BUNDLE_NAME).app
DMG_FILE := $(DMG_NAME).dmg

build:
	@echo "==> Building $(APP_NAME) in release configuration..."
	swift build -c release
	@echo "==> Build complete."

app: build
	@echo "==> Assembling $(APP_BUNDLE)..."
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	cp "$(BUILD_DIR)/$(APP_NAME)" "$(APP_BUNDLE)/Contents/MacOS/"
	cp Resources/Info.plist "$(APP_BUNDLE)/Contents/"
	cp -R src/GrowattToolbarApp/Resources/* "$(APP_BUNDLE)/Contents/Resources/"
	@echo "==> Ad-hoc codesigning..."
	codesign --force --deep --sign - "$(APP_BUNDLE)"
	@echo "==> App bundle ready: $(APP_BUNDLE)"

dmg: app
	@echo "==> Creating $(DMG_FILE)..."
	hdiutil create -volname "$(DMG_NAME)" -srcfolder "$(APP_BUNDLE)" -ov -format UDZO "$(DMG_FILE)"
	@echo "==> DMG ready: $(DMG_FILE)"

clean:
	@echo "==> Cleaning..."
	rm -rf .build
	rm -rf "$(APP_BUNDLE)"
	rm -f "$(DMG_FILE)"
	@echo "==> Clean complete."

all: dmg
