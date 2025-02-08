import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:ui/footer.dart';
import 'package:ui/spotify/spotify_page.dart';
import 'package:ui/user_details.dart';
import 'package:ui/weather/weather_page.dart';
import 'google_map_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to '/' after 30 seconds
    Future.delayed(const Duration(seconds: 300), () {
      Navigator.of(context).pushNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black,
                        ),
                      ),
                      child: Center(
                        // child: SvgPicture.asset(
                        //   '../assets/images/main.svg',
                        //   fit: BoxFit.contain,
                        child: Lottie.asset(
                          '../assets/files/main.json', // Use Lottie asset
                          fit: BoxFit.cover,
                          width: 900,
                          // height: double.infinity,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black,
                              ),
                            ),
                            child: GoogleMapScreen(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black,
                              ),
                            ),
                            child: WeatherPage(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black,
                        ),
                      ),
                      child: UserDetails("Cupertino"),
                    ),
                    Expanded(
                      child: Container(
                          height: screenHeight * 0.64,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.black,
                            ),
                          ),
                          child: SongListScreen()),
                    ),
                    Container(
                      height: screenHeight * 0.10,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black,
                        ),
                      ),
                      child: Footer(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
