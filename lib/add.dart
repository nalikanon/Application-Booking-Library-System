//add.dart
import 'package:flutter/material.dart';
import 'room_form.dart';

class Add extends StatefulWidget {
  final VoidCallback onRoomAdded;

  Add({required this.onRoomAdded});

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  String imagePath = 'assets/images/1.jpg';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          SizedBox(height: 20),
          RoomForm(
            title: 'Add new room',
            initialRoomName: '',
            initialBedCount: '',
            initialLocation: '',
            imagePath: imagePath,
            onAccept: () {
              widget.onRoomAdded();
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
           
          ),
        ],
      ),
    );
  }
}