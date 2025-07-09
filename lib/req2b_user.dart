import 'package:flutter/material.dart';
import 'package:project_mad/browseroom_user.dart';
import 'package:project_mad/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Req2bUser extends StatefulWidget {
  final Function onBookPressed;
  final int roomId;

  const Req2bUser({
    super.key,
    required this.onBookPressed,
    required this.roomId,
  });

  @override
  _Req2bUserState createState() => _Req2bUserState();
}

class _Req2bUserState extends State<Req2bUser> {
  late SharedPreferences prefs;
  String? token;
  int? userId; 
  String roomImage = 'assets/images/1.jpg';
  String roomName = 'Loading...';
  String location = 'Loading...';
  String bed = 'Loading...';
  String selectedTime = '08:00-10:00';
  String startTime = '08:00:00';
  String endTime = '10:00:00';
  final String date =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

  @override
  void initState() {
    super.initState();
    initializePreferencesAndToken();
  }

  Future<void> initializePreferencesAndToken() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      print("Token not found. Redirecting to login.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      return;
    }

    await fetchUserData(); 
    fetchRoomDetails(); 
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.111:3000/profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userId = data['user_id']; 
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        print("Error fetching user data, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchRoomDetails() async {
    if (token == null) {
      print("Cannot fetch room details without a valid token.");
      return;
    }

    setState(() {
      roomImage = 'assets/images/1.jpg';
      roomName = 'Loading...';
      location = 'Loading...';
      bed = 'Loading...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.111:3000/roomDetails/${widget.roomId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomDetails = jsonDecode(response.body);
        setState(() {
          roomImage = roomDetails["room_img"] != null
              ? 'assets/images/${roomDetails["room_img"]}.jpg'
              : 'assets/images/1.jpg';
          roomName = roomDetails["room_name"] ?? 'Unknown Room';
          location = roomDetails["location"] ?? 'Unknown Location';
          bed = roomDetails["bed"]?.toString() ?? 'Unknown Bed';
        });
      } else {
        print(
            'Failed to load room details, status code: ${response.statusCode}');
        setState(() {
          roomImage = 'assets/images/1.jpg';
          roomName = 'Unknown';
          location = 'Unknown';
          bed = 'Unknown';
        });
      }
    } catch (error) {
      print('Error fetching room details: $error');
      setState(() {
        roomImage = 'assets/images/default.jpg';
        roomName = 'Unknown';
        location = 'Unknown';
        bed = 'Unknown';
      });
    }
  }

  Future<void> bookRoom() async {
  if (token == null || userId == null) {
    print("Cannot book room without a valid token and user ID.");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.111:3000/requestBook'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'room_id': widget.roomId,
        'start_time': startTime,
        'end_time': endTime,
        'date': date,
      }),
    );

    if (response.statusCode == 201) {
      widget.onBookPressed();
      _showBookingAlert(context, true);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['message'] ?? 'An unexpected error occurred.';
      _showBookingAlert(context, false, errorMessage: errorMessage);
    }
  } catch (error) {
    print("Error booking room: $error");
    _showBookingAlert(context, false, errorMessage: 'An unexpected error occurred. Please try again.');
  }
}

void _showBookingAlert(BuildContext context, bool isSuccess, {String? errorMessage}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isSuccess ? 'Booking Successful' : 'Booking Failed'),
        content: Text(isSuccess
            ? 'Your booking has been successfully submitted and is pending approval.'
            : errorMessage ?? 'Sorry, there was an error with your booking. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Browseroom_user(),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Browseroom_user(),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const Text(
              'Booking details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                roomImage,
                height: 150,
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            BookingDetailField(label: 'Room', value: roomName),
            BookingDetailField(label: 'Bed', value: bed),
            BookingDetailField(label: 'Location', value: location),
            BookingDetailField(label: 'Date', value: date),
            BookingDetailField(
              label: 'Time',
              value: selectedTime,
              isDropdown: true,
              onSelected: (value) {
                setState(() {
                  selectedTime = value;

                  final times = selectedTime.split('-');
                  startTime = '${times[0]}:00';
                  endTime = '${times[1]}:00';
                });
              },
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  child: const Text('Book',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    _showCancelDialog(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
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
          title: const Text('Confirm Booking'),
          content: const Text('Are you sure you want to book this room?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Browseroom_user(),
                  ),
                );
              },
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Browseroom_user(),
                  ),
                );
                bookRoom(); 
              },
              child: const Text('Yes'),
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
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Browseroom_user(),
                  ),
                );
              },
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Browseroom_user(),
                  ),
                );
                widget
                    .onBookPressed(); // Trigger the callback to handle cancellation
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class BookingDetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool isDropdown;
  final ValueChanged<String>? onSelected;

  const BookingDetailField({
    required this.label,
    required this.value,
    this.isDropdown = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isDropdown
                ? DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: value,
                    onChanged: (newValue) {
                      if (onSelected != null && newValue != null) {
                        onSelected!(newValue);
                      }
                    },
                    items: [
                      '08:00-10:00',
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
                : Center(
                    child: Text(value,
                        style: const TextStyle(fontSize: 16))
                    ),
          ),
        ],
      ),
    );
  }
}
