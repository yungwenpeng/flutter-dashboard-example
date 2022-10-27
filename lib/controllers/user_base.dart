import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'controllers.dart';
import '../storage/storage.dart';

class UserBaseController {
  String? _token;
  String? _refreshToken;
  AuthUser? _authUser;
  BaseStorage? _storage;
  bool _refreshTokenPending = false;
  final DioClientController dioClient;

  UserBaseController({required this.dioClient}) {
    _storage = InMemoryStorage();
  }

  Future<void> _clearJwtToken() async {
    await _setUserFromJwtToken(null, null, true);
  }

  Future<void> _setUserFromJwtToken(
      String? jwtToken, String? refreshToken, bool? notify) async {
    //print('UserBaseController _setUserFromJwtToken jwtToken: $jwtToken');
    //inspect(_storage);
    if (jwtToken == null) {
      _token = null;
      _refreshToken = null;
      await _storage?.deleteItem('jwt_token');
      await _storage?.deleteItem('refresh_token');
    } else {
      _token = jwtToken;
      _refreshToken = refreshToken;
      var decodedToken = JwtDecoder.decode(jwtToken);
      _authUser = AuthUser.fromJson(decodedToken);
      await _storage?.setItem('jwt_token', jwtToken);
      if (refreshToken != null) {
        await _storage?.setItem('refresh_token', refreshToken);
      } else {
        await _storage?.deleteItem('refresh_token');
      }
    }
  }

  Future<void> init() async {
    try {
      var jwtToken = await _storage?.getItem('jwt_token');
      var refreshToken = await _storage?.getItem('refresh_token');
      //print('UserBaseController init - jwtToken: $jwtToken,\nrefreshToken: $refreshToken');
      if (!_isTokenValid(jwtToken)) {
        await refreshJwtToken(refreshToken: refreshToken, notify: true);
      } else {
        await _setUserFromJwtToken(jwtToken, refreshToken, true);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    //inspect(loginRequest);
    final response = await dioClient.post(
      '/api/login',
      data: jsonEncode(loginRequest),
    );
    var loginResponse = LoginResponse.fromJson(response.data);
    //print('UserBaseController login - token: ${loginResponse.token}\nrefreshToken: ${loginResponse.refreshToken}');

    await _setUserFromJwtToken(
        loginResponse.token, loginResponse.refreshToken, true);
    return loginResponse;
  }

  Future<void> logout() async {
    try {
      await _clearJwtToken();
    } catch (e) {
      await _clearJwtToken();
    }
  }

  Future<void> refreshJwtToken(
      {String? refreshToken,
      bool? notify,
      bool interceptRefreshToken = false}) async {
    _refreshTokenPending = true;
    try {
      refreshToken ??= _refreshToken;
      if (_isTokenValid(refreshToken)) {
        var refreshTokenRequest = RefreshTokenRequest(refreshToken!);
        try {
          var response = await dioClient.post('/api/login',
              data: jsonEncode(refreshTokenRequest));
          var loginResponse = LoginResponse.fromJson(response.data);
          await _setUserFromJwtToken(
              loginResponse.token, loginResponse.refreshToken, notify);
        } catch (e) {
          await _clearJwtToken();
          rethrow;
        }
      } else {
        await _clearJwtToken();
        if (interceptRefreshToken) {
          throw Exception('Session expired!');
        }
      }
    } finally {
      _refreshTokenPending = false;
    }
  }

  bool _isTokenValid(String? jwtToken) {
    if (jwtToken != null) {
      try {
        return !JwtDecoder.isExpired(jwtToken);
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  bool isAuthenticated() {
    return _authUser != null;
  }

  AuthUser? getAuthUser() {
    return _authUser;
  }

  String? getJwtToken() {
    return _token;
  }

  bool refreshTokenPending() {
    return _refreshTokenPending;
  }

  bool isSystemAdmin() {
    return _authUser != null && _authUser!.isSystemAdmin();
  }
}

class LoginRequest {
  String email;
  String password;

  LoginRequest(this.email, this.password);

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  String? refreshToken;
  Authority? scope;

  LoginResponse(this.token, this.refreshToken);

  LoginResponse.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        refreshToken = json['refreshToken'],
        scope =
            json['scope'] != null ? authorityFromString(json['scope']) : null;
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest(this.refreshToken);

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

enum Authority {
  sysAdmin,
  tenantAdmin,
  customerUser,
  refreshToken,
  anonymous,
  preVerificationToken
}

Authority authorityFromString(String value) {
  return Authority.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
}

class AuthUser {
  late String? userName;
  late String? email;
  late String? role;
  late Authority authority;

  AuthUser.fromJson(Map<String, dynamic> json) {
    var claims = Map.of(json);
    userName = claims.remove('userName');
    email = claims.remove('email');
    role = claims.remove('role');
    authority = role == 'admin' ? Authority.sysAdmin : Authority.customerUser;
  }

  @override
  String toString() {
    return '{userName: $userName, email: $email, role: $role, authority: $authority}';
  }

  bool isSystemAdmin() {
    return authority == Authority.sysAdmin;
  }
}
