import 'package:flutter/material.dart';
import 'package:quick_court_booking/screens/owner/fnb/fnb_menu_crud_screen.dart';
import 'package:quick_court_booking/screens/owner/fnb/fnb_order_list_screen.dart';

class FnbDashboardScreen extends StatelessWidget {
  final int venueId;

  const FnbDashboardScreen({Key? key, required this.venueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DashboardCard(
              icon: Icons.list_alt,
              label: 'Order List',
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FnbOrderListScreen(venueId: venueId),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _DashboardCard(
              icon: Icons.fastfood,
              label: 'Menu List',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FnbMenuCrudScreen(venueId: venueId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shadowColor = color.withOpacity(0.3);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: shadowColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 30,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 24),
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
