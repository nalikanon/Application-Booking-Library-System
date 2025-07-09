//logout.dart
import 'package:flutter/material.dart';
import 'login.dart';

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.amber,
              size: 50, // Increase icon size
            ),
            const SizedBox(width: 8), // Space between icon and text
            const Text('Are you sure?'),
          ],
        ),
        content: const Text('You are about to log out of your account.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // Cancel button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Make button rounded
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white), // Text color
            ),
          ),
TextButton(
  onPressed: () {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Login()), // Change to login page
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  },
  style: TextButton.styleFrom(
    backgroundColor: Colors.red, // Logout button background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Make button rounded
    ),
  ),
  child: const Text(
    'Logout',
    style: TextStyle(color: Colors.white), // Text color
  ),
),

        ],
      );
    },
  );
}
