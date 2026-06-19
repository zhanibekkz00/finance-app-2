import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/category_model.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    // Read providers safely
    final userId = ref.read(authProvider).userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAdmin = false;
        });
      }
      return;
    }

    final isAdmin = await ref.read(adminProvider.notifier).checkIsAdmin(userId);
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isChecking = false;
      });
      if (isAdmin) {
        ref.read(adminProvider.notifier).loadDashboardData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new support messages inside build method (correct way in Riverpod)
    ref.listen<AdminState>(adminProvider, (previous, next) {
      final prevUnread = previous?.supportMessages.where((msg) => !msg.isRead).length ?? 0;
      final newUnread = next.supportMessages.where((msg) => !msg.isRead).length;
      if (newUnread > prevUnread) {
        final latest = next.supportMessages.firstWhere((msg) => !msg.isRead);
        NotificationService.instance.showNotification(
          title: 'Новое сообщение от пользователя',
          body: latest.message.length > 60 ? '${latest.message.substring(0, 60)}...' : latest.message,
        );
      }
    });

    final adminState = ref.watch(adminProvider);
    final adminL10n = AdminLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                adminL10n.accessDenied,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(adminL10n.noAdminPrivileges),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(adminL10n.goBack),
              ),
            ],
          ),
        ),
      );
    }

    if (adminState.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(adminL10n.adminError),
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  adminL10n.failedLoadAdminData,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  adminState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.read(adminProvider.notifier).loadDashboardData(),
                  icon: const Icon(Icons.refresh),
                  label: Text(adminL10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminL10n.adminDashboard,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            tooltip: adminL10n.logout,
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.blueGrey[50],
            indicatorColor: isDark
                ? Colors.indigoAccent.withOpacity(0.3)
                : Colors.indigo.withOpacity(0.15),
            selectedIconTheme: IconThemeData(
              color: isDark ? Colors.indigoAccent[100] : Colors.indigo,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark ? Colors.white38 : Colors.black38,
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: isDark ? Colors.indigoAccent[100] : Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard),
                label: Text(adminL10n.stats),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.people),
                label: Text(adminL10n.users),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.category),
                label: Text(adminL10n.categories),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.notifications),
                label: Text(adminL10n.notify),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.mail),
                label: Text(adminL10n.messages),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                DashboardTab(),
                UsersTab(),
                CategoriesTab(),
                NotificationsTab(),
                MessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Tabs ---

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final adminL10n = AdminLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (adminState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminState.stats == null) {
      return Center(child: Text(adminL10n.noData));
    }

    final stats = adminState.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              _SummaryCard(
                title: adminL10n.totalUsers,
                value: stats.totalUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                title: adminL10n.totalVolume,
                value: '\$${stats.totalTransactionVolume.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Charts
          Text(
            adminL10n.newUsers7Days,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: stats.newUsersPerDay.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            adminL10n.topCategories,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: stats.popularCategories.map((entry) {
                  final color = Colors
                      .primaries[entry.key.hashCode % Colors.primaries.length];
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
                    radius: 100,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final adminL10n = AdminLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter users
    final filteredUsers = adminState.users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.id.contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: adminL10n.searchUsers,
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                  onPressed: () => ref.refresh(adminProvider),
                  icon: const Icon(Icons.refresh),
                  color: isDark ? Colors.white70 : Colors.black87),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('ID')),
                      const DataColumn(label: Text('Email')),
                      DataColumn(label: Text(adminL10n.role)),
                      DataColumn(label: Text(adminL10n.group)),
                      DataColumn(label: Text(adminL10n.status)),
                      DataColumn(label: Text(adminL10n.actions)),
                    ],
                    rows: filteredUsers.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.id.length > 8
                            ? '${user.id.substring(0, 8)}...'
                            : user.id)),
                        DataCell(
                            Text(user.email.isEmpty ? 'No Email' : user.email)),
                        DataCell(DropdownButton<String>(
                          value: user.role,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          items: [
                            DropdownMenuItem(
                                value: 'user', child: Text(adminL10n.userRole)),
                            DropdownMenuItem(
                                value: 'admin', child: Text(adminL10n.adminRole)),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(adminProvider.notifier)
                                  .updateUserRole(user.id, val);
                            }
                          },
                          underline: Container(),
                        )),
                        DataCell(Text(user.groupName)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isBlocked
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.isBlocked ? adminL10n.blocked : adminL10n.active,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: user.isBlocked
                                    ? Colors.red[300]
                                    : Colors.green[300],
                              ),
                            ),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(user.isBlocked
                                  ? Icons.lock_open
                                  : Icons.block),
                              color: user.isBlocked ? Colors.green : Colors.red,
                              onPressed: () {
                                ref
                                    .read(adminProvider.notifier)
                                    .toggleUserBlockStatus(
                                        user.id, user.isBlocked);
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({super.key});

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  Color _selectedColor = Colors.blue;

  void _showAddCategoryDialog() {
    final adminL10n = AdminLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          adminL10n.addGlobalCategory,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: adminL10n.categoryName,
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            TextField(
              controller: _iconController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: adminL10n.iconCodePoint,
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(builder: (context, setState) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Colors.primaries
                    .map((c) => GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Container(
                            width: 32,
                            height: 32,
                            color: c,
                            child: _selectedColor == c
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(adminL10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final iconCode = int.tryParse(_iconController.text) ?? 58428;
              final newCat = CategoryModel(
                id: '',
                name: _nameController.text,
                colorValue: _selectedColor.value,
                iconCode: iconCode,
                isDefault: true,
              );
              ref.read(adminProvider.notifier).addGlobalCategory(newCat);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(adminL10n.categoryAdded),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(adminL10n.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final adminL10n = AdminLocalizations.of(context);
    final categories = adminState.globalCategories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                adminL10n.globalCategories,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(adminL10n.addNewCategory),
                onPressed: _showAddCategoryDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      adminL10n.noGlobalCategories,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Card(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(cat.colorValue),
                            child: Icon(
                              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            cat.isDefault ? adminL10n.defaultValue : adminL10n.customGlobal,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key});

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  Future<void> _send() async {
    final adminL10n = AdminLocalizations.of(context);
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ref.read(adminProvider.notifier).sendNotification(
            _titleController.text,
            _bodyController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminL10n.notificationQueued),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${adminL10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminL10n = AdminLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                adminL10n.sendGlobalPush,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: adminL10n.title,
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: adminL10n.messageBody,
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _send,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    adminL10n.sendToAll,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (adminState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final messages = adminState.supportMessages;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.adminMessages,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
              ),
              IconButton(
                onPressed: () => ref.read(adminProvider.notifier).loadDashboardData(),
                icon: const Icon(Icons.refresh),
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      l10n.noMessages,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: msg.isRead
                              ? (isDark ? Colors.white.withOpacity(0.02) : Colors.white)
                              : (isDark ? Colors.blue.withOpacity(0.08) : Colors.blue.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: msg.isRead
                                ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
                                : (isDark ? Colors.blueAccent.withOpacity(0.4) : Colors.blueAccent.withOpacity(0.2)),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!msg.isRead)
                                  Container(
                                    width: 4,
                                    color: Colors.blueAccent,
                                  ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: isDark ? Colors.blueGrey[850] : Colors.blueGrey[50],
                                              child: Icon(
                                                Icons.person,
                                                size: 16,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                msg.userEmail,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : Colors.black87,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${msg.createdAt.day}.${msg.createdAt.month}.${msg.createdAt.year} ${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white38 : Colors.black38,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          msg.message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                          ),
                                        ),
                                        if (!msg.isRead) ...[
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                ref.read(adminProvider.notifier).markSupportMessageAsRead(msg.id);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.blueAccent,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  side: const BorderSide(color: Colors.blueAccent, width: 1),
                                                ),
                                              ),
                                              icon: const Icon(Icons.done_all, size: 16),
                                              label: Text(
                                                l10n.markAsRead,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Admin Dashboard Kazakh and Russian Localizations ---
class AdminLocalizations {
  final String languageCode;

  AdminLocalizations(this.languageCode);

  static AdminLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AdminLocalizations(locale.languageCode);
  }

  String get adminDashboard => languageCode == 'kk' ? 'Әкімшілік панелі' : (languageCode == 'ru' ? 'Панель администратора' : 'Admin Dashboard');
  String get stats => languageCode == 'kk' ? 'Статистика' : (languageCode == 'ru' ? 'Статистика' : 'Stats');
  String get users => languageCode == 'kk' ? 'Пайдаланушылар' : (languageCode == 'ru' ? 'Пользователи' : 'Users');
  String get categories => languageCode == 'kk' ? 'Санаттар' : (languageCode == 'ru' ? 'Категории' : 'Categories');
  String get notify => languageCode == 'kk' ? 'Хабарландыру' : (languageCode == 'ru' ? 'Оповещение' : 'Notify');
  String get messages => languageCode == 'kk' ? 'Хабарламалар' : (languageCode == 'ru' ? 'Сообщения' : 'Messages');
  
  String get totalUsers => languageCode == 'kk' ? 'Жалпы пайдаланушылар' : (languageCode == 'ru' ? 'Всего пользователей' : 'Total Users');
  String get totalVolume => languageCode == 'kk' ? 'Жалпы айналым' : (languageCode == 'ru' ? 'Общий объем' : 'Total Volume');
  String get newUsers7Days => languageCode == 'kk' ? 'Жаңа пайдаланушылар (соңғы 7 күн)' : (languageCode == 'ru' ? 'Новые пользователи (7 дней)' : 'New Users (Last 7 Days)');
  String get topCategories => languageCode == 'kk' ? 'Ең танымал санаттар' : (languageCode == 'ru' ? 'Популярные категории' : 'Top Categories');
  
  String get searchUsers => languageCode == 'kk' ? 'Пайдаланушыларды іздеу' : (languageCode == 'ru' ? 'Поиск пользователей' : 'Search Users');
  String get role => languageCode == 'kk' ? 'Рөл' : (languageCode == 'ru' ? 'Роль' : 'Role');
  String get group => languageCode == 'kk' ? 'Топ' : (languageCode == 'ru' ? 'Группа' : 'Group');
  String get status => languageCode == 'kk' ? 'Күйі' : (languageCode == 'ru' ? 'Статус' : 'Status');
  String get actions => languageCode == 'kk' ? 'Әрекеттер' : (languageCode == 'ru' ? 'Действия' : 'Actions');
  String get userRole => languageCode == 'kk' ? 'Пайдаланушы' : (languageCode == 'ru' ? 'Пользователь' : 'User');
  String get adminRole => languageCode == 'kk' ? 'Әкімші' : (languageCode == 'ru' ? 'Администратор' : 'Admin');
  String get blocked => languageCode == 'kk' ? 'Блокталған' : (languageCode == 'ru' ? 'Заблокирован' : 'Blocked');
  String get active => languageCode == 'kk' ? 'Белсенді' : (languageCode == 'ru' ? 'Активен' : 'Active');
  
  String get addGlobalCategory => languageCode == 'kk' ? 'Жалпы санатты қосу' : (languageCode == 'ru' ? 'Добавить общую категорию' : 'Add Global Category');
  String get categoryName => languageCode == 'kk' ? 'Санат атауы' : (languageCode == 'ru' ? 'Название категории' : 'Category Name');
  String get iconCodePoint => languageCode == 'kk' ? 'Иконка коды (мысалы, 58428)' : (languageCode == 'ru' ? 'Код иконки (например, 58428)' : 'Icon Code Point (e.g. 58428)');
  String get cancel => languageCode == 'kk' ? 'Болдырмау' : (languageCode == 'ru' ? 'Отмена' : 'Cancel');
  String get add => languageCode == 'kk' ? 'Қосу' : (languageCode == 'ru' ? 'Добавить' : 'Add');
  String get categoryAdded => languageCode == 'kk' ? 'Санат қосылды' : (languageCode == 'ru' ? 'Категория добавлена' : 'Category added');
  String get globalCategories => languageCode == 'kk' ? 'Жалпы санаттар' : (languageCode == 'ru' ? 'Общие категории' : 'Global Categories');
  String get addNewCategory => languageCode == 'kk' ? 'Жаңа санат қосу' : (languageCode == 'ru' ? 'Добавить категорию' : 'Add New Category');
  String get noGlobalCategories => languageCode == 'kk' ? 'Жалпы санаттар табылмады' : (languageCode == 'ru' ? 'Общие категории не найдены' : 'No global categories found.');
  String get defaultValue => languageCode == 'kk' ? 'Әдепкі' : (languageCode == 'ru' ? 'По умолчанию' : 'Default');
  String get customGlobal => languageCode == 'kk' ? 'Арнайы жалпы' : (languageCode == 'ru' ? 'Пользовательская общая' : 'Custom Global');
  
  String get sendGlobalPush => languageCode == 'kk' ? 'Жалпы пуш-хабарландыру жіберу' : (languageCode == 'ru' ? 'Отправить пуш-уведомление' : 'Send Global Push Notification');
  String get title => languageCode == 'kk' ? 'Тақырып' : (languageCode == 'ru' ? 'Заголовок' : 'Title');
  String get messageBody => languageCode == 'kk' ? 'Хабарлама мәтіні' : (languageCode == 'ru' ? 'Текст сообщения' : 'Message Body');
  String get sendToAll => languageCode == 'kk' ? 'Барлық пайдаланушыларға жіберу' : (languageCode == 'ru' ? 'Отправить всем' : 'Send to All Users');
  String get notificationQueued => languageCode == 'kk' ? 'Хабарландыру кезекке қойылды' : (languageCode == 'ru' ? 'Уведомление отправлено' : 'Notification Queued');
  
  String get accessDenied => languageCode == 'kk' ? 'Рұқсат берілмеді' : (languageCode == 'ru' ? 'Доступ запрещен' : 'Access Denied');
  String get noAdminPrivileges => languageCode == 'kk' ? 'Сізде әкімшілік құқықтар жоқ.' : (languageCode == 'ru' ? 'У вас нет прав администратора.' : 'You do not have administrative privileges.');
  String get goBack => languageCode == 'kk' ? 'Артқа қайту' : (languageCode == 'ru' ? 'Назад' : 'Go Back');
  String get logout => languageCode == 'kk' ? 'Шығу' : (languageCode == 'ru' ? 'Выйти' : 'Logout');
  String get noData => languageCode == 'kk' ? 'Деректер жоқ' : (languageCode == 'ru' ? 'Нет данных' : 'No data available');
  String get retry => languageCode == 'kk' ? 'Қайталау' : (languageCode == 'ru' ? 'Повторить' : 'Retry');
  String get failedLoadAdminData => languageCode == 'kk' ? 'Әкімші деректерін жүктеу сәтсіз аяқталды' : (languageCode == 'ru' ? 'Не удалось загрузить данные' : 'Failed to Load Admin Data');
  String get adminError => languageCode == 'kk' ? 'Әкімші қателігі' : (languageCode == 'ru' ? 'Ошибка администратора' : 'Admin Error');
  String get error => languageCode == 'kk' ? 'Қате' : (languageCode == 'ru' ? 'Ошибка' : 'Error');
}

