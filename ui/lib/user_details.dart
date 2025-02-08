import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'weather/city_timezones.dart';

class UserDetails extends StatelessWidget {
  final String _cityName;

  const UserDetails(this._cityName, {super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final DateTime time = tz.TZDateTime.now(
      tz.getLocation(cityTimeZones[_cityName] ?? 'Asia/Seoul'),
    );

    final String formattedTime =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    return Scaffold(
        body: Stack(children: [
      SvgPicture.asset(
        '../assets/images/user_backround.svg',
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 50,
          ),
          Text(
            formattedTime,
            style: GoogleFonts.poppins(
                fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              SizedBox(width: screenWidth * 0.1),
              SvgPicture.asset(
                '../assets/icons/user.svg',
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Ibrokhim Tate',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          Row(children: [
            SizedBox(width: screenWidth * 0.1),
            SvgPicture.asset(
              '../assets/icons/marker.svg',
            ),
            SizedBox(width: 8),
            Text(
              'One Apple Park Way, Cupertino, CA 95014',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ])
        ],
      ),
      
    ]));
  }
}
