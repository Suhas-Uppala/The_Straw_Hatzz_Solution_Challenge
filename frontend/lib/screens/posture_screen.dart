import 'dart:io';
import 'package:flutter/material.dart';

class PostureScreen extends StatefulWidget {
  const PostureScreen({Key? key}) : super(key: key);

  @override
  _PostureScreenState createState() => _PostureScreenState();
}

class _PostureScreenState extends State<PostureScreen> {
  Process? _postureProcess;
  bool _isDetecting = false;

  Future<void> _startPostureDetection() async {
    if (_isDetecting) return;
    setState(() {
      _isDetecting = true;
    });

    const String pythonScriptPath = 'path/to/your/posture_detection_script.py';

    try {
      _postureProcess = await Process.start('python', [pythonScriptPath]);

      _postureProcess!.stdout
          .transform(SystemEncoding().decoder)
          .listen((data) {
        print('Python stdout: $data');
      });
      _postureProcess!.stderr
          .transform(SystemEncoding().decoder)
          .listen((data) {
        print('Python stderr: $data');
      });
    } catch (e) {
      print('Error launching posture detection: $e');
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _stopPostureDetection() async {
    if (_postureProcess != null) {
      _postureProcess!.kill();
      setState(() {
        _isDetecting = false;
      });
    }
  }

  @override
  void dispose() {
    _stopPostureDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Press the button to start/stop posture detection'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _isDetecting ? _stopPostureDetection : _startPostureDetection,
              child: Text(_isDetecting ? 'Stop Detection' : 'Start Detection'),
            ),
          ],
        ),
      ),
    );
  }
}
