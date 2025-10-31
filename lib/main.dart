import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(KadesCupApp());
}

class KadesCupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kades Cup 2025 Adan-Adan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ScoreboardPage(),
    );
  }
}

class ScoreboardPage extends StatefulWidget {
  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  String leftName = 'Pemain A & Pemain B';
  String rightName = 'Pemain C & Pemain D';
  int leftScore = 0;
  int rightScore = 0;
  bool isLeftServer = true;
  final List<Map<String, dynamic>> _history = [];

  void _pushUndo(String type) {
    _history.add({
      'type': type,
      'leftScore': leftScore,
      'rightScore': rightScore,
      'isLeftServer': isLeftServer,
    });
    if (_history.length > 300) _history.removeAt(0);
  }

  void _leftWinsRally() {
    if (leftScore >= 30 || rightScore >= 30) return;
    _pushUndo('rally');
    setState(() {
      if (isLeftServer) leftScore += 1;
      else isLeftServer = true;
    });
  }

  void _rightWinsRally() {
    if (leftScore >= 30 || rightScore >= 30) return;
    _pushUndo('rally');
    setState(() {
      if (!isLeftServer) rightScore += 1;
      else isLeftServer = false;
    });
  }

  void _swapSides() {
    _pushUndo('swap');
    setState(() {
      final ln = leftName;
      leftName = rightName;
      rightName = ln;
      final ls = leftScore;
      leftScore = rightScore;
      rightScore = ls;
      isLeftServer = !isLeftServer;
    });
  }

  void _newGame() {
    _pushUndo('newgame');
    setState(() {
      leftScore = 0;
      rightScore = 0;
      isLeftServer = true;
      _history.clear();
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    setState(() {
      leftScore = last['leftScore'];
      rightScore = last['rightScore'];
      isLeftServer = last['isLeftServer'];
    });
  }

  Future<void> _editNames() async {
    final l = TextEditingController(text: leftName);
    final r = TextEditingController(text: rightName);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Edit Nama Pemain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: l, decoration: InputDecoration(labelText: 'Nama Kiri')),
            TextField(controller: r, decoration: InputDecoration(labelText: 'Nama Kanan')),
            SizedBox(height: 8),
            Text('Pisahkan dua pemain dengan "&" jika ingin menampilkan dua nama.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('Batal')),
          ElevatedButton(onPressed: () {
            _pushUndo('names');
            setState(() {
              leftName = l.text.trim().isEmpty ? 'Pemain A & Pemain B' : l.text.trim();
              rightName = r.text.trim().isEmpty ? 'Pemain C & Pemain D' : r.text.trim();
            });
            Navigator.of(c).pop();
          }, child: Text('Simpan')),
        ],
      ),
    );
  }

  bool _isFinished() {
    if ((leftScore >= 30 || rightScore >= 30) && leftScore != rightScore) return true;
    return false;
  }

  String _winnerText() {
    if (!_isFinished()) return '';
    return leftScore > rightScore ? '$leftName MENANG' : '$rightName MENANG';
  }

  Widget _buildHalf({required bool left, required Color color, required String name, required int score, required VoidCallback onTap, required bool showServe}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: color,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(child: Text('Kades Cup\n2025 Adan-Adan', textAlign: TextAlign.center, style: TextStyle(fontSize: 120, fontWeight: FontWeight.w300))),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(children: [
                        if (showServe) Icon(Icons.sports_tennis, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Expanded(child: Text(name, style: TextStyle(fontSize: 22, color: Color(0xFFcfeaff), fontWeight: FontWeight.w700))),
                      ]),
                    ),
                  ),
                  Expanded(child: Center(child: Text('$score', style: TextStyle(fontSize: 220, color: Color(0xFFcfeaff))))),
                  SizedBox(height: 80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final winner = _winnerText();
    return Scaffold(
      body: Row(children: [
        _buildHalf(left: true, color: Colors.red.shade700, name: leftName, score: leftScore, onTap: _leftWinsRally, showServe: isLeftServer),
        _buildHalf(left: false, color: Colors.black, name: rightName, score: rightScore, onTap: _rightWinsRally, showServe: !isLeftServer),
      ]),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(onPressed: _newGame, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)), child: Text('New Game', style: TextStyle(color: Colors.black87))),
          ElevatedButton(onPressed: _editNames, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)), child: Text('Edit Nama', style: TextStyle(color: Colors.black87))),
          ElevatedButton(onPressed: _swapSides, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)), child: Text('Swap Side', style: TextStyle(color: Colors.black87))),
          ElevatedButton(onPressed: _undo, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)), child: Text('Undo', style: TextStyle(color: Colors.black87))),
        ]),
      ),
      floatingActionButton: _isFinished() ? FloatingActionButton.extended(onPressed: () {}, label: Text(winner), backgroundColor: Colors.orange) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
