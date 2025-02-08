import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:ui/home.dart';
import 'package:ui/opencv.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InteractionScreen(),
        '/openCV': (context) => OpenCV(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({super.key});

  @override
  State<InteractionScreen> createState() => _InteractionScreenState();
}

class _InteractionScreenState extends State<InteractionScreen> {
  bool _showLottie = true;
  double _opacity = 1.0;

  void _hideLottie() {
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLottie = false;
      });
    });
  }

  Future<Uint8List> _loadSvgBytes(BuildContext context) async {
    final svgString = await DefaultAssetBundle.of(context).loadString('assets/images/start.svg');
    return Uint8List.fromList(utf8.encode(svgString));
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agreement', style: GoogleFonts.poppins()),
          content: Text('Do you agree to the terms and conditions?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Show Lottie animation again on decline
                setState(() {
                  _showLottie = true;
                  _opacity = 1.0; // Reset opacity for Lottie animation
                });
              },
              child: Text('Decline', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hideLottie();
              },
              child: Text('Agree', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_showLottie)
          FutureBuilder<Uint8List>(
            future: _loadSvgBytes(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading SVG: ${snapshot.error}'));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.memory(
                      snapshot.data!,
                      width: MediaQuery.of(context).size.width,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.15,
                          MediaQuery.of(context).size.height * 0.04,
                        ),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/openCV'),
                      child: Text(
                        'START',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        if (_showLottie)
          GestureDetector(
            onTap: () {
              _hideLottie(); // Hide the Lottie animation
              Future.delayed(const Duration(milliseconds: 500), _showAgreementDialog); // Show dialog after hiding
            },
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Lottie.network(
                  "https://lottie.host/27b89d8a-8cc0-4e1c-8e6b-c891c6625587/wH84MGpQL2.json",
                  width: 800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
