import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class EmergencyService {
  Future<Map<String, dynamic>> triggerEmergency({
    required File audioFile,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    // Sends multipart data to FastAPI: /trigger-emergency
    final uri = Uri.parse('${AppConstants.backendBaseUrl}/trigger-emergency');
    final request = http.MultipartRequest('POST', uri)
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..fields['user_id'] = userId
      ..files.add(await http.MultipartFile.fromPath('audio_file', audioFile.path));

    final streamed = await request.send();
    final responseText = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 400) {
      throw Exception('Emergency API failed: $responseText');
    }

    return jsonDecode(responseText) as Map<String, dynamic>;
  }
}
