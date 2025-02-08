import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchApp(String urlScheme, String webUrl) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme);
    } else {
      await launch(webUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E2B5F), 
            Color(0xFF1C1C1C),
          ])
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // YouTube Button
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: () => _launchApp('vnd.youtube://', 'https://www.youtube.com'),
                icon: SvgPicture.asset(
                  '../assets/icons/youtube.svg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
        
            // Watcha Button
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: () => _launchApp('watcha://', 'https://watcha.com'),
                icon: SvgPicture.asset(
                  '../assets/icons/watcha.svg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
        
            // Tving Button
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: () => _launchApp('tving://', 'http://127.0.0.1:5000/player'),
                icon: SvgPicture.asset(
                  '../assets/icons/tving.svg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
        
            // Netflix Button
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: () => _launchApp('nflx://', 'https://www.netflix.com'),
                icon: SvgPicture.asset(
                  '../assets/icons/netflix.svg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
