# Firebase support

## Pascal API
This directory contains the firebase messaging support files for Pas2JS.
The src directory contains the firebaseapp unit which provides an interface
for Firebase Cloud messaging APIs from Google.

##  Support files
The js directory contains the support files needed to make it work. 
The Google API compatibility API is used, the version saved in the js
directory is known to work.

You must use these files in your main HTML file:
```html
  <script src="firebase-app-compat.js"></script>
  <script src="firebase-messaging-compat.js"></script>
```

The firebase-messaging-sw.js file is a small service worker file that you can register
with the following call :
```javascript
Window.Navigator.serviceWorker.register('firebase-messaging-sw.js')
```

A demo application can be found in FPC fcl-web/examples/fcm/webclient

