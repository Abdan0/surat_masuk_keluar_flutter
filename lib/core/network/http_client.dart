import 'package:http/http.dart' as http;
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;

class AuthorizedHttpClient {
  // GET dengan penanganan token
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      final token = await UserService.getToken();
      final Map<String, String> authHeaders = {
        'Accept': 'application/json',
        'Authorization': token,
        ...?headers,
      };
      
      var response = await http.get(Uri.parse(url), headers: authHeaders);
      
      // Handle 401
      if (response.statusCode == 401) {
        // Coba refresh token
        final refreshed = await UserService.refreshToken();
        if (refreshed) {
          // Get token baru
          final newToken = await UserService.getToken();
          authHeaders['Authorization'] = newToken;
          
          // Coba request lagi
          response = await http.get(Uri.parse(url), headers: authHeaders);
        }
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // POST dengan penanganan token
  static Future<http.Response> post(
    String url, 
    {Map<String, String>? headers, dynamic body}
  ) async {
    try {
      final token = await UserService.getToken();
      final Map<String, String> authHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
        ...?headers,
      };
      
      var response = await http.post(Uri.parse(url), headers: authHeaders, body: body);
      
      // Handle 401
      if (response.statusCode == 401) {
        // Coba refresh token
        final refreshed = await UserService.refreshToken();
        if (refreshed) {
          // Get token baru
          final newToken = await UserService.getToken();
          authHeaders['Authorization'] = newToken;
          
          // Coba request lagi
          response = await http.post(Uri.parse(url), headers: authHeaders, body: body);
        }
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
}