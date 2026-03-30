import 'package:flutter/material.dart';

class PickupScheduleScreen extends StatelessWidget {
  const PickupScheduleScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pickup Schedule',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Overlay
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE))),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.map, size: 80, color: Colors.green[200]),
                          // Mocking pins
                          const Positioned(
                            bottom: 50,
                            left: 60,
                            child: Icon(Icons.place, color: _primaryColor, size: 24),
                          ),
                          const Positioned(
                            top: 40,
                            right: 80,
                            child: Icon(Icons.place, color: Color(0xFF757575), size: 20),
                          ),
                          const Positioned(
                            top: 80,
                            right: 120,
                            child: Icon(Icons.local_airport, color: _primaryColor, size: 24),
                          ),
                        ],
                      ),
                    ),
                    
                    // Trip Sequence Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trip Sequence',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF2F4),
                              border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EDIT ROUTE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timeline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildTimelineStop(
                            index: 1,
                            title: 'Alfanar Restaurant',
                            subtitle: '8.4 km away',
                            isCompleted: true,
                            statusText: 'Arrived',
                            isFirst: true,
                            isLast: false,
                          ),
                          _buildTimelineStop(
                            index: 2,
                            title: 'Saudi Embassy',
                            subtitle: '9.1 km away',
                            isCompleted: false,
                            statusText: 'Pending',
                            isFirst: false,
                            isLast: false,
                          ),
                          _buildTimelineStop(
                            index: 3,
                            title: 'River Cafe',
                            subtitle: '10.2 km away',
                            isCompleted: false,
                            statusText: 'Pending',
                            isFirst: false,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    // Final Destination Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        'FINAL DESTINATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    // Final Destination Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Airport Base',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Terminal 1, Dubai International Airport',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation (Scheduling focus)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 1, // 'SCHEDULE' is selected based on mockup
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _primaryColor,
          unselectedItemColor: const Color(0xFF9E9E9E),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'SCHEDULE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              activeIcon: Icon(Icons.mail),
              label: 'INBOX',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStop({
    required int index,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required String statusText,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Line and Node
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isLast)
                  Positioned(
                    top: 36, // Start line below circle
                    bottom: 0,
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted ? _primaryColor : const Color(0xFFFDF2F4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isCompleted ? Colors.white : _primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32.0, top: 2), // Padding pushes next item down
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.my_location, size: 12, color: Color(0xFF9E9E9E)),
                            const SizedBox(width: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? _primaryColor : const Color(0xFF1976D2), // Using a blue for 'Pending'
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
}
