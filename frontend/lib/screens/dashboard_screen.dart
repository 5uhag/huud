import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/pro_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Laptop Stats
  Map<String, dynamic> _laptopStats = {};
  bool _laptopStatsLoading = true;
  bool _laptopConnected = false;
  bool _laptopIpEmpty = true;

  // Tech Stats - Speed
  double _uploadSpeed = 0.0;
  double _downloadSpeed = 0.0;
  int _lastBytesSent = 0;
  int _lastBytesRecv = 0;

  // Tech Stats - Latency
  int _latencyMs = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    // Refresh stats every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // _fetchData is superseded by _checkConnection

  Future<void> _checkConnection() async {
    final ip = ApiService.currentIp;
    if (ip.isEmpty) {
      if (mounted) {
        setState(() {
          _laptopIpEmpty = true;
          _laptopConnected = false;
          _laptopStatsLoading = false;
        });
      }
      return;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final stats = await ApiService.fetchLaptopStats();
      stopwatch.stop();

      if (mounted) {
        // Calculate Speed before setState to ensure vars are updated
        if (stats['net_io'] != null) {
          final int currentSent = stats['net_io']['bytes_sent'] ?? 0;
          final int currentRecv = stats['net_io']['bytes_recv'] ?? 0;

          if (_lastBytesSent != 0) {
            final sentDelta = currentSent - _lastBytesSent;
            final recvDelta = currentRecv - _lastBytesRecv;

            if (sentDelta >= 0 && recvDelta >= 0) {
              _uploadSpeed = (sentDelta / 1024 / 1024) / 3.0;
              _downloadSpeed = (recvDelta / 1024 / 1024) / 3.0;
            }
          }
          _lastBytesSent = currentSent;
          _lastBytesRecv = currentRecv;
        }

        setState(() {
          _laptopIpEmpty = false;
          _laptopConnected = true;
          _laptopStats = stats;
          _latencyMs = stopwatch.elapsedMilliseconds;
          _laptopStatsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _laptopIpEmpty = false; // IP exists, just offline
          _laptopConnected = false;
          _laptopStatsLoading = false;
          _latencyMs = 999;
          _uploadSpeed = 0.0;
          _downloadSpeed = 0.0;
        });
      }
    }
  }

  void _showDetails(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep matte black
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLandscape = constraints.maxWidth > constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (isLandscape)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildSystemStatsGrid()),
                        Container(width: 1, color: Colors.grey[800]),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: _buildAuxColumn(),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSystemStatsGrid(),
                        const SizedBox(height: 16),
                        _buildAuxColumn(),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onLongPress: _showSettings,
          child: const Text(
            "HUUD // SYS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Row(
          children: [
            // Removed Icon Button, now hidden in Long Press
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _laptopConnected ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _laptopIpEmpty
                  ? "SETUP REQUIRED"
                  : (_laptopConnected ? "ONLINE" : "OFFLINE"),
              style: TextStyle(
                  color: _laptopIpEmpty
                      ? Colors.orange
                      : (_laptopConnected ? Colors.white : Colors.red),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0),
            ),
          ],
        )
      ],
    );
  }

  void _showSettings() {
    final TextEditingController ipController =
        TextEditingController(text: ApiService.currentIp);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("SETTINGS",
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Laptop IP Address",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: ipController,
              style:
                  const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none),
                hintText: "192.168.x.x",
                hintStyle: TextStyle(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Current: ${ApiService.currentIp}",
              style: const TextStyle(
                  color: Colors.green, fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newIp = ipController.text.trim();
              await ApiService.setIp(newIp);
              if (mounted) {
                Navigator.pop(context);
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("IP set to: $newIp"),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
                _checkConnection(); // Retry connection immediately
              }
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatsGrid() {
    if (_laptopStatsLoading && _laptopStats.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    // Default values
    final cpu = _laptopStats['cpu'] ?? 0;
    final ram = _laptopStats['ram'] ?? 0;
    final ramDetails = _laptopStats['ram_details'] ?? "0/0 GB";
    final battery = _laptopStats['battery'] ?? 0;
    final plugged = _laptopStats['is_plugged'] ?? false;

    // GPU
    final gpuData = _laptopStats['gpu'];
    final gpuLoad = gpuData != null ? gpuData['load'] : 0.0;
    final gpuMem = gpuData != null
        ? "${gpuData['memoryUsed']}/${gpuData['memoryTotal']} GB"
        : "N/A";
    final gpuTemp = gpuData != null ? "${gpuData['temperature']} \u00B0C" : "";

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        ProCard(
          title: "Cpu Load",
          value: "$cpu%",
          subValue: "CORES: ${_laptopStats['cpu_cores']?.length ?? 'N/A'}",
          icon: Icons.memory,
          progress: cpu / 100,
          onTap: () {
            final cores = _laptopStats['cpu_cores'] as List? ?? [];
            _showDetails(
                "Cpu Cores",
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cores
                      .map((c) => Chip(
                            label: Text("$c%",
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.grey[900],
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ));
          },
        ),
        ProCard(
          title: "Ram Usage",
          value: "$ram%",
          subValue: ramDetails,
          icon: Icons.storage,
          progress: ram / 100,
          onTap: () {
            final processes = _laptopStats['processes'] as List? ?? [];
            _showDetails(
                "Top Processes (RAM)",
                Column(
                  children: processes
                      .map((p) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(p['name'],
                                style: const TextStyle(color: Colors.white)),
                            trailing: Text("${p['mem_mb']} MB",
                                style: TextStyle(color: Colors.grey[400])),
                          ))
                      .toList(),
                ));
          },
        ),
        ProCard(
          title: "Gpu Core",
          value: "$gpuLoad%",
          subValue: gpuData != null ? gpuData['name'] : "NO GPU",
          icon: Icons.grid_4x4,
          progress: gpuLoad / 100,
          onTap: () {
            if (gpuData == null) return;
            _showDetails(
                "GPU Stats",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Memory Used", gpuMem),
                    const SizedBox(height: 8),
                    _buildDetailRow("Temperature", gpuTemp),
                    const SizedBox(height: 8),
                    _buildDetailRow("Voltage",
                        "N/A (Req Admin)"), // Placeholder as py libraries rarely give this without kernel access
                  ],
                ));
          },
        ),
        ProCard(
          title: "Battery",
          value: "$battery%",
          subValue: plugged ? "CHARGING" : "BATTERY",
          icon: plugged ? Icons.power : Icons.battery_std,
          progress: battery / 100,
          onTap: () {
            final int seconds = _laptopStats['battery_secs_left'] ?? -1;
            String timeLeft = "Calculating...";

            // psutil: -1=Unknown, -2=Unlimited(Plugged)
            if (plugged) {
              timeLeft = "Charging";
            } else if (seconds > 0) {
              final hours = seconds ~/ 3600;
              final mins = (seconds % 3600) ~/ 60;
              timeLeft = "${hours}h ${mins}m";
            } else {
              timeLeft = "Estimating...";
            }

            _showDetails(
                "Power Stats",
                Column(
                  children: [
                    _buildDetailRow(
                        "Status", plugged ? "Plugged In" : "Discharging"),
                    const SizedBox(height: 8),
                    _buildDetailRow("Time Left", timeLeft),
                    const SizedBox(height: 8),
                    _buildDetailRow("System Uptime",
                        _laptopStats['uptime'] ?? "Loading..."),
                  ],
                ));
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAuxColumn() {
    return Column(
      children: [
        // 1. Network Speed
        SizedBox(
          height: 140,
          child: ProCard(
            title: "Net Speed",
            value: "${_downloadSpeed.toStringAsFixed(1)} MB/s",
            subValue: "UP: ${_uploadSpeed.toStringAsFixed(1)} MB/s",
            icon: Icons.network_check,
            progress:
                (_downloadSpeed / 10.0).clamp(0.0, 1.0), // Cap visual at 10MB/s
            onTap: () {
              _showDetails(
                  "Net Activity",
                  Column(
                    children: [
                      _buildDetailRow(
                          "Down", "${_downloadSpeed.toStringAsFixed(2)} MB/s"),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          "Up", "${_uploadSpeed.toStringAsFixed(2)} MB/s"),
                    ],
                  ));
            },
          ),
        ),
        const SizedBox(height: 12),

        // 2. Latency / Ping
        SizedBox(
          height: 140,
          child: ProCard(
            title: "Latency",
            value: "$_latencyMs ms",
            subValue: "PHONE → PC",
            icon: Icons.speed,
            progress:
                (1.0 - (_latencyMs / 100.0)).clamp(0.0, 1.0), // Good if low
            onTap: () {},
          ),
        ),
        const SizedBox(height: 16),

        // 3. Active Ports (Restored)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("OPEN PORTS",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Icon(Icons.security, color: Colors.grey[700], size: 14),
                ],
              ),
              const SizedBox(height: 12),
              // Get ports from stats
              if ((_laptopStats['ports'] as List? ?? []).isEmpty)
                Text("No active listeners",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13))
              else
                ...(_laptopStats['ports'] as List).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("PORT ${p['port']}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace')),
                          Text("LISTEN",
                              style: TextStyle(
                                  color: Colors.green[400], fontSize: 10)),
                        ],
                      ),
                    )),
            ],
          ),
        )
      ],
    );
  }

  // Crypto helper removed as per user request
}
