import 'package:flutter/material.dart';
import 'appro_disappro_seebookreq_lecturer.dart';
import 'dash_his_lecturer.dart';
import 'bar_lecturer.dart'; 
import 'logout.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class Browseroom_lecturer extends StatelessWidget {
  const Browseroom_lecturer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RoomsAvailability(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoomsAvailability extends StatefulWidget {
  @override
  _RoomsAvailabilityState createState() => _RoomsAvailabilityState();
}

class _RoomsAvailabilityState extends State<RoomsAvailability> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<Room> rooms = []; // สร้าง List สำหรับเก็บห้อง

  @override
  void initState() {
    super.initState();
    fetchRooms(); // ดึงข้อมูลห้องเมื่อเริ่มต้น
  }

  Future<void> fetchRooms() async {
    final response = await http.get(Uri.parse('http://192.168.1.111:3000/browseroom_lecturer'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        rooms = data.map((roomData) => Room.fromJson(roomData)).toList();
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // Function to change the content in the body based on the selected icon
  Widget _getBodyContent() {
    switch (_selectedIndex) {
      case 1:
        return const Appro_Disappro_Seebookreq_lecturer(); 
      case 2:
        return const Dash_his_lecturer();
      default:
        return _defaultBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BarLecturer(
      body: _getBodyContent(),
      selectedIndex: _selectedIndex,
      onTap: (index) {
        if (index == 3) {
          showLogoutConfirmationDialog(context); // Show logout confirmation dialog
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      }, firstName: '', lastName: '', email: '', role: '',
    );
  }

  Widget _defaultBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rooms availability',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: rooms.map((room) => Column(
                  children: [
                    _roomCard(room), // Display each room card
                    SizedBox(height: 10), // Add 20 pixels of spacing
                  ],
                )).toList(),
              ),
              SizedBox(height: 220),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomCard(Room room) {
    List<TimeSlot> timeSlots = [
      TimeSlot(label: '08:00-10:00', status: room.firstSlot, color: _getSlotColor(room.firstSlot)),
      TimeSlot(label: '10:00-12:00', status: room.secondSlot, color: _getSlotColor(room.secondSlot)),
      TimeSlot(label: '13:00-15:00', status: room.thirdSlot, color: _getSlotColor(room.thirdSlot)),
      TimeSlot(label: '15:00-17:00', status: room.fourthSlot, color: _getSlotColor(room.fourthSlot)),
    ];

    return GestureDetector(
      onTap: () {
        if (room.roomStatus != 'disabled') {
        }
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/${room.roomImg}.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.roomName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: timeSlots[0]),
                                  SizedBox(width: 5),
                                  Expanded(child: timeSlots[1]),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: timeSlots[2]),
                                  SizedBox(width: 5),
                                  Expanded(child: timeSlots[3]),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (room.roomStatus == 'disabled')
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                'Disable',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSlotColor(String slotStatus) {
    switch (slotStatus) {
      case 'reserved':
        return Colors.black; 
      case 'pending':
        return Colors.orange; 
      case 'free':
        return Colors.blue; 
      default:
        return Colors.grey; 
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class Room {
  final String roomName;
  final String roomImg;
  final String firstSlot;
  final String secondSlot;
  final String thirdSlot;
  final String fourthSlot;
  final String roomStatus;

  Room({
    required this.roomName,
    required this.roomImg,
    required this.firstSlot,
    required this.secondSlot,
    required this.thirdSlot,
    required this.fourthSlot,
    required this.roomStatus,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomName: json['room_name'] as String,
      roomImg: json['room_img'] as String, 
      firstSlot: json['first_slot'].toString(), // แปลงเป็น String
      secondSlot: json['second_slot'].toString(),
      thirdSlot: json['third_slot'].toString(),
      fourthSlot: json['fourth_slot'].toString(),
      roomStatus: json['room_status'] as String,
    );
  }
}

class TimeSlot extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  TimeSlot({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == 'reserved' ? 'Reserved' : status == 'pending' ? 'Pending' : label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
