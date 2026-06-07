// ignore_for_file: unused_import, unnecessary_this, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, curly_braces_in_flow_control_structures

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String rating;
  final released_year;
  final String url;
  final List type;

  const MovieCard({
    Key? key,
    required this.title,
    required this.rating,
    required this.released_year,
    required this.url,
    required this.type,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPageBody(moviename: widget.title),
            ),
          );
        },
        child: Container(
          height: 40.h,
          width: 90.w,
          decoration: BoxDecoration(
            color: HexColor("#1E1E1E"),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: HexColor("#000000").withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster image with improved styling
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  height: 37.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        widget.url.toString() == "NULL"
                            ? Image.asset(
                              "assets/images/loading.png",
                              fit: BoxFit.cover,
                            )
                            : CachedNetworkImage(
                              imageUrl: widget.url.toString(),
                              placeholder:
                                  (context, url) => Image.asset(
                                    "assets/images/loading.png",
                                    fit: BoxFit.cover,
                                  ),
                              errorWidget:
                                  (context, url, error) => Image.asset(
                                    "assets/images/loading.png",
                                    fit: BoxFit.cover,
                                  ),
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              // Movie details column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 2.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with gradient text
                      Container(
                        width: double.infinity,
                        child: TextScroll(
                          widget.title.toString() == "NULL"
                              ? "N/A"
                              : widget.title.toString(),
                          velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                          pauseBetween: Duration(milliseconds: 1000),
                          mode: TextScrollMode.bouncing,
                          style: TextStyle(
                            color: HexColor("#FFFFFF"),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.left,
                          selectable: false,
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // Rating with improved styling
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: HexColor("#7220C9").withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text(
                              widget.rating.toLowerCase() == "NULL"
                                  ? "N/A"
                                  : widget.rating.toLowerCase(),
                              style: TextStyle(
                                color: HexColor("#FFFFFF"),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Release year with icon
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: HexColor("#DEDEDE"),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.released_year.toString() == "null"
                                ? "N/A"
                                : widget.released_year.toString(),
                            style: TextStyle(
                              color: HexColor("#DEDEDE"),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // Genre chips
                      widget.type.isEmpty
                          ? Container()
                          : Flexible(
                            fit: FlexFit.loose,
                            child: getgenres(widget.type),
                          ),

                      // Add a view button
                      Spacer(),
                      // Align(
                      //   alignment: Alignment.bottomRight,
                      //   child: Padding(
                      //     padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                      //     child: Container(
                      //       height: 3.h,
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder:
                      //                   (context) => DetailsPageBody(
                      //                     moviename: widget.title,
                      //                   ),
                      //             ),
                      //           );
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: HexColor("#7220C9"),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(20),
                      //           ),
                      //           padding: EdgeInsets.symmetric(horizontal: 12),
                      //         ),
                      //         child: Text(
                      //           "View",
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getgenres(List data) {
    if (data.isEmpty) return Container();

    // Giới hạn số lượng thể loại hiển thị
    final displayCount = data.length > 3 ? 3 : data.length;
    final displayData = data.sublist(0, displayCount);

    return Container(
      height: 3.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayData.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: HexColor("#7220C9"),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: HexColor("#7220C9").withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  displayData[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
