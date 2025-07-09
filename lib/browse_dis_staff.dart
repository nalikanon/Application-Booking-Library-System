import 'package:flutter/material.dart';
import 'dash_his_staff.dart';
import 'bar_staff.dart';
import 'logout.dart';
import 'edit.dart';
import 'add.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Browseroom_staff extends StatelessWidget {
  const Browseroom_staff({super.key});

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

  bool isEditing = false;
  bool isAdding = false;
  String roomToEdit = '';
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.111:3000/browseroom_staff'));

      if (response.statusCode == 200) {
        List<dynamic> jsonRooms = json.decode(response.body);
        setState(() {
          rooms = jsonRooms.map((jsonRoom) => Room.fromJson(jsonRoom)).toList();
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print("Error fetching rooms: $e");
      // Display error message in UI if needed
    }
  }

Future<void> toggleRoomStatus(String roomId, String currentStatus) async {
  final newStatus = currentStatus == 'enabled' ? 'disabled' : 'enabled';
  final endpoint = newStatus == 'disabled' 
      ? 'http://192.168.1.111:3000/disableRoom/$roomId' 
      : 'http://192.168.1.111:3000/enableRoom/$roomId';

  final response = await http.put(
    Uri.parse(endpoint),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'room_status': newStatus}),
  );

  if (response.statusCode == 200) {
    fetchRooms(); // Refresh the room list after toggling
  } else {
    print('Failed to toggle room status: ${response.body}');
  }
}


  @override
  Widget build(BuildContext context) {
    return BarStaff(
      body: isAdding ? _addBody() : (isEditing ? _editBody() : _getBodyContent()),
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
        const Dash_his_staff(),
      ],
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
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Rooms Availability',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdding = true;
                      });
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2B55A7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...rooms.map((room) => Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _roomCard(room),
                  )),
              SizedBox(height: 220), // Adjust space here
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomCard(Room room) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/${room.roomImg}.jpg',
              width: 90,
              height: 90,
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
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Location: ${room.location}',
                      style: TextStyle(color: Colors.blueGrey[600]),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Beds: ${room.bed}',
                      style: TextStyle(color: Colors.blueGrey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            roomToEdit = room.roomName;
                            isEditing = true;
                          });
                        },
                        child: Text('Edit', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
  child: ElevatedButton(
    onPressed: () {
      // Call the function to toggle the room status
      toggleRoomStatus(room.roomId, room.roomStatus);
    },
    child: Text(
      room.roomStatus == 'enabled' ? 'Disable' : 'Enable',
      style: TextStyle(color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: room.roomStatus == 'enabled'
          ? Colors.red
          : Color.fromARGB(255, 14, 123, 212),
      padding: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editBody() {
    return Edit(
      initialRoomName: roomToEdit,
      initialBedCount: rooms.firstWhere((room) => room.roomName == roomToEdit).bed.toString(),
      initialLocation: rooms.firstWhere((room) => room.roomName == roomToEdit).location,
      initialImagePath: 'assets/images/${rooms.firstWhere((room) => room.roomName == roomToEdit).roomImg}.jpg',
      onRoomUpdated: () {
        setState(() {
          isEditing = false;
        });
      },
    );
  }

  Widget _addBody() {
    return Add(
      onRoomAdded: () {
        setState(() {
          isAdding = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class Room {
  String roomId; // Unique identifier for the room
  String roomName;
  String location;
  String bed;
  String roomStatus;
  String roomImg;

  Room({
    required this.roomId,
    required this.roomName,
    required this.location,
    required this.bed,
    required this.roomStatus,
    required this.roomImg,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id']?.toString() ?? '',
      roomName: json['room_name'] ?? '',
      location: json['location'] ?? '',
      bed: json['bed']?.toString() ?? '0',
      roomStatus: json['room_status'] ?? '',
      roomImg: json['room_img'] ?? '',
    );
  }
}