# 12. Debugging and Monitoring

BlaiseVue offers integrated features to facilitate error identification and application state tracking.

## 🛠️ BVDevTools

The `BVDevTools` unit is automatically injected in **Debug Mode** (`bv run dev`).

### Main features:
- **HUD (Overlay)**: Displays an on-screen overlay in the browser if fatal errors occur during template compilation or reactive directives at runtime.
- **Quick Investigation**: The HUD displays the error message, the source (which directive or component failed), and the JavaScript stack trace in the browser.

## 📜 Console Logs

With the new updates, you can use the following methods from the `BVDevTools` unit in your components (`<script>`) for diagnostics:

### `LogEvent(const Msg: string; Data: JSValue = nil)`
Logs an important event to the console.
- **Style**: White text on a green background (`EVENT`).
- **Usage**: Ideal for tracking user actions or event triggers.

### `LogTrace(const Msg: string; Data: JSValue = nil)`
Traces detailed code snippet execution.
- **Style**: White text on a dark background (`TRACE`).
- **Usage**: Recommended for monitoring data flows or loops.

### `LogError(const Msg, Source: string; Err: JSValue)`
Used internally by the framework but available to display custom errors in the HUD and console (in red).

## 📡 CLI Monitoring

The new workflow (`bv run dev` + `bv serve`) separates monitoring into two channels:

### 1. Application Logs (`bv run dev`)
- Displays the progress of the Pascal to JavaScript compiler.
- Identifies `.bv` syntax errors, missing units, or Pascal compiler (`pas2js`) errors.
- **Tip:** Keep this command open to verify if the build was successful.

### 2. Server Logs (`bv serve`)
- Displays all HTTP requests received by the server.
- Shows `404` errors if you try to access a non-existent file or if an image fails to load.
- Validates the loading of compiled files (`main.js` and `rtl.js`).

## 🛑 Production Removal

When running `bv run build`, the compiler removes the ENTIRE `BVDevTools` unit and the injected log commands (using `$IFNDEF PRODUCTION`). This ensures that your final application is **light, fast, and secure**, without exposing error HUDs or internal logs to end users.
