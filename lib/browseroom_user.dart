import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkreq_his_user.dart';
import 'bar_user.dart';
import 'logout.dart';
import 'req2b_user.dart';

class Browseroom_user extends StatelessWidget {
  const Browseroom_user({super.key});

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
  List<Room> rooms = [];
  late Timer _timer;
  final List<String> imagePaths = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    checkAndResetSlots();
    fetchRooms();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchRooms();
      updatePendingBookings();
      updateApprovedBookings();
    });
  }

  Future<void> updatePendingBookings() async {
  final todayDate = DateTime.now().toIso8601String().substring(0, 10); 
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.111:3000/updatePendingBookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'date': todayDate}), 
    );

    if (response.statusCode == 200) {
      //print('Pending bookings processed and room slots updated');
    } else {
      //print('Failed to update pending bookings: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating pending bookings: $e');
    print(todayDate);
  }
}

 Future<void> updateApprovedBookings() async {
  final todayDate = DateTime.now().toIso8601String().substring(0, 10); 
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.111:3000/updateApprovedBookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'date': todayDate}), 
    );

    if (response.statusCode == 200) {
      //debugPrint('Approved bookings processed and room slots updated for date $todayDate');
    } else {
      //debugPrint('Failed to update approved bookings. Status code: ${response.statusCode}');
      //debugPrint('Response body: ${response.body}');
    }
  } catch (e) {
    //debugPrint('Error updating approved bookings: $e');
    //debugPrint('Attempted date for update: $todayDate');
  }
}


 Future<void> checkAndResetSlots() async {
  final prefs = await SharedPreferences.getInstance();
  final lastResetDateStr = prefs.getString('lastResetDate');
  final todayStr = _getFormattedDate(DateTime.now());

  // Reset if there's no previous date or if today is after last reset date
  if (lastResetDateStr == null || todayStr != lastResetDateStr) {
    await resetRoomSlots();
    await prefs.setString('lastResetDate', todayStr);
  }
}

String _getFormattedDate(DateTime date) {
  return date.toIso8601String().substring(0, 10);
}

  Future<void> resetRoomSlots() async {
    try {
      final response =
          await http.put(Uri.parse('http://192.168.1.111:3000/resetSlots'));
      if (response.statusCode == 200) {
        print('Room slots have been reset');
      } else {
        print('Failed to reset room slots: ${response.statusCode}');
      }
    } catch (e) {
      print('Error resetting room slots: $e');
    }
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.111:3000/browseroom_user'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          rooms = data.map((roomData) => Room.fromJson(roomData)).toList();
        });
      } else {
        debugPrint('Failed to load rooms, status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BarUser(
      body: _getBodyContent(),
      selectedIndex: _selectedIndex,
      onTap: (index) {
        if (index == 2) {
          showLogoutConfirmationDialog(context);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
    );
  }

  Widget _getBodyContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _defaultBody(),
        const Checkreq_His_user(),
        if (rooms.isNotEmpty)
          Req2bUser(
            roomId: rooms[0].roomId,
            onBookPressed: () => setState(() => _selectedIndex = 0),
          ),
      ],
    );
  }

  Widget _defaultBody() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return _buildRoomItem(rooms[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(Room room) {
    final List<TimeSlot> timeSlots = [
      TimeSlot(
          label: '08:00-10:00',
          status: room.firstSlot,
          color: _getSlotColor(room.firstSlot)),
      TimeSlot(
          label: '10:00-12:00',
          status: room.secondSlot,
          color: _getSlotColor(room.secondSlot)),
      TimeSlot(
          label: '13:00-15:00',
          status: room.thirdSlot,
          color: _getSlotColor(room.thirdSlot)),
      TimeSlot(
          label: '15:00-17:00',
          status: room.fourthSlot,
          color: _getSlotColor(room.fourthSlot)),
    ];

    String imagePath =
        imagePaths[(room.roomImg - 1).clamp(0, imagePaths.length - 1)];

    return GestureDetector(
      onTap: () => _handleRoomTap(room),
      child: Stack(
        children: [
          _buildRoomCardContent(room, imagePath, timeSlots),
          if (room.roomStatus == 'disabled') _buildDisabledOverlay(),
        ],
      ),
    );
  }

  void _handleRoomTap(Room room) {
    if (room.roomStatus != 'disabled') {
      setState(() => _selectedIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Req2bUser(
            roomId: room.roomId,
            onBookPressed: () => setState(() => _selectedIndex = 0),
          ),
        ),
      );
    }
  }

  Widget _buildRoomCardContent(
      Room room, String imagePath, List<TimeSlot> timeSlots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: _containerDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath,
                width: 100, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTimeSlotsGrid(timeSlots),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsGrid(List<TimeSlot> timeSlots) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeSlots
              .sublist(0, 2)
              .map((slot) => Expanded(child: slot))
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeSlots
              .sublist(2, 4)
              .map((slot) => Expanded(child: slot))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDisabledOverlay() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Disabled',
        style: TextStyle(
            fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
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

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class Room {
  final int roomId;
  final String roomName;
  final int roomImg;
  final String firstSlot;
  final String secondSlot;
  final String thirdSlot;
  final String fourthSlot;
  final String roomStatus;

  Room({
    required this.roomId,
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
      roomId: json['room_id'] ?? 0,
      roomName: json['room_name'] ?? 'Unknown Room',
      roomImg: int.tryParse(json['room_img'].toString()) ?? 0,
      firstSlot: json['first_slot'] ?? 'free',
      secondSlot: json['second_slot'] ?? 'free',
      thirdSlot: json['third_slot'] ?? 'free',
      fourthSlot: json['fourth_slot'] ?? 'free',
      roomStatus: json['room_status'] ?? 'available',
    );
  }
}

class TimeSlot extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const TimeSlot(
      {required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status == 'reserved'
            ? 'Reserved'
            : status == 'pending'
                ? 'Pending'
                : label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
