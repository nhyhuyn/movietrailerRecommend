import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/Util/ApiService.dart';

class BookingScreen extends StatefulWidget {
  final int id;
  final String moviename;
  final String posterPath;

  const BookingScreen({
    Key? key,
    required this.id,
    required this.moviename,
    required this.posterPath,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Booking variables
  final List<DateTime> _availableDates = [];
  final List<String> _availableTimes = [
    "10:00 AM",
    "12:30 PM",
    "03:15 PM",
    "06:00 PM",
    "08:45 PM",
    "11:30 PM",
  ];

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "06:00 PM";
  List<int> _selectedSeats = [];
  List<int> _bookedSeats = []; // Cập nhật từ MySQL
  final int _ticketPrice = 95000; // VND
  bool _isProcessingPayment = false;
  int _currentStep = 0; // 0: select date/time, 1: select seats, 2: payment

  // Seat layout configuration
  final int _rowCount = 8;
  final int _colCount = 9;
  final List<int> _vipSeats = [28, 29, 30, 31, 32, 37, 38, 39, 40, 41];

  @override
  void initState() {
    super.initState();
    _generateAvailableDates();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animationController.forward();

    // Lấy ghế đã đặt cho ngày và giờ mặc định
    _fetchBookedSeats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateAvailableDates() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _availableDates.add(now.add(Duration(days: i)));
    }
  }

  // Lấy danh sách ghế đã đặt từ MySQL dựa trên ngày và giờ
  Future<void> _fetchBookedSeats() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = DateFormat(
        'HH:mm:ss',
      ).format(DateFormat('hh:mm a').parse(_selectedTime));

      // Gọi getShowtimes để lấy danh sách lịch chiếu
      final showtimes = await ApiService.getShowtimes(widget.id, formattedDate);
      final matchingShowtime = showtimes.firstWhere(
        (showtime) =>
            showtime['show_time'] == formattedTime &&
            showtime['theater_name'] == "CGV Cinemas - Vincom Center",
        orElse: () => {},
      );

      if (matchingShowtime.isNotEmpty) {
        final showtimeId = matchingShowtime['id'];
        final bookedSeats = await ApiService.getSeatAvailability(showtimeId);
        setState(() {
          _bookedSeats = bookedSeats;
        });
      } else {
        setState(() {
          _bookedSeats = [];
        });
      }
    } catch (e) {
      print('Error fetching booked seats: $e');
      setState(() {
        _bookedSeats = [];
      });
    }
  }

  int _getSeatPrice(int seatNumber) {
    return _vipSeats.contains(seatNumber) ? _ticketPrice + 30000 : _ticketPrice;
  }

  String _formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  int _getTotalPrice() {
    int total = 0;
    for (int seat in _selectedSeats) {
      total += _getSeatPrice(seat);
    }
    return total;
  }

  String _getSeatName(int seatIndex) {
    final rowName = String.fromCharCode(65 + (seatIndex ~/ _colCount));
    final seatNum = (seatIndex % _colCount) + 1;
    return '$rowName$seatNum';
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Chuẩn bị dữ liệu
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = DateFormat(
        'HH:mm:ss',
      ).format(DateFormat('hh:mm a').parse(_selectedTime));

      // Kiểm tra lịch chiếu hiện có
      final showtimes = await ApiService.getShowtimes(widget.id, formattedDate);
      final matchingShowtime = showtimes.firstWhere(
        (showtime) =>
            showtime['show_time'] == formattedTime &&
            showtime['theater_name'] == "CGV Cinemas - Vincom Center",
        orElse: () => {},
      );

      int showtimeId;
      if (matchingShowtime.isNotEmpty) {
        showtimeId = matchingShowtime['id'];
      } else {
        // Tạo lịch chiếu mới
        final showtimeResult = await ApiService.createShowtime(
          movieId: widget.id.toString(),
          showDate: formattedDate,
          showTime: formattedTime,
          theaterName: "CGV Cinemas - Vincom Center",
        );

        if (showtimeResult == null || showtimeResult['showtime_id'] == null) {
          throw Exception('Failed to create showtime');
        }
        showtimeId = showtimeResult['showtime_id'];
      }

      // Kiểm tra ghế đã đặt
      final bookedSeats = await ApiService.getSeatAvailability(showtimeId);
      if (_selectedSeats.any((seat) => bookedSeats.contains(seat))) {
        final bookedSeatNames = _selectedSeats
            .where((seat) => bookedSeats.contains(seat))
            .map((seat) => _getSeatName(seat))
            .join(', ');
        throw Exception('Seats $bookedSeatNames are already booked');
      }

      // Gọi createBooking để lưu thông tin đặt vé
      final bookingResult = await ApiService.createBooking(
        showtimeId: showtimeId,
        seatIds: _selectedSeats,
        totalPrice: _getTotalPrice().toDouble(),
        paymentMethod: "Credit/Debit Card",
      );

      if (bookingResult != null) {
        // Cập nhật lại _bookedSeats sau khi đặt vé thành công
        setState(() {
          _bookedSeats.addAll(_selectedSeats);
        });
        _showBookingConfirmation();
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: HexColor("#1E1E2A"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: HexColor("#2FC162"), size: 30),
                SizedBox(width: 10),
                Text(
                  'Booking Successful',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your tickets have been booked successfully!',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                SizedBox(height: 15),
                _buildConfirmationItem('Movie', widget.moviename),
                _buildConfirmationItem(
                  'Date',
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                ),
                _buildConfirmationItem('Time', _selectedTime),
                _buildConfirmationItem(
                  'Seats',
                  _selectedSeats.map((seat) => _getSeatName(seat)).join(', '),
                ),
                _buildConfirmationItem(
                  'Total',
                  _formatCurrency(_getTotalPrice()),
                ),
                SizedBox(height: 10),
                Text(
                  'An email with the tickets has been sent to your registered email address.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: HexColor("#7220C9"),
                ),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        itemBuilder: (context, index) {
          final date = _availableDates[index];
          final isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedSeats.clear(); // Xóa ghế đã chọn khi đổi ngày
                _bookedSeats.clear(); // Xóa ghế đã đặt để lấy lại từ server
              });
              _fetchBookedSeats(); // Lấy ghế đã đặt cho ngày mới
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 8),
              width: 70,
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HexColor("#7220C9"),
                            HexColor("#7220C9").withOpacity(0.7),
                          ],
                        )
                        : null,
                color: isSelected ? null : HexColor("#1E1E2A"),
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: HexColor("#7220C9").withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    DateFormat('dd').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _availableTimes.map((time) {
            final isSelected = time == _selectedTime;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = time;
                  _selectedSeats.clear(); // Xóa ghế đã chọn khi đổi giờ
                  _bookedSeats.clear(); // Xóa ghế đã đặt để lấy lại từ server
                });
                _fetchBookedSeats(); // Lấy ghế đã đặt cho giờ mới
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              HexColor("#7220C9"),
                              HexColor("#7220C9").withOpacity(0.7),
                            ],
                          )
                          : null,
                  color: isSelected ? null : HexColor("#1E1E2A"),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: HexColor("#7220C9").withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSeatLayout() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
              Container(
                height: 25,
                width: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Center(
                  child: Text(
                    'SCREEN',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _colCount,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: _rowCount * _colCount,
            itemBuilder: (context, index) {
              final bool isBooked = _bookedSeats.contains(index);
              final bool isSelected = _selectedSeats.contains(index);
              final bool isVIP = _vipSeats.contains(index);
              final bool isAisle = index % _colCount == 4;

              if (isAisle) {
                return SizedBox();
              }

              return GestureDetector(
                onTap:
                    isBooked
                        ? null
                        : () {
                          setState(() {
                            if (isSelected) {
                              _selectedSeats.remove(index);
                            } else {
                              _selectedSeats.add(index);
                            }
                          });
                        },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color:
                        isBooked
                            ? Colors.grey.withOpacity(0.3)
                            : isSelected
                            ? HexColor("#7220C9")
                            : isVIP
                            ? HexColor("#2FC162").withOpacity(0.7)
                            : HexColor("#1E1E2A"),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isBooked
                              ? Colors.transparent
                              : isSelected
                              ? Colors.white.withOpacity(0.5)
                              : isVIP
                              ? HexColor("#2FC162")
                              : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getSeatName(index),
                      style: GoogleFonts.poppins(
                        color:
                            isBooked
                                ? Colors.grey.withOpacity(0.5)
                                : isSelected || isVIP
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSeatIndicator(
                "Available",
                HexColor("#1E1E2A"),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              SizedBox(width: 16),
              _buildSeatIndicator(
                "Selected",
                HexColor("#7220C9"),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              SizedBox(width: 16),
              _buildSeatIndicator(
                "VIP",
                HexColor("#2FC162").withOpacity(0.7),
                border: Border.all(color: HexColor("#2FC162"), width: 1.5),
              ),
              SizedBox(width: 16),
              _buildSeatIndicator("Booked", Colors.grey.withOpacity(0.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatIndicator(String label, Color color, {BoxBorder? border}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HexColor("#1E1E2A"),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Divider(color: Colors.white24, height: 25),
              _buildOrderSummaryItem('Movie', widget.moviename),
              _buildOrderSummaryItem(
                'Date & Time',
                '${DateFormat('EEE, dd MMM').format(_selectedDate)} • $_selectedTime',
              ),
              _buildOrderSummaryItem(
                'Seats',
                _selectedSeats.map((seat) => _getSeatName(seat)).join(', '),
              ),
              Divider(color: Colors.white24, height: 25),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedSeats.length,
                itemBuilder: (context, index) {
                  final seatNumber = _selectedSeats[index];
                  final isVIP = _vipSeats.contains(seatNumber);
                  final price = _getSeatPrice(seatNumber);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seat ${_getSeatName(seatNumber)} ${isVIP ? "(VIP)" : ""}',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                        Text(
                          _formatCurrency(price),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 6),
              Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _formatCurrency(_getTotalPrice()),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: HexColor("#7220C9"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          'Payment Method',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HexColor("#1E1E2A"),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: HexColor("#7220C9").withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.credit_card,
                  color: HexColor("#1E1E2A"),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit/Debit Card',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Pay securely with your card',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Radio(
                value: true,
                groupValue: true,
                onChanged: (_) {},
                activeColor: HexColor("#7220C9"),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HexColor("#1E1E2A"),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-Wallet',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Pay with MoMo, ZaloPay, VNPay',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Radio(
                value: false,
                groupValue: true,
                onChanged: (_) {},
                activeColor: HexColor("#7220C9"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: HexColor("#1E1E2A"),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image:
                          widget.posterPath != null
                              ? NetworkImage(
                                "https://image.tmdb.org/t/p/w500${widget.posterPath}",
                              )
                              : AssetImage("assets/images/loading.png")
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.moviename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HexColor("#7220C9"),
                        ),
                      ),
                      Text(
                        'CGV Cinemas - Vincom Center',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildStepIndicator(0, "Date & Time"),
                _buildStepConnector(0),
                _buildStepIndicator(1, "Seats"),
                _buildStepConnector(1),
                _buildStepIndicator(2, "Payment"),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child:
                    _currentStep == 0
                        ? _buildDateTimeSelector()
                        : _currentStep == 1
                        ? _buildSeatSelector()
                        : _buildPaymentSection(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HexColor("#1E1E2A"),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                          if (_currentStep == 0) {
                            _selectedSeats.clear();
                            _bookedSeats.clear();
                            _fetchBookedSeats(); // Lấy lại ghế đã đặt
                          }
                        });
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                    ),
                  Spacer(),
                  if (_currentStep == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatCurrency(_getTotalPrice()),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        _isProcessingPayment
                            ? null
                            : () {
                              if (_currentStep == 0) {
                                setState(() {
                                  _currentStep = 1;
                                });
                              } else if (_currentStep == 1) {
                                if (_selectedSeats.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please select at least one seat',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _currentStep = 2;
                                  });
                                }
                              } else if (_currentStep == 2) {
                                _processPayment();
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor("#7220C9"),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: HexColor("#7220C9").withOpacity(0.5),
                    ),
                    child:
                        _isProcessingPayment
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _currentStep == 0
                                  ? 'Select Seats'
                                  : _currentStep == 1
                                  ? 'Continue to Payment'
                                  : 'Pay ${_formatCurrency(_getTotalPrice())}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final bool isCompleted = _currentStep > step;
    final bool isCurrent = _currentStep == step;

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  isCurrent || isCompleted
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          HexColor("#7220C9"),
                          HexColor("#7220C9").withOpacity(0.7),
                        ],
                      )
                      : null,
              color:
                  isCurrent || isCompleted
                      ? null
                      : Colors.grey.withOpacity(0.3),
            ),
            child: Center(
              child:
                  isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                        '${step + 1}',
                        style: GoogleFonts.poppins(
                          color: isCurrent ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isCurrent ? Colors.white : Colors.white70,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final bool isActive = _currentStep > step;

    return Container(
      width: 20,
      height: 2,
      color: isActive ? HexColor("#7220C9") : Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildDateTimeSelector() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          _buildDateSelector(),
          SizedBox(height: 30),
          Text(
            'Select Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          _buildTimeSelector(),
        ],
      ),
    );
  }

  Widget _buildSeatSelector() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Seats',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Selected: ${_selectedSeats.length}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      _selectedSeats.isEmpty ? Colors.red : HexColor("#2FC162"),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSeatLayout(),
          if (_selectedSeats.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HexColor("#1E1E2A"),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Regular Seat',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      Text(
                        _formatCurrency(_ticketPrice),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VIP Seat',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      Text(
                        _formatCurrency(_ticketPrice + 30000),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total (${_selectedSeats.length} seats)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatCurrency(_getTotalPrice()),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: HexColor("#7220C9"),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
