import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Settings
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              );
            },
          ),
          const Divider(),
          // User Info
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return ListTile(
                title: const Text('Email'),
                subtitle: Text(authProvider.currentUser?.email ?? 'N/A'),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return ListTile(
                title: const Text('Account Type'),
                subtitle: Text(authProvider.isGuest ? 'Guest' : 'Registered'),
              );
            },
          ),
          const Divider(),
          // Logout
          ListTile(
            title: const Text('Logout'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // About
          ListTile(
            title: const Text('About'),
            subtitle: const Text('FitLife Mini v1.0.0'),
          ),
        ],
      ),
    );
  }
}
