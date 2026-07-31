.PHONY: build icons app dmg clean all

APP_NAME := GrowattToolbarApp
BUNDLE_NAME := Growatt Toolbar
DMG_NAME := GrowattToolbar
VERSION := 0.5.0
BUILD_DIR := .build/release
DIST_DIR := dist
APP_BUNDLE := $(DIST_DIR)/$(BUNDLE_NAME).app
DMG_FILE := $(DIST_DIR)/$(DMG_NAME).dmg
ICONSET_DIR := $(DIST_DIR)/$(BUNDLE_NAME).iconset
ICNS_FILE := $(DIST_DIR)/$(BUNDLE_NAME).icns

build:
	@echo "==> Building $(APP_NAME) in release configuration..."
	swift build -c release
	@echo "==> Build complete."

icons:
	@echo "==> Generating app icon..."
	mkdir -p "$(DIST_DIR)"
	rm -rf "$(ICONSET_DIR)"
	mkdir -p "$(ICONSET_DIR)"
	sips -z 16 16   Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_16x16.png"
	sips -z 32 32   Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_16x16@2x.png"
	sips -z 32 32   Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_32x32.png"
	sips -z 64 64   Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_32x32@2x.png"
	sips -z 128 128 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_128x128.png"
	sips -z 256 256 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_128x128@2x.png"
	sips -z 256 256 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_256x256.png"
	sips -z 512 512 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_256x256@2x.png"
	sips -z 512 512 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_512x512.png"
	sips -z 1024 1024 Resources/Growatt-G.png --out "$(ICONSET_DIR)/icon_512x512@2x.png"
	iconutil -c icns "$(ICONSET_DIR)" -o "$(ICNS_FILE)"
	@echo "==> Icon generated: $(ICNS_FILE)"

app: build icons
	@echo "==> Assembling $(APP_BUNDLE)..."
	mkdir -p "$(DIST_DIR)"
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	cp "$(BUILD_DIR)/$(APP_NAME)" "$(APP_BUNDLE)/Contents/MacOS/"
	cp Resources/Info.plist "$(APP_BUNDLE)/Contents/"
	cp -R src/GrowattToolbarApp/Resources/* "$(APP_BUNDLE)/Contents/Resources/"
	cp "$(ICNS_FILE)" "$(APP_BUNDLE)/Contents/Resources/"
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
	rm -rf "$(DIST_DIR)"
	@echo "==> Clean complete."

all: dmg
