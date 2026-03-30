import 'package:flutter/material.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Off-white/light gray
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'My Trips',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: Color(0xFF9E9E9E),
            indicatorColor: _primaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'UPCOMING'),
              Tab(text: 'PAST'),
              Tab(text: 'CANCELED'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              // UPCOMING TAB
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                   _buildActiveTripCard(),
                   const SizedBox(height: 16),
                   _buildUpcomingTripCard('Tomorrow • 08:30 AM', 'Amman → Irbid', '15.00 JOD'),
                ],
              ),
              // PAST TAB
              const Center(
                child: Text('No past trips yet.', style: TextStyle(color: Color(0xFF757575))),
              ),
              // CANCELED TAB
              const Center(
                child: Text('No canceled trips.', style: TextStyle(color: Color(0xFF757575))),
              ),
            ],
          ),
        ),

        // Bottom Navigation
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: 1, // 'My Trips' tab
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
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'MY TRIPS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'CHAT',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTripCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Replaced withOpacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Snippet Placeholder
          Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFE0F7FA), // Soft blue to mimic map
            child: const Center(
              child: Icon(Icons.map, color: Colors.blueAccent, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ACTIVE TRIP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const Text(
                      '12.50 JOD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Route
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _primaryColor, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Amman, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_city, color: Color(0xFF9E9E9E), size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Irbid, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Driver Details & Actions
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFF5F5F5),
                      child: Icon(Icons.person, color: _primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hassan Abdullah',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
                              const SizedBox(width: 4),
                              const Text('4.9', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chat_bubble_outline, color: _primaryColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone, color: _primaryColor, size: 20),
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

  Widget _buildUpcomingTripCard(String time, String route, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            route,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }
}
