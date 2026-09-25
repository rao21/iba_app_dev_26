
import 'package:flutter/material.dart';
import 'package:iba_app_dev_26/activities/models.dart';
import 'package:iba_app_dev_26/activities/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D47A1),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserListViewModel _viewModel = UserListViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChange);
    _viewModel.loadUsers();
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              onChanged: _viewModel.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(),
         Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'All users',
            selected: !_viewModel.showFavoritesOnly,
            onTap: () => _viewModel.setShowFavoritesOnly(false),
          ),
        ),
        Expanded(
          child: _TabButton(
            label: 'Favorites',
            selected: _viewModel.showFavoritesOnly,
            onTap: () => _viewModel.setShowFavoritesOnly(true),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_viewModel.state) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
    case ViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(_viewModel.errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _viewModel.loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case ViewState.empty:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No users found'),
            ],
          ),
        );

      case ViewState.success:
        return RefreshIndicator(
          onRefresh: _viewModel.loadUsers,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _viewModel.users.length,
            itemBuilder: (context, index) {
              final user = _viewModel.users[index];
              return UserCard(
                user: user,
                isFavorite: _viewModel.isFavorite(user.id),
                onFavoriteToggle: () => _viewModel.toggleFavorite(user.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(user: user),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? color : Colors.grey,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Reusable custom widget — extracted out of build(), as required.
class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          child: Text(user.initials),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
      ),
    );
  }
}


class DetailScreen extends StatelessWidget {
  final UserModel user;

  const DetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent to ${user.name}')),
          );
        },
        child: const Icon(Icons.message),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(user.initials, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 12),
                Text(user.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Text(user.company.name,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          _InfoRow(icon: Icons.email, label: 'Email', value: user.email),
          _InfoRow(icon: Icons.phone, label: 'Phone', value: user.phone),
          _InfoRow(
            icon: Icons.location_on,
            label: 'Address',
            value: '${user.address.street}, ${user.address.city}',
          ),
          _InfoRow(icon: Icons.business, label: 'Company', value: user.company.name),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}