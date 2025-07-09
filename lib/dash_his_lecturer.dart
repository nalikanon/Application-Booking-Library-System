import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dash_his_lecturer extends StatefulWidget {
  const Dash_his_lecturer({super.key});

  @override
  _Dash_his_lecturerState createState() => _Dash_his_lecturerState();
}

class _Dash_his_lecturerState extends State<Dash_his_lecturer> {
  int availableCount = 0;
  int reservedCount = 0;
  int disabledCount = 0;
  int pendingCount = 0;

  List<Request> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRoomCounts();
    fetchRequestHistory();
  }

  Future<void> fetchRoomCounts() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.111:3000/dashBoard'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched data: $data');
        setState(() {
          availableCount = int.tryParse(data['available'].toString()) ?? 0;
          reservedCount = int.tryParse(data['reserved'].toString()) ?? 0;
          disabledCount = int.tryParse(data['disabled'].toString()) ?? 0;
          pendingCount = int.tryParse(data['pending'].toString()) ?? 0;
          
        });
      } else {
        throw Exception('Failed to load room counts');
      }
    } catch (e) {
      print('Error fetching room counts: $e');
    }
  }

  Future<void> fetchRequestHistory() async {
const userId = '22';
    try {
      final response = await http.get(Uri.parse('http://192.168.1.111:3000/requestHistoryLecturer/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          requests = data.map((item) => Request.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load request history');
      }
    } catch (e) {
      print('Error fetching request history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(13.0),
          color: Color(0xFFF8F8F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDashboardCard('Available', availableCount.toString(), Colors.green[200]),
                  _buildDashboardCard('Reserved', reservedCount.toString(), Colors.red[200]),
                  _buildDashboardCard('Disabled', disabledCount.toString(), Colors.grey[400]),
                  _buildDashboardCard('Pending', pendingCount.toString(), Colors.yellow[200]),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              Text(
                'Request History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              ...requests.reversed.map((request) {
                Color cardColor = request.status == 'Disapprove' ? Colors.red : Colors.blue; // Determine color based on status

                return DetailedRequestCard(
                  color: cardColor, // Set the color
                  label: '${request.userFirstName} ${request.userLastName}',
                  icon: Icons.expand_less,
                  details: [
                    'Room: ${request.roomName}',
                    'Time: ${request.startTime} - ${request.endTime}',
                    'Date: ${request.date}',
                    'Status: ${request.status}',
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String count, Color? color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class Request {
  final String userFirstName;
  final String userLastName;
  final String roomName;  // Changed from roomId to roomName
  final String startTime;
  final String endTime;
  final String date;
  final String approverFirstName;
  final String approverLastName;
  final String status;

  Request({
    required this.userFirstName,
    required this.userLastName,
    required this.roomName,  // Update constructor parameter
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.approverFirstName,
    required this.approverLastName,
    required this.status,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      userFirstName: json['user_first_name'],
      userLastName: json['user_last_name'],
      roomName: json['room_name'],  // Update to fetch roomName
      startTime: json['start_time'],
      endTime: json['end_time'],
      date: json['date'],
      approverFirstName: json['approver_first_name'],
      approverLastName: json['approver_last_name'],
      status: json['status'],
    );
  }
}

class DetailedRequestCard extends StatefulWidget {
  final Color color;
  final String label;
  final IconData icon;
  final List<String> details;

  DetailedRequestCard({
    required this.color,
    required this.label,
    required this.icon,
    required this.details,
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
        ],
      ),
    );
  }
}
