import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Laptop Flask Server Endpoint
  // TODO: Make this configurable in settings
  static const String _laptopUrl = 'http://192.168.29.20:5000/api/stats';

  // Binance API Endpoint
  static const String _binanceBaseUrl =
      'https://api.binance.com/api/v3/ticker/24hr';

  // Fetch Laptop Stats
  static Future<Map<String, dynamic>> fetchLaptopStats() async {
    try {
      final response = await http
          .get(Uri.parse(_laptopUrl))
          .timeout(const Duration(seconds: 2));
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
