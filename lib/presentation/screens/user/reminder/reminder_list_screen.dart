import 'package:flutter/material.dart';
import '../../../navigation/app_router.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  int _selectedIndex = 2; // SET SESUAI MENU REMINDER (ICON BELL)

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.of(context).pushNamed(AppRouter.userHome);
        break;
      case 1:
        Navigator.of(context).pushNamed(AppRouter.searchScreen);
        break;
      case 2:
        // Ini halaman Reminder
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRouter.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =================== CUSTOM APP BAR ===================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF1A237E),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "BENGKELBELL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.search, color: Colors.white, size: 26),
            ],
          ),
        ),
      ),

      // =================== BODY ===================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "5 Pengingat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Teratas",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // =================== TOP REMINDER CARD ===================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Service Motor",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "9.00 Minggu, 26 Mei",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                "Pengingat",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),

              // =================== GRID REMINDER ===================
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                children: [
                  _menuCard("Hari Ini", "Tidak ada pengingat", Icons.today),
                  _menuCard("Besok", "Tidak ada pengingat",
                      Icons.calendar_today_outlined),
                  _menuCard("Semua Pengingat", "", Icons.calendar_month),
                  _menuCard("Riwayat Pengingat", "", Icons.history),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // =================== NAVBAR SAMA PERSIS HOMESCREEN ===================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1E3A8A),
            selectedItemColor: const Color(0xFFFFA500),
            unselectedItemColor: Colors.white.withOpacity(0.6),
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================== CARD WIDGET ===================
  Widget _menuCard(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.red.shade700),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
