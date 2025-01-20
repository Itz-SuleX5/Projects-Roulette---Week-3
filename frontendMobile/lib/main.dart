import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class AppLocalizations {
  final bool isEnglish;

  const AppLocalizations({this.isEnglish = true});

  String get tapToSpin => isEnglish ? 'Tap the wheel to spin' : 'Toca la ruleta para girar';
  String get settings => isEnglish ? 'Settings' : 'Ajustes';
  String get language => isEnglish ? 'Language' : 'Idioma';
  String get english => isEnglish ? 'English' : 'Inglés';
  String get spanish => isEnglish ? 'Spanish' : 'Español';
  String get home => isEnglish ? 'Home' : 'Inicio';
  String get history => isEnglish ? 'History' : 'Historial';
  String get projectsRoulette => isEnglish ? 'Projects Roulette' : 'Ruleta de Proyectos';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheel Spinner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WheelSpinnerPage(),
    );
  }
}

class Note {
  final String title;
  final String description;

  Note({required this.title, required this.description});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class ArrowPainter extends CustomPainter {
  const ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final arrowPaint = Paint()
      ..color = const Color(0xFFFF4444)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final arrowPath = Path();
    arrowPath.moveTo(size.width / 2, 0);
    arrowPath.lineTo(size.width / 2 - 20, 20);
    arrowPath.quadraticBezierTo(
      size.width / 2, 15,
      size.width / 2 + 20, 20,
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, shadowPaint);
    canvas.drawPath(arrowPath, arrowPaint);

    final arrowBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(arrowPath, arrowBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WheelPainter extends CustomPainter {
  final List<Note> notes;
  final List<Color> colors;

  WheelPainter({required this.notes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    final sectionAngle = 2 * math.pi / notes.length;

    for (var i = 0; i < notes.length; i++) {
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectionAngle,
        sectionAngle,
        true,
        paint,
      );

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final x = radius * math.cos(i * sectionAngle);
      final y = radius * math.sin(i * sectionAngle);
      canvas.drawLine(center, center + Offset(x, y), linePaint);
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HistoryEntry {
  final Note note;
  final DateTime timestamp;

  HistoryEntry({required this.note, required this.timestamp});
}

class WheelSpinnerPage extends StatefulWidget {
  const WheelSpinnerPage({super.key});

  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

class _WheelSpinnerPageState extends State<WheelSpinnerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _startRotation = 0.0;
  bool _isSpinning = false;
  int _selectedIndex = 0;
  List<Note> _notes = [];
  Note? _selectedNote;
  bool _isLoading = true;
  bool _isEnglish = true;
  late AppLocalizations _localizations;
  List<HistoryEntry> _history = [];

  final List<Color> _pastelColors = [
    const Color(0xFFFFB3BA),
    const Color(0xFFBAE1FF),
    const Color(0xFFBAFFBA),
    const Color(0xFFFFDFBA),
    const Color(0xFFE8BAFF),
    const Color(0xFFFFFFBA),
  ];

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations(isEnglish: _isEnglish);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_notes.isNotEmpty) {
            final totalRotation = _startRotation + (_controller.value * 2 * math.pi * 7);
            final normalizedRotation = totalRotation % (2 * math.pi);
            final sectionAngle = (2 * math.pi) / _notes.length;
            
            double adjustedRotation = (2 * math.pi) - normalizedRotation;
            adjustedRotation += sectionAngle / 2;
            adjustedRotation = adjustedRotation % (2 * math.pi);
            
            int baseIndex = (adjustedRotation / sectionAngle).floor() % _notes.length;
            int selectedIndex = (baseIndex + 4) % _notes.length;
            
            setState(() {
              _selectedNote = _notes[selectedIndex];
              _history.insert(0, HistoryEntry(
                note: _notes[selectedIndex],
                timestamp: DateTime.now(),
              ));
            });
          }
        });
        
        _controller.reset();
      }
    });

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final response = await http.get(
        Uri.parse('https://sticky-notes-week-1.onrender.com/api/notes/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> notesJson = json.decode(response.body);
        setState(() {
          _notes = notesJson.map((json) => Note.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error cargando notas: $e');
    }
  }

  void _spinWheel() {
    if (!_isSpinning && _notes.isNotEmpty) {
      setState(() {
        _isSpinning = true;
        _selectedNote = null;
      });
      
      final random = math.Random();
      final spins = 5 + random.nextInt(2) + random.nextDouble();
      _startRotation = (spins * 2 * math.pi) % (2 * math.pi);
      
      _controller.duration = const Duration(seconds: 3);
      _controller.forward(from: 0.0);
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
      _localizations = AppLocalizations(isEnglish: _isEnglish);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _localizations.projectsRoulette,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: GestureDetector(
                            onTap: _spinWheel,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _startRotation + (_controller.value * 2 * math.pi * 7),
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          size: const Size(300, 300),
                                          painter: WheelPainter(
                                            notes: _notes,
                                            colors: _pastelColors,
                                          ),
                                        ),
                                        ...List.generate(_notes.length, (index) {
                                          final angle = (2 * math.pi * index) / _notes.length;
                                          return Transform(
                                            transform: Matrix4.identity()
                                              ..translate(150.0, 150.0)
                                              ..rotateZ(angle)
                                              ..translate(0.0, -100.0),
                                            child: Transform(
                                              transform: Matrix4.identity()
                                                ..rotateZ(math.pi / 2 + (math.pi / _notes.length) + math.pi / 12),
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 100,
                                                child: Text(
                                                  _notes[index].title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: -20,
                          child: SizedBox(
                            width: 300,
                            height: 40,
                            child: CustomPaint(
                              painter: ArrowPainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedNote != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedNote!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedNote!.description),
                      ],
                    ),
                  ),
                ] else if (!_isSpinning)
                  Text(
                    _localizations.tapToSpin,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                const Spacer(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            _showHistoryDialog();
          } else if (index == 2) {
            _showSettingsDialog();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: _localizations.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _localizations.settings,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_localizations.settings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_localizations.language),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_localizations.english),
                leading: Radio<bool>(
                  value: true,
                  groupValue: _isEnglish,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleLanguage();
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(_localizations.spanish),
                leading: Radio<bool>(
                  value: false,
                  groupValue: _isEnglish,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleLanguage();
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _localizations.history,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: _history.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _isEnglish ? 'No history yet' : 'No hay historial aún',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final entry = _history[index];
                            return ListTile(
                              title: Text(entry.note.title),
                              subtitle: Text(entry.note.description),
                              trailing: Text(
                                _formatDateTime(entry.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
