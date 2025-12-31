import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

/// Service responsible for interacting with the remote MockAPI backend.
class ApiService {
  // Replace this with your MockAPI endpoint from https://mockapi.io
  // Example: https://675d1234abcdef.mockapi.io/api/v1/locations
  static const String _baseUrl = 'https://6754e1f936bcd1eec850a7ad.mockapi.io/api/v1/locations';

  /// Fetches all stored locations.
  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        return jsonList.map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch data (${response.statusCode}).');
      }
    } catch (e) {
      rethrow; // Let caller decide how to surface error.
    }
  }

  /// Adds a new location. Returns true if creation succeeded.
  Future<bool> addLocation(LocationModel model) async {
    try {
      final requestBody = model.toJson();
      print('POST Request to: $_baseUrl');
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: const {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Accept both 200 and 201 as success
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding location: $e');
      return false; // Network error or parsing issue.
    }
  }
}
