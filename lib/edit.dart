//edit.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'room_form.dart';

class Edit extends StatefulWidget {
  final String initialRoomName;
  final String initialBedCount;
  final String initialLocation;
  final String initialImagePath;
  final VoidCallback onRoomUpdated;

  Edit({
    required this.initialRoomName,
    required this.initialBedCount,
    required this.initialLocation,
    required this.initialImagePath,
    required this.onRoomUpdated,
  });

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imagePath = pickedImage.path;
      });
    }
  }

  void _navigateBack() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Container(), // Replace with a dummy container
        transitionDuration: Duration.zero, // Disable transition duration
        reverseTransitionDuration: Duration.zero, // Disable reverse transition duration
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Adjust the height as needed
            RoomForm(
              title: 'Edit room',
              initialRoomName: widget.initialRoomName,
              initialBedCount: widget.initialBedCount,
              initialLocation: widget.initialLocation,
              imagePath: imagePath,
              onAccept: () {
                widget.onRoomUpdated();
                _navigateBack(); // Call custom navigation method
              },
              onCancel: () {
                _navigateBack(); // Call custom navigation method
              },
            ),
          ],
        ),
      ),
    );
  }
}