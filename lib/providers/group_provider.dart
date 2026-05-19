import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class GroupMember {
  final String id;
  final String email;
  final String? displayName;

  GroupMember({required this.id, required this.email, this.displayName});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }
}

class GroupInfo {
  final String id;
  final String name;
  final String joinCode;
  final List<GroupMember> users;

  GroupInfo({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.users,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    var usersList = json['users'] as List? ?? [];
    return GroupInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      joinCode: json['joinCode'] as String,
      users: usersList.map((u) => GroupMember.fromJson(u)).toList(),
    );
  }
}

class GroupNotifier extends AsyncNotifier<GroupInfo?> {
  final ApiService _apiService = ApiService();

  @override
  Future<GroupInfo?> build() async {
    final auth = ref.watch(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      return null;
    }
    return _fetchGroup();
  }

  Future<GroupInfo?> _fetchGroup() async {
    try {
      final response = await _apiService.get('/groups/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          return GroupInfo.fromJson(data);
        }
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGroup());
  }
}

final groupProvider = AsyncNotifierProvider<GroupNotifier, GroupInfo?>(() {
  return GroupNotifier();
});
