import 'dart:convert';

import 'package:http/http.dart' as http;

class YnoughApi {
  YnoughApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUri = Uri.parse(baseUrl ?? _defaultBaseUrl);

  static const _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  final http.Client _client;
  final Uri _baseUri;

  Future<List<ApiTeam>> fetchTeams() async {
    final response = await _get('/api/teams');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((team) => ApiTeam.fromJson(team as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<ApiTeam> createTeam({
    required String name,
    required String player1,
    required String player2,
  }) async {
    final response = await _send(
      'POST',
      '/api/teams',
      body: {
        'name': name,
        'player_1': player1,
        'player_2': player2,
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiTeam.fromJson(data);
  }

  Future<void> deleteTeam(int teamId) async {
    await _send('DELETE', '/teams/$teamId');
  }

  Future<ApiMatch> createMatch({
    required int team1Id,
    required int team2Id,
    required DateTime date,
    String status = 'in_progress',
  }) async {
    final response = await _send(
      'POST',
      '/api/matches',
      body: {
        'id_team1': team1Id,
        'id_team2': team2Id,
        'status': status,
        'date': date.toIso8601String(),
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiMatch.fromJson(data);
  }

  Future<ApiMatch> updateMatchStatus({
    required int matchId,
    required String status,
  }) async {
    final response = await _send(
      'PATCH',
      '/api/matches/$matchId/status',
      body: {'status': status},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiMatch.fromJson(data);
  }

  Future<ApiMatch> updateMatchScore({
    required int matchId,
    required int team1Score,
    required int team2Score,
  }) async {
    final response = await _send(
      'PATCH',
      '/api/matches/$matchId/score',
      body: {
        'score_team1': team1Score,
        'score_team2': team2Score,
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiMatch.fromJson(data);
  }

  Future<List<ApiMatch>> fetchMatches({String? status}) async {
    final response = await _get(
      '/api/matches',
      queryParameters: status == null ? null : {'status': status},
    );
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((match) => ApiMatch.fromJson(match as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    return _send('GET', path, queryParameters: queryParameters);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _baseUri.replace(
      path: _joinPath(_baseUri.path, path),
      queryParameters: queryParameters,
    );
    late final http.Response response;
    if (method == 'GET') {
      response = await _client.get(uri);
    } else if (method == 'POST') {
      response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } else if (method == 'DELETE') {
      response = await _client.delete(uri);
    } else if (method == 'PATCH') {
      response = await _client.patch(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } else {
      throw ApiException('Unsupported HTTP method: $method');
    }
    if (response.statusCode >= 400) {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
    return response;
  }

  String _joinPath(String basePath, String path) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}

class ApiTeam {
  const ApiTeam({
    required this.id,
    required this.name,
    required this.player1,
    required this.player2,
  });

  factory ApiTeam.fromJson(Map<String, dynamic> json) {
    return ApiTeam(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      player1: json['player_1'] as String? ?? '',
      player2: json['player_2'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String player1;
  final String player2;

  List<String> get players => [player1, player2].where((player) => player.isNotEmpty).toList();
}

class ApiMatch {
  const ApiMatch({
    required this.id,
    required this.team1Id,
    required this.team2Id,
    required this.team1Score,
    required this.team2Score,
    required this.status,
    required this.date,
  });

  factory ApiMatch.fromJson(Map<String, dynamic> json) {
    return ApiMatch(
      id: _asInt(json['id']),
      team1Id: _asInt(json['id_team1']),
      team2Id: _asInt(json['id_team2']),
      team1Score: _asInt(json['score_team1']),
      team2Score: _asInt(json['score_team2']),
      status: json['status'] as String? ?? 'scheduled',
      date: DateTime.tryParse(json['date'] as String? ?? ''),
    );
  }

  final int id;
  final int team1Id;
  final int team2Id;
  final int team1Score;
  final int team2Score;
  final String status;
  final DateTime? date;
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value') ?? 0;
}
