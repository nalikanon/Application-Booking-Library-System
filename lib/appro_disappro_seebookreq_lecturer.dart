import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Appro_Disappro_Seebookreq_lecturer extends StatefulWidget {
  const Appro_Disappro_Seebookreq_lecturer({super.key});

  @override
  _Appro_Disappro_Seebookreq_lecturerState createState() => _Appro_Disappro_Seebookreq_lecturerState();
}

class _Appro_Disappro_Seebookreq_lecturerState extends State<Appro_Disappro_Seebookreq_lecturer> {
  List<Request> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests(); // เรียกใช้ฟังก์ชันเพื่อดึงคำขอจาก API
  }

  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.111:3000/seebookingReq'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          requests = data.map((request) {
            String formattedDate = request['Date']?.substring(0, 10) ?? 'No Date';
            List<String> dateParts = formattedDate.split('-');
            String day = dateParts[2];
            String month = dateParts[1];
            String year = dateParts[0];
            String finalDate = '$day/$month/$year';

            return Request(
              label: request['Name'] ?? 'No Name',
              time: '${request['StartTime']?.substring(0, 5) ?? 'No Start Time'} - ${request['EndTime']?.substring(0, 5) ?? 'No End Time'}',
              date: finalDate,
              room: request['Room'] ?? 'No Room',
              bookingId: request['BookingID'] ?? 0, // Map BookingID to Request object
              showCancelButton: true,
              color: Colors.blue,
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void cancelRequest(int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.amber, size: 50),
            SizedBox(width: 8),
            Text('Confirm Disapprove'),
          ],
        ),
        content: Text('Are you sure you want to disapprove this request?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              String bookingId = requests[index].bookingId.toString(); // Get the BookingID
              await cancelRequestOnServer(bookingId); // Call the cancel request function
              setState(() {
                requests.removeAt(index); // Remove the disapproved request
              });
              Navigator.of(context).pop();
            },
            child: Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

// Function to send a POST request to the server to disapprove the booking
Future<void> cancelRequestOnServer(String bookingId) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.111:3000/disapprove/$bookingId'), // Replace with actual endpoint
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'approver_id': '22'}), // Include additional data as needed
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disapprove request: ${response.body}');
    }
  } catch (e) {
    print('Error disapproving request: $e');
  }
}

  void approveRequest(int index) {
    String bookingId = requests[index].bookingId.toString(); // Get the BookingID
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(width: 8),
              Text('Confirm Approve'),
            ],
          ),
          content: Text('Are you sure you want to approve this request?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                // Call the API to approve the request
                await approveRequestOnServer(bookingId);
                setState(() {
                  requests.removeAt(index); // Remove the approved request
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to send a POST request to the server to approve the booking
  Future<void> approveRequestOnServer(String bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.111:3000/approve/$bookingId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'approver_id': '22'}), // Replace with actual approver_id if needed
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to approve request: ${response.body}');
      }
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          color: Color(0xFFF8F8F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Request',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              ...requests.asMap().entries.map((entry) {
                int index = entry.key;
                Request request = entry.value;
                return DetailedRequestCard(
                  color: request.color,
                  label: request.label,
                  icon: Icons.expand_less,
                  details: [
                    'Room: ${request.room}',
                    'Time: ${request.time}',
                    'Date: ${request.date}',
                  ],
                  showCancelButton: request.showCancelButton,
                  onApprove: () => approveRequest(index),
                  onCancel: () => cancelRequest(index),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class Request {
  final String label;
  final String time;
  final String date;
  final String room;
  final int bookingId; // Add bookingId property
  final bool showCancelButton;
  final Color color;

  Request({
    required this.label,
    required this.time,
    required this.date,
    required this.room,
    required this.bookingId, // Include bookingId in the constructor
    required this.showCancelButton,
    required this.color,
  });
}

class DetailedRequestCard extends StatefulWidget {
  final Color color;
  final String label;
  final IconData icon;
  final List<String> details;
  final bool showCancelButton;
  final VoidCallback onApprove;
  final VoidCallback onCancel;

  DetailedRequestCard({
    required this.color,
    required this.label,
    required this.icon,
    required this.details,
    this.showCancelButton = false,
    required this.onApprove,
    required this.onCancel,
  });

  @override
  _DetailedRequestCardState createState() => _DetailedRequestCardState();
}

class _DetailedRequestCardState extends State<DetailedRequestCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.details.map((detail) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    detail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                )).toList(),
              ),
            ),
          if (widget.showCancelButton && _isExpanded)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onApprove,
                    child: Text('Approve'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onCancel,
                    child: Text('Disapprove'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
