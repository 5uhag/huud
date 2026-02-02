from flask import Flask, jsonify
from flask_cors import CORS
import psutil
import GPUtil
import platform

app = Flask(__name__)
# Allow CORS to enable access from the Flutter app on the same network
CORS(app)

@app.route('/api/stats', methods=['GET'])
def get_stats():
    # CPU usage percentage
    cpu_percent = psutil.cpu_percent(interval=None)
    cpu_cores = psutil.cpu_percent(interval=None, percpu=True)
    
    # RAM usage
    virtual_memory = psutil.virtual_memory()
    ram_percent = virtual_memory.percent
    ram_used_gb = round(virtual_memory.used / (1024 ** 3), 1)
    ram_total_gb = round(virtual_memory.total / (1024 ** 3), 1)
    
    # Battery
    battery = psutil.sensors_battery()
    battery_info = {
        "percent": round(battery.percent, 1) if battery else 0,
        "is_plugged": battery.power_plugged if battery else False,
        "secs_left": battery.secsleft if battery else -1
    }
    
    # GPU (NVIDIA) - Attempt to get more details like Voltage/Power if possible
    gpu_info = None
    try:
        gpus = GPUtil.getGPUs()
        if gpus:
            gpu = gpus[0]
            gpu_info = {
                "load": round(gpu.load * 100, 1),
                "memoryUsed": round(gpu.memoryUsed / 1024, 2),
                "memoryTotal": round(gpu.memoryTotal / 1024, 2),
                "temperature": gpu.temperature,
                "name": gpu.name
            }
    except:
        pass

    # Active Connections (Top 5 Listening Ports)
    connections = []
    try:
        # Requires admin privs for full details on windows usually, but basic check works
        for conn in psutil.net_connections(kind='inet'):
            if conn.status == 'LISTEN' and conn.laddr:
                connections.append({
                    "port": conn.laddr.port,
                    "status": conn.status
                })
        # Limit to top 5 unique ports
        seen_ports = set()
        unique_connections = []
        for c in connections:
            if c['port'] not in seen_ports:
                unique_connections.append(c)
                seen_ports.add(c['port'])
        connections = unique_connections[:5]
    except:
        pass

    # Top 5 RAM Processes
    processes = []
    try:
        # iterate over processes
        for proc in psutil.process_iter(['pid', 'name', 'memory_info']):
            try:
                processes.append(proc.info)
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        # Sort by memory usage (rss)
        processes = sorted(processes, key=lambda p: p['memory_info'].rss, reverse=True)[:5]
        # Format for JSON
        formatted_processes = []
        for p in processes:
            mem_mb = round(p['memory_info'].rss / (1024 * 1024), 1)
            formatted_processes.append({'name': p['name'], 'mem_mb': mem_mb})
    except:
        formatted_processes = []

    # Network IO (for speed calculation)
    net_io = psutil.net_io_counters()

    # Uptime
    try:
        boot_time = psutil.boot_time()
        import time
        uptime_seconds = time.time() - boot_time
        # Format "Xd Xh Xm"
        days = int(uptime_seconds // (24 * 3600))
        uptime_seconds %= (24 * 3600)
        hours = int(uptime_seconds // 3600)
        uptime_seconds %= 3600
        minutes = int(uptime_seconds // 60)
        
        uptime_str = ""
        if days > 0: uptime_str += f"{days}d "
        if hours > 0: uptime_str += f"{hours}h "
        uptime_str += f"{minutes}m"
    except:
        uptime_str = "Unknown"

    return jsonify({
        'cpu': cpu_percent,
        'cpu_cores': cpu_cores,
        'ram': ram_percent,
        'ram_details': f"{ram_used_gb}/{ram_total_gb} GB",
        'processes': formatted_processes,
        'battery': battery_info['percent'],
        'is_plugged': battery_info['is_plugged'],
        'battery_secs_left': battery_info['secs_left'],
        'uptime': uptime_str,
        'gpu': gpu_info,
        'ports': connections,
        'net_io': {
            'bytes_sent': net_io.bytes_sent,
            'bytes_recv': net_io.bytes_recv
        }
    })

if __name__ == '__main__':
    # Initial Setup: Print the Local IP Address for the user
    import socket
    try:
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        print(f"\n[HUUD SERVER] Running on: {local_ip}:5000")
        print(f"[HUUD SERVER] Enter this IP in your Mobile App Settings.\n")
    except:
        print("[HUUD SERVER] Could not detect local IP. Check 'ipconfig'.")

    # Host 0.0.0.0 allows access from external devices (like the phone)
    app.run(host='0.0.0.0', port=5000)
