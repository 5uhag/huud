import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Laptop Flask Server Endpoint
  // Default fallback if not set
  static String _laptopIp = '192.168.29.20';
  static const String _port = '5000';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('laptop_ip');
      if (savedIp != null && savedIp.isNotEmpty) {
        _laptopIp = savedIp;
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  static Future<void> setIp(String ip) async {
    _laptopIp = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('laptop_ip', ip);
  }

  static String get currentIp => _laptopIp;

  // Binance API Endpoint
  static const String _binanceBaseUrl =
      'https://api.binance.com/api/v3/ticker/24hr';

  // Fetch Laptop Stats
  static Future<Map<String, dynamic>> fetchLaptopStats() async {
    final url = 'http://$_laptopIp:$_port/api/stats';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load laptop stats');
      }
    } catch (e) {
      throw Exception('Error fetching laptop stats: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchTicker(String symbol) async {
    try {
      final response =
          await http.get(Uri.parse('$_binanceBaseUrl?symbol=$symbol'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Normalize to match our UI expectations
        return {
          'close': data['lastPrice'],
          'open_interest': 'N/A', // Binance public ticker doesn't have OI
          'funding_rate': data['priceChangePercent'] // Reusing this for "24h %"
        };
      } else {
        debugPrint('Crypto API Error: ${response.statusCode} ${response.body}');
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching crypto stats: $e');
      return {};
    }
  }
}
