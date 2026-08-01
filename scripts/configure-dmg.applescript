tell application "Finder"
    tell disk "Growatt Toolbar"
        open
        delay 2

        set installerWindow to container window
        set current view of installerWindow to icon view
        set toolbar visible of installerWindow to false
        set statusbar visible of installerWindow to false
        set sidebar width of installerWindow to 0
        set bounds of installerWindow to {100, 100, 800, 550}

        tell icon view options of installerWindow
            set icon size to 90
            set arrangement to not arranged
            set background picture to POSIX file "/Volumes/Growatt Toolbar/.background/background.png"
        end tell
 
        set position of item "Growatt Toolbar.app" to {140, 220}
        set position of item "Applications" to {330, 220}

        close installerWindow
        open
    end tell
end tell
