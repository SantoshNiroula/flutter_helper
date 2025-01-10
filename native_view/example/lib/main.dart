import 'package:flutter/material.dart';
import 'package:native_view/native_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraPreviewWidget());
  }
}

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late CameraController _controller;
  bool flashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController();
  }

  Future<void> _toggleFlash() async {
    flashOn = await _controller.toggleFlash();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pigeon Example'),
      ),
      body: AndroidView(viewType: '<view-id>'),
      floatingActionButton: Row(
        spacing: 16,
        children: [
          FloatingActionButton(
            onPressed: _toggleFlash,
            child: const Icon(
              Icons.flash_on,
            ),
          ),
          FloatingActionButton(
            onPressed: _controller.toggleCamera,
            child: const Icon(
              Icons.switch_camera,
            ),
          ),
        ],
      ),
    );
  }
}
