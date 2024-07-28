import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:groshop/Theme/colors.dart';

Container buildRating(BuildContext context, {double avrageRating = 0.0}) {
  return Container(
    // padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
    // height: 30,
    // decoration: BoxDecoration(
    //   // color: Colors.green,
    //   borderRadius: BorderRadius.circular(8),
    // ),
    child: RatingBar(
      itemSize: 25,

      initialRating: avrageRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      // itemBuilder: (context, _) => Icon(
      //   Icons.star,
      //   color: Colors.amber,
      // ),
      onRatingUpdate: (rating) {  print(rating);  },
      ratingWidget: RatingWidget(
        full: IconButton(
          icon: ImageIcon(AssetImage('assets/Icon_star.png')),
          iconSize: 25,
          color: kRatingStar,
          onPressed: () {}),
        half: IconButton(
          icon: ImageIcon(AssetImage('assets/Icon_star_half.png')),
          color: kRatingStar,
          iconSize: 25,
          onPressed: () {}),
        empty: IconButton(
          icon: ImageIcon(AssetImage('assets/without_fill_star.png')),
          color: kRatingStarNull,
          iconSize: 25,
          onPressed: () {}),
      ),
    ),
  );
}

class GUIDGen {
  static String generate() {
    Random random = new Random(DateTime.now().millisecondsSinceEpoch);

    final String hexDigits = "0123456789abcdef";
    final List<String> uuid = new List<String>(36);

    for (int i = 0; i < 36; i++) {
      final int hexPos = random.nextInt(16);
      uuid[i] = (hexDigits.substring(hexPos, hexPos + 1));
    }

    int pos = (int.parse(uuid[19], radix: 16) & 0x3) |
        0x8; // bits 6-7 of the clock_seq_hi_and_reserved to 01

    uuid[14] = "4"; // bits 12-15 of the time_hi_and_version field to 0010
    uuid[19] = hexDigits.substring(pos, pos + 1);

    uuid[8] = uuid[13] = uuid[18] = uuid[23] = "-";

    final StringBuffer buffer = new StringBuffer();
    buffer.writeAll(uuid);
    return buffer.toString();
  }
}
