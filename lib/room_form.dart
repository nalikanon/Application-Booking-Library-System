//room_form.dart
import 'package:flutter/material.dart';
import 'browse_dis_staff.dart';

class RoomForm extends StatefulWidget {
  final String title;
  final String initialRoomName;
  final String initialBedCount;
  final String initialLocation;
  final String imagePath;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  RoomForm({
    required this.title,
    required this.initialRoomName,
    required this.initialBedCount,
    required this.initialLocation,
    required this.imagePath,
    required this.onAccept,
    required this.onCancel,
  });

  @override
  _RoomFormState createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  late TextEditingController _roomNameController;
  late TextEditingController _bedCountController;
  late TextEditingController _locationController;
  String imagePath = '';
  final List<String> imagePaths = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
  ];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: widget.initialRoomName);
    _bedCountController = TextEditingController(text: widget.initialBedCount);
    _locationController = TextEditingController(text: widget.initialLocation);
    imagePath = widget.imagePath;
    currentImageIndex = imagePaths.indexOf(imagePath);
  }

  void _updateImageIndex(int change) {
    setState(() {
      currentImageIndex = (currentImageIndex + change) % imagePaths.length;
      if (currentImageIndex < 0) {
        currentImageIndex = imagePaths.length - 1;
      }
      imagePath = imagePaths[currentImageIndex];
    });
  }

  void _handleAcceptSave(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Browseroom_staff(),
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Browseroom_staff(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/images/left-arrow.png',
                    width: 40, // Set the desired width
                    height: 40, // Set the desired height
                  ),
                  onPressed: () => _updateImageIndex(-1),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/images/right-arrow.png',
                    width: 40, // Set the desired width
                    height: 40, // Set the desired height
                  ),
                  onPressed: () => _updateImageIndex(1),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField(_roomNameController, 'Room'),
            SizedBox(height: 10),
            _buildTextField(_bedCountController, 'Bed'),
            SizedBox(height: 10),
            _buildTextField(_locationController, 'Location'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _handleAcceptSave(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.title == 'Add new room' ? 'Accept' : 'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _handleCancel(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}