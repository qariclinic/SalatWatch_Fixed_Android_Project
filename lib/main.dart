import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SalatWatchApp());
}

class SalatWatchApp extends StatelessWidget {
  const SalatWatchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SalatWatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D5C36)),
          scaffoldBackgroundColor: const Color(0xFF061A12),
        ),
        home: const SalatWatchHome(),
      );
}

class SalatWatchHome extends StatefulWidget {
  const SalatWatchHome({super.key});
  @override
  State<SalatWatchHome> createState() => _SalatWatchHomeState();
}

class _SalatWatchHomeState extends State<SalatWatchHome> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  HijriCalendar _hijri = HijriCalendar.now();
  late PrayerTimes _prayerTimes;

  @override
  void initState() {
    super.initState();
    _prayerTimes = _calculatePrayerTimes(_now);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        _now = now;
        _hijri = HijriCalendar.now();
        if (now.day != _prayerTimes.fajr.day) {
          _prayerTimes = _calculatePrayerTimes(now);
        }
      });
    });
  }

  PrayerTimes _calculatePrayerTimes(DateTime date) {
    final coordinates = Coordinates(34.0, 73.0);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayers = <Map<String, Object>>[
      {'name': 'فجر', 'time': _prayerTimes.fajr},
      {'name': 'ظہر', 'time': _prayerTimes.dhuhr},
      {'name': 'عصر', 'time': _prayerTimes.asr},
      {'name': 'مغرب', 'time': _prayerTimes.maghrib},
      {'name': 'عشاء', 'time': _prayerTimes.isha},
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(children: [
                const _TitlePill(),
                const SizedBox(height: 22),
                _ClockCard(now: _now, hijri: _hijri),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.15,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: prayers.length,
                  itemBuilder: (_, i) {
                    final name = prayers[i]['name']! as String;
                    final time = prayers[i]['time']! as DateTime;
                    final isNext = _isNextPrayer(i, prayers);
                    return _PrayerCard(name: name, time: time, highlighted: isNext);
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'مقام: بیشام، خیبر پختونخوا  •  حنفی  •  کراچی طریقہ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  bool _isNextPrayer(int index, List<Map<String, Object>> prayers) {
    final time = prayers[index]['time']! as DateTime;
    if (!_now.isBefore(time)) return false;
    if (index == 0) return true;
    final previous = prayers[index - 1]['time']! as DateTime;
    return _now.isAfter(previous);
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D5C36),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'صلوٰۃ واچ  •  SalatWatch',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
}

class _ClockCard extends StatelessWidget {
  final DateTime now;
  final HijriCalendar hijri;
  const _ClockCard({required this.now, required this.hijri});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF122E22), Color(0xFF1A4D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Column(children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              DateFormat('hh:mm:ss a').format(now),
              style: const TextStyle(color: Color(0xFF7CFFB2), fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 7),
          Text(DateFormat('EEEE, d MMMM yyyy').format(now), style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 5),
          Text('${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} ھ', style: const TextStyle(color: Color(0xFFFFD86B), fontSize: 17, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final bool highlighted;
  const _PrayerCard({required this.name, required this.time, required this.highlighted});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF0D5C36) : const Color(0xFF11261C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: highlighted ? const Color(0xFF7CFFB2) : Colors.white10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(name, style: TextStyle(color: highlighted ? Colors.white : Colors.white70, fontSize: 19, fontWeight: FontWeight.bold)),
          Text(DateFormat('hh:mm a').format(time), style: TextStyle(color: highlighted ? const Color(0xFF7CFFB2) : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      );
}
