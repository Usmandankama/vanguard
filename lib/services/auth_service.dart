import 'base_api_service.dart';

class AuthService {
  // Auth endpoints
  static Future<Map<String, dynamic>> signup(String name, String email, String password, String role) async {
    return BaseApiService.post('/api/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }
  
  static Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await BaseApiService.post('/api/auth/signin', {
      'email': email,
      'password': password,
    });
    
    // Store token and user data on successful login
    if (response['success'] == true && response['data']['token'] != null) {
      await BaseApiService.storeToken(response['data']['token']);
      
      // Store user data for persistence
      if (response['data']['user'] != null) {
        await BaseApiService.storeUser(response['data']['user']);
      }
      
      ApiLogger.logResponse(200, response.toString());
    }
    
    return response;
  }
  
  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return BaseApiService.post('/api/auth/refresh', {'token': token});
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await BaseApiService.get('/api/auth/me');
    } catch (e) {
      // If getting current user fails, try to return stored user data
      final storedUser = await BaseApiService.getStoredUser();
      if (storedUser != null) {
        return {
          'success': true,
          'data': {
            'user': storedUser
          }
        };
      }
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    await BaseApiService.removeToken();
  }
}
