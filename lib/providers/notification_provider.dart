import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  final String? _userId;

  NotificationNotifier(this._ref, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      fetchNotifications();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final ApiService _apiService = ApiService();
  Set<String> _notifiedIds = {};

  Future<void> fetchNotifications() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load notified IDs specific to this user
      final notifiedKey = 'notified_notification_ids_$_userId';
      _notifiedIds = (prefs.getStringList(notifiedKey) ?? []).toSet();

      final response = await _apiService.get('/notifications');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final list = data.map((e) => NotificationModel.fromMap(e)).toList();

        // Check for new notifications to show local push notification
        bool prefsUpdated = false;
        for (final notification in list) {
          if (!_notifiedIds.contains(notification.id)) {
            // Trigger local push notification
            await NotificationService.instance.showNotification(
              title: notification.title,
              body: notification.body,
            );
            _notifiedIds.add(notification.id);
            prefsUpdated = true;
          }
        }

        if (prefsUpdated) {
          await prefs.setStringList(notifiedKey, _notifiedIds.toList());
        }

        if (!mounted) return;
        state = AsyncValue.data(list);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    if (_userId == null) return;
    try {
      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((n) {
          if (n.id == id) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              createdAt: n.createdAt,
              isRead: true,
            );
          }
          return n;
        }).toList();
        state = AsyncValue.data(updatedList);
      }
      
      await _apiService.post('/notifications/$id/read', {});
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    try {
      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((n) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            body: n.body,
            createdAt: n.createdAt,
            isRead: true,
          );
        }).toList();
        state = AsyncValue.data(updatedList);
      }

      await _apiService.post('/notifications/read-all', {});
    } catch (e) {
      // ignore
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final authState = ref.watch(authProvider);
  return NotificationNotifier(ref, authState.userId);
});

class LastReadTimestampNotifier extends StateNotifier<DateTime?> {
  LastReadTimestampNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt('last_read_notifications_timestamp');
      if (ms != null) {
        state = DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> updateLastRead(DateTime time) async {
    state = time;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_read_notifications_timestamp', time.millisecondsSinceEpoch);
    } catch (e) {
      // ignore
    }
  }
}

final lastReadTimestampProvider =
    StateNotifierProvider<LastReadTimestampNotifier, DateTime?>((ref) {
  return LastReadTimestampNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.maybeWhen(
    data: (list) {
      return list.where((n) => !n.isRead).length;
    },
    orElse: () => 0,
  );
});


