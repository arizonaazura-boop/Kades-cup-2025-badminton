// Kades Cup 2025 Adan-Adan - Service Point System (single game to 30)
// Landscape-oriented scoreboard with Start Match screen and shuttlecock serve indicator.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to landscape only
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
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kades Cup', style: titleStyle.copyWith(fontSize: 48, color: Colors.redAccent)),
                    SizedBox(height: 8),
                    Text('2025 Adan-Adan', style: titleStyle.copyWith(fontSize: 32, color: Colors.white70)),
                    SizedBox(height: 24),
                    Text('Service-Point System\nSingle game to 30 points\nShuttlecock indicates server\nTap serving side to score', style: TextStyle(color: Colors.white70, fontSize: 18)),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ScoreboardPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      ),
                      child: Text('Start Match', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // right side preview card
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Preview', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 12),
                        Container(
                          width: 420,
                          height: 180,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(color: Colors.red.shade700, child: Center(child: Text('Pemain A\n& Pemain B', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
                              ),
                              Expanded(
                                child: Container(color: Colors.black, child: Center(child: Text('Pemain C\n& Pemain D', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchEvent {
  final String type; // 'point' or 'serve' or 'swap' or 'names'
  final int leftScore;
  final int rightScore;
  final bool isLeftServer;

  MatchEvent({
    required this.type,
    required this.leftScore,
    required this.rightScore,
    required this.isLeftServer,
  });
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

  // true = left side serving; false = right side serving
  bool isLeftServer = true;

  // undo stack of MatchEvent
  final List<MatchEvent> undoStack = [];

  // helper to push current state to undo stack
  void pushUndo(String type) {
    undoStack.add(MatchEvent(
      type: type,
      leftScore: leftScore,
      rightScore: rightScore,
      isLeftServer: isLeftServer,
    ));
    if (undoStack.length > 300) undoStack.removeAt(0);
  }

  bool isFinished() {
    if ((leftScore >= 30 || rightScore >= 30) && leftScore != rightScore) {
      if (leftScore > rightScore && leftScore >= 30) return true;
      if (rightScore > leftScore && rightScore >= 30) return true;
    }
    return false;
  }

  String winnerText() {
    if (!isFinished()) return '';
    return leftScore > rightScore ? '$leftName MENANG' : '$rightName MENANG';
  }

  void leftWinsRally() {
    // if left is serving, point awarded; else serve changes
    if (isFinished()) return;
    pushUndo('rally');
    setState(() {
      if (isLeftServer) {
        leftScore += 1;
      } else {
        // only change server
        isLeftServer = true;
      }
    });
  }

  void rightWinsRally() {
    if (isFinished()) return;
    pushUndo('rally');
    setState(() {
      if (!isLeftServer) {
        rightScore += 1;
      } else {
        isLeftServer = false;
      }
    });
  }

  void swapSides() {
    pushUndo('swap');
    setState(() {
      final tmpName = leftName;
      leftName = rightName;
      rightName = tmpName;
      final tmpScore = leftScore;
      leftScore = rightScore;
      rightScore = tmpScore;
      isLeftServer = !isLeftServer;
    });
  }

  void newGame() {
    pushUndo('newgame');
    setState(() {
      leftScore = 0;
      rightScore = 0;
      // default server: left side
      isLeftServer = true;
      // keep names as-is
      undoStack.clear();
    });
  }

  void undo() {
    if (undoStack.isEmpty) return;
    final last = undoStack.removeLast();
    setState(() {
      leftScore = last.leftScore;
      rightScore = last.rightScore;
      isLeftServer = last.isLeftServer;
    });
  }

  Future<void> editNamesDialog() async {
    final leftController = TextEditingController(text: leftName);
    final rightController = TextEditingController(text: rightName);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Edit Nama Pemain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: leftController, decoration: InputDecoration(labelText: 'Nama Kiri')),
            TextField(controller: rightController, decoration: InputDecoration(labelText: 'Nama Kanan')),
            SizedBox(height:8),
            Text('Pisahkan dua pemain dengan "&" jika ingin menampilkan dua nama pada sisi kiri/kanan.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('Batal')),
          ElevatedButton(
              onPressed: () {
                pushUndo('names');
                setState(() {
                  leftName = leftController.text.trim().isEmpty ? 'Pemain A & Pemain B' : leftController.text.trim();
                  rightName = rightController.text.trim().isEmpty ? 'Pemain C & Pemain D' : rightController.text.trim();
                });
                Navigator.of(c).pop();
              },
              child: Text('Simpan')),
        ],
      ),
    );
  }

  Widget buildHalf({
    required bool leftSide,
    required Color color,
    required String name,
    required int score,
    required VoidCallback onTapRallyWin,
    required bool showServeIcon,
  }) {
    final media = MediaQuery.of(context);
    final largeFont = media.size.height * 0.25;
    final nameFont = media.size.height * 0.05;

    return Expanded(
      child: GestureDetector(
        onTap: onTapRallyWin,
        child: Container(
          color: color,
          child: Stack(
            children: [
              // watermark
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(
                    child: Text('Kades Cup\n2025 Adan-Adan', textAlign: TextAlign.center, style: TextStyle(fontSize: largeFont*0.7, fontWeight: FontWeight.w300)),
                  ),
                ),
              ),

              // content
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // top name and serve icon
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        children: [
                          if (showServeIcon) ...[
                            Icon(Icons.sports_tennis, size: 28, color: Colors.white),
                            SizedBox(width: 8),
                          ],
                          Expanded(child: Text(name, style: TextStyle(fontSize: nameFont, color: Color(0xFFcfeaff), fontWeight: FontWeight.w700))),
                        ],
                      ),
                    ),
                  ),

                  // center score
                  Expanded(
                    child: Center(
                      child: Text('$score', style: TextStyle(fontSize: largeFont, color: Color(0xFFcfeaff), fontWeight: FontWeight.w400)),
                    ),
                  ),

                  SizedBox(height: 60),
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
    final winner = winnerText();
    return Scaffold(
      body: Row(
        children: [
          buildHalf(
            leftSide: true,
            color: Colors.red.shade700,
            name: leftName,
            score: leftScore,
            onTapRallyWin: leftWinsRally,
            showServeIcon: isLeftServer,
          ),
          buildHalf(
            leftSide: false,
            color: Colors.black,
            name: rightName,
            score: rightScore,
            onTapRallyWin: rightWinsRally,
            showServeIcon: !isLeftServer,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: newGame,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)),
              child: Text('New Game', style: TextStyle(color: Colors.black87)),
            ),
            ElevatedButton(
              onPressed: editNamesDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)),
              child: Text('Edit Nama', style: TextStyle(color: Colors.black87)),
            ),
            ElevatedButton(
              onPressed: swapSides,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)),
              child: Text('Swap Side', style: TextStyle(color: Colors.black87)),
            ),
            ElevatedButton(
              onPressed: undo,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFcfeaff)),
              child: Text('Undo', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
      // winner banner
      floatingActionButton: isFinished() ? FloatingActionButton.extended(
        onPressed: (){},
        label: Text(winner),
        backgroundColor: Colors.orange,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
