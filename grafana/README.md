# Grafana Legend Text Copy Feature

This feature adds a one-click copy button to Grafana legend items, allowing you to easily copy legend text.

## Installation Options

### Option 1: Add to Dashboard JSON

1. Go to your dashboard settings
2. Click on "JSON Model"
3. Add the following to your dashboard JSON:

```json
"panels": [
  // Your existing panels...
],
"scriptedDashboard": {
  "js": "// Include the content of copy-legend-text.js here"
}
```

### Option 2: Add to Grafana custom.js (if you have server access)

1. Locate your Grafana installation directory
2. Find or create the `public/dashboards/custom.js` file
3. Add the content of `copy-legend-text.js` to this file
4. Restart Grafana

### Option 3: Use as a browser bookmarklet

1. Create a new bookmark in your browser
2. Name it "Grafana Copy Legend"
3. In the URL/location field, paste:
   ```
   javascript:(function(){const script=document.createElement('script');script.src='https://your-server/path/to/copy-legend-text.js';document.body.appendChild(script);})();
   ```
   (Replace with the actual path where you host the script)
4. Click the bookmark when viewing a Grafana dashboard

## How It Works

The script adds a small clipboard icon (📋) next to each legend item. When clicked, it copies the legend text to your clipboard and shows a checkmark (✓) to confirm the copy was successful.

## Features

- Works with both table and list mode legends
- Compatible with time series and other panel types
- Shows visual feedback when text is copied
- Automatically handles dynamically loaded panels
- Minimal and non-intrusive UI