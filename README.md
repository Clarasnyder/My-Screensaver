# My Screensaver

This project is wrapped as a native macOS screensaver bundle.

The installed screensaver lives here:

```text
~/Library/Screen Savers/MyScreensaver.saver
```

If you edit `index.html`, `styles.css`, or `script.js`, rebuild and reinstall it with:

```sh
./build-screensaver.sh
```

Then open **System Settings → Screen Saver** and choose **My Screensaver**.

On macOS Sonoma, the visible Screen Saver settings can override legacy `.saver`
bundles with the newer wallpaper/aerial system. For reliable idle activation,
this project also includes a background idle watcher that launches the same
animation as a full-screen app after 60 seconds:

```sh
./install-idle-screensaver.sh
```

Installed app:

```text
~/Applications/My Screensaver.app
```

Installed LaunchAgent:

```text
~/Library/LaunchAgents/com.claramae.myscreensaver.idlewatcher.plist
```
