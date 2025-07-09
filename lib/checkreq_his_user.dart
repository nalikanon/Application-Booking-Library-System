import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Request {
  final String label;
  final String time;
  final String date;
  final String status;
  final bool showCancelButton;
  final int bookingId;

  Request({
    required this.label,
    required this.time,
    required this.date,
    required this.status,
    required this.showCancelButton,
    required this.bookingId,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      label: json['label'] ?? '',
      time: json['time'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      showCancelButton: json['status'] == 'pending',
      bookingId: json['booking_id'],
    );
  }

  String get formattedStatus {
    switch (status) {
      case 'approved':
        return 'Approve';
      case 'rejected':
        return 'Disapprove';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  String get formattedDate {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  Color get statusColor {
    switch (status) {
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class Checkreq_His_user extends StatefulWidget {
  const Checkreq_His_user({Key? key}) : super(key: key);

  @override
  _Checkreq_His_userState createState() => _Checkreq_His_userState();
}

class _Checkreq_His_userState extends State<Checkreq_His_user> {
  late Future<List<Request>> dataREQ;
  List<Request> requests = [];

  @override
  void initState() {
    super.initState();
    dataREQ = fetchData();
  }

  Future<List<Request>> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('token');
    String? userId;
    if (data != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(data);
      userId = payload['userId'];
      print('User ID: $userId');
    }

    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.111:3000/checkReq/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<Request> requests =
            data.map((json) => Request.fromJson(json)).toList();

        // เรียงข้อมูลตาม booking_id จากมากไปน้อย
        requests.sort((a, b) => b.bookingId.compareTo(a.bookingId));

        return requests;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
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
              Text('Confirm Cancel'),
            ],
          ),
          content: Text('Are you sure you want to cancel this request?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  requests.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          color: Color(0xFFF8F8F8),
          child: FutureBuilder<List<Request>>(
            future: dataREQ,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No requests available.');
              }

              requests = snapshot.data!;
              return Column(
                children: requests.asMap().entries.map((entry) {
                  int index = entry.key;
                  Request request = entry.value;
                  return DetailedRequestCard(
                    color: request.statusColor,
                    label: request.label,
                    icon: Icons.expand_less,
                    details: [
                      'Time: ${request.time}',
                      'Date: ${request.formattedDate}',
                      'Status: ${request.formattedStatus}',
                    ],
                    showCancelButton: request.showCancelButton,
                    onCancel: () => cancelRequest(index),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DetailedRequestCard extends StatefulWidget {
  final Color color;
  final String label;
  final IconData icon;
  final List<String> details;
  final bool showCancelButton;
  final VoidCallback onCancel;

  DetailedRequestCard({
    required this.color,
    required this.label,
    required this.icon,
    required this.details,
    this.showCancelButton = false,
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
                children: widget.details
                    .map((detail) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            detail,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
