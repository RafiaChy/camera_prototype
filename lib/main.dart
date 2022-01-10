import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

int seconds = 0;
Timer? timer;

class _MyAppState extends State<MyApp> {
  CameraController? controller;

  @override
  void initState() {
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    controller = CameraController(cameras!.last, ResolutionPreset.high);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // setState(() {});
      countDown();
      recordVideo();
    });

    super.initState();
  }

  Future<void> recordVideo() async {
    await controller!.startVideoRecording();
  }

  Future<void> saveVideoToGallery() async {
    final video = await controller!.stopVideoRecording();
    await GallerySaver.saveVideo(video.path);
    File(video.path).deleteSync();
  }

  void counterSetter() {
    while (seconds < 30) {
      seconds++;

      print('recording video');
    }
    // else {
    timer?.cancel();
    saveVideoToGallery();
    // }
  }

  void countDown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          counterSetter();
          print(seconds);
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !controller!.value.isInitialized
        ? const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CameraPreview(controller!),
                ],
              ),
            ),
          );
  }
}
