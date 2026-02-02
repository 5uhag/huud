# HUUD - Professional System Monitor

A minimalist, real-time system monitoring dashboard for Android. Monitor your laptop's CPU, RAM, GPU, Battery, and Network stats from your phone.

## Features

- **Real-time Stats**: CPU load (per-core), RAM usage, GPU metrics, Battery status
- **Network Monitoring**: Live upload/download speeds, active listening ports
- **Interactive Details**: Tap any card to see detailed breakdowns
- **Universal Configuration**: Works on any local network - just enter your laptop's IP
- **Crypto Tickers**: Live BTC/ETH prices from Binance

## Quick Start

### 1. Start the Server (Laptop)

```bash
cd backend
pip install -r requirements.txt
python app.py
```

The server will print your local IP address:
```
[HUUD SERVER] Running on: 192.168.1.5:5000
[HUUD SERVER] Enter this IP in your Mobile App Settings.
```

### 2. Configure the App (Phone)

**Download the APK:**
1. Go to [GitHub Actions](https://github.com/5uhag/huud/actions)
2. Click the latest successful "Build Android APK" workflow run (green checkmark ✓)
3. Scroll down to "Artifacts" and download `release-apk`
4. Extract the ZIP and install the APK on your phone

**Setup:**
1. Open HUUD
2. **Long-press** the title "HUUD // SYS"
3. Enter the IP address shown in your terminal
4. Tap **SAVE**

## Requirements

- **Backend**: Python 3.8+, Windows/Linux
- **Frontend**: Android 8.0+ (API 26)
- **Network**: Both devices on the same WiFi/LAN

## Resource Usage

The Flask server is extremely lightweight:
- **CPU**: <1% idle, ~2-3% during active monitoring
- **RAM**: ~30-50 MB
- **Network**: Minimal (stats sent every 3 seconds, ~1KB per request)

## Stopping the Server

The server runs **only while the terminal is open**. To stop it:
- Press `Ctrl+C` in the terminal
- Or simply close the terminal window

**Note**: Closing Antigravity/VS Code will automatically terminate the server process.

## Tech Stack

- **Backend**: Flask, psutil, GPUtil (NVIDIA GPU support)
- **Frontend**: Flutter (Dart)
- **CI/CD**: GitHub Actions (automatic APK builds)

## License

MIT License - See [LICENSE](LICENSE) for details.
