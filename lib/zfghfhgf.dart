//req2b.dart
import 'package:flutter/material.dart';

class Req2bUser extends StatelessWidget {
  final VoidCallback onBookPressed;

  const Req2bUser({super.key, required this.onBookPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              'Booking details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/1.jpg',
                height: 150,
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            BookingDetailField(label: 'Room', value: 'MT 001'),
            BookingDetailField(label: 'Bed', value: '1'),
            BookingDetailField(label: 'Location', value: '1st floor'),
            BookingDetailField(label: 'Date', value: '25/10/2024'),
            BookingDetailField(
              label: 'Time',
              value: '8:00-10:00',
              isDropdown: true,
            ),
            SizedBox(height: 10),
            Text(
              'Thanks for booking room',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  child: Text('Book', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    _showCancelDialog(context); // แสดงกล่องข้อความยืนยันการยกเลิก
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Text('Are you sure you want to book this room?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
              backgroundColor: Colors.red, // เปลี่ยนสีปุ่ม Yes เป็นสีเขียว
              foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
              child: Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
              backgroundColor: Colors.green, // เปลี่ยนสีปุ่ม Yes เป็นสีเขียว
              foregroundColor: Colors.white),
              onPressed: () {
                
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
                onBookPressed(); // เรียกฟังก์ชันที่ส่งมาจากพ่อแม่
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
              backgroundColor: Colors.green, // เปลี่ยนสีปุ่ม Yes เป็นสีเขียว
              foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
              child: Text('No'),
              
            ),
            TextButton(
              style: TextButton.styleFrom(
              backgroundColor: Colors.red, // เปลี่ยนสีปุ่ม Yes เป็นสีเขียว
              foregroundColor: Colors.white),
              onPressed: () {
                // ปิดกล่องข้อความ
                Navigator.of(context).pop();
                onBookPressed();// กลับไปยังหน้าก่อนหน้า
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class BookingDetailField extends StatefulWidget {
  final String label;
  final String value;
  final bool isDropdown;

  BookingDetailField({
    required this.label,
    required this.value,
    this.isDropdown = false,
  });

  @override
  _BookingDetailFieldState createState() => _BookingDetailFieldState();
}

class _BookingDetailFieldState extends State<BookingDetailField> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value; // เริ่มต้นด้วยค่าที่กำหนด
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.isDropdown
                ? DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox(),
                    value: selectedValue,
                    onChanged: (newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: [
                      '8:00-10:00',
                      '10:00-12:00',
                      '13:00-15:00',
                      '15:00-17:00'
                    ].map<DropdownMenuItem<String>>((String time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                  )
                : Center(child: Text(widget.value, style: TextStyle(fontSize: 16))),
          ),
        ],
      ),
    );
  }
}
