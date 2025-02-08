import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'logger.dart';
import 'package:lottie/lottie.dart';

class OpenCV extends StatefulWidget {
  const OpenCV({super.key});

  @override
  State<OpenCV> createState() => _OpenCVState();
}

class _OpenCVState extends State<OpenCV> with SingleTickerProviderStateMixin {
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _recordedBlobs = [];
  bool _isRecording = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _stopMediaStream();
    _controller.dispose();
    super.dispose();
  }

  void _stopMediaStream() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _mediaRecorder = null;
  }

  Future<void> _requestCameraPermission() async {
    try {
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
      });

      AppLogger.i('Camera permission granted');
      _startRecording(_mediaStream!);
    } catch (e) {
      AppLogger.e('Camera permission denied: $e');
    }
  }

  void _startRecording(html.MediaStream stream) {
    setState(() {
      _isRecording = true;
    });

    _mediaRecorder = html.MediaRecorder(stream);

    _mediaRecorder!.addEventListener('dataavailable', (event) {
      final blobEvent = event as html.BlobEvent;
      final blob = blobEvent.data;
      if (blob != null) {
        _recordedBlobs.add(blob);
      }
    });

    _mediaRecorder!.addEventListener('stop', (event) {
      final blob = html.Blob(_recordedBlobs, 'video/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'video.webm')
        ..click();
      html.Url.revokeObjectUrl(url);
      AppLogger.i('Video saved successfully');

      _stopMediaStream();

      setState(() {
        _isRecording = false;
      });

      Navigator.pushNamed(context, '/home');
    });

    _mediaRecorder!.start();

    Future.delayed(const Duration(seconds: 8), () {
      if (_isRecording) {
        _mediaRecorder!.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isRecording
            ? Lottie.network(
                'https://lottie.host/c3f1342b-565f-4f5b-9331-de125de88fd5/MeIEd6asDQ.json',
                controller: _controller,
                repeat: true,
                animate: true,
                onLoaded: (composition) {
                  _controller
                    ..duration = Duration(
                        milliseconds:
                            (composition.duration.inMilliseconds / 0.7).round())
                    ..repeat();
                },
              )
            : const Text('Recording will start when permissions are granted.'),
      ),
    );
  }
}
