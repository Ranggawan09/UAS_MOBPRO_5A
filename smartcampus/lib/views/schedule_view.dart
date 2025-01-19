import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleView extends StatefulWidget {
  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _setReminder(String title, DateTime scheduleTime) async {
    tz.initializeTimeZones();
    final tz.TZDateTime tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID notifikasi
      title,
      'Pengingat untuk kegiatan: $title',
      tzScheduleTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengingat berhasil disetel untuk $scheduleTime!')),
    );
  }

  void _addSchedule(String event, DateTime selectedTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      Timestamp timestamp = Timestamp.fromDate(selectedTime);
      await _firestore.collection('schedules').add({
        'uid': user.uid,
        'event': event,
        'time': timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jadwal berhasil ditambahkan!')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan jadwal: $e')));
    }
  }

  Future<List<String>> _loadSchedules() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final QuerySnapshot snapshot = await _firestore
        .collection('schedules')
        .where('uid', isEqualTo: user.uid)
        .get();

    List<String> schedules = snapshot.docs.map((doc) {
      var event = doc['event'];
      var time = doc['time'];

      if (time is Timestamp) {
        time = time.toDate();
      } else {
        time = DateTime.now();
      }

      return '$event - ${time.toString()}';
    }).toList();

    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _loadSchedules(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat jadwal'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada jadwal tersedia'));
                } else {
                  List<String> schedules = snapshot.data!;
                  return ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(schedules[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.alarm),
                          onPressed: () {
                            var timeString = schedules[index].split(' - ')[1];
                            DateTime scheduleTime = DateTime.parse(timeString);
                            _setReminder(
                              schedules[index].split(' - ')[0],
                              scheduleTime,
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final event = await _showAddEventDialog();
          if (event != null) {
            _addSchedule(event['event'], event['time']);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showAddEventDialog() async {
    TextEditingController controller = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Masukkan nama kegiatan'),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("Pilih Waktu: ${selectedTime.format(context)}"),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null && time != selectedTime) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {'event': controller.text, 'time': DateTime(
                    _selectedDay?.year ?? DateTime.now().year,
                    _selectedDay?.month ?? DateTime.now().month,
                    _selectedDay?.day ?? DateTime.now().day,
                    selectedTime.hour,
                    selectedTime.minute,
                  )},
                );
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
