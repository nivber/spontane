import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onClose;
  final AuthService _authService = AuthService();

  SideMenu({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _authService.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                      : null,
                ),
                SizedBox(height: 12),
                Text(
                  currentUser?.displayName ?? 'Anonymous User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (currentUser?.email != null) ...[
                  SizedBox(height: 4),
                  Text(
                    currentUser!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.map_outlined, color: Colors.grey[700]),
            title: Text(
              'Map',
              style: TextStyle(color: Colors.grey[800]),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/map');
            },
          ),
          ListTile(
            leading: Icon(Icons.add_location_outlined, color: Colors.grey[700]),
            title: Text(
              'Add Event',
              style: TextStyle(color: Colors.grey[800]),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/add-event');
            },
          ),
          Spacer(),
          Divider(color: Colors.grey[300]),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.grey[700]),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Colors.grey[800]),
            ),
            onTap: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
} 