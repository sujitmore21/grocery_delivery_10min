import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dummy_data.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'delivery_tracking_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final User user;
        if (authState is AuthAuthenticated) {
          user = authState.user;
        } else {
          // Fallback to dummy user if not authenticated (shouldn't happen in normal flow)
          user = DummyData.getDummyUser();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 20),
                // User Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // User Email
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                // Profile Details Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Name'),
                        subtitle: Text(user.name),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(user.phone),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Member Since'),
                        subtitle: Text(
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Delivery Addresses'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to addresses
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: const Text('My Orders'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to orders
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: const Text('Track Delivery'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeliveryTrackingScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const LogoutRequested(),
                                    );
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
