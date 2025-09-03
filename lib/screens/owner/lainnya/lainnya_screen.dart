import 'package:flutter/material.dart';
import 'package:quick_court_booking/models/venue_model.dart';

class OwnerVenueMoreScreen extends StatelessWidget {
  final Venue venue;

  const OwnerVenueMoreScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final imageUrl = venue.imageUrl.isNotEmpty
        ? (venue.imageUrl.startsWith("http")
            ? venue.imageUrl
            : "http://192.168.1.22:8000/storage/${venue.thumbnail}")
        : 'https://via.placeholder.com/150';

    print('Debug: Image URL yang dipakai -> $imageUrl');
    print('Debug: venue.imageUrl = "${venue.imageUrl}"');
    print('Debug: venue.thumbnail = "${venue.thumbnail}"');
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported,
                      size: 30, color: Colors.grey);
                },
              ),
            ),
          ),
          title: Text(venue.name),
          subtitle: TextButton(
            onPressed: () {
              // TODO: Navigasi ke halaman profil venue
            },
            child: const Text("Lihat Profil"),
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Informasi Venue",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _menuItem(Icons.assessment, "Performa Venue", () {
          // TODO: Navigasi ke performa venue
        }),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Pengaturan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _menuItem(Icons.settings, "Pengaturan Venue", () {
          // TODO: Navigasi ke pengaturan venue
        }),
        _menuItem(Icons.add_alert, "Libur", () {}),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Bantuan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _menuItem(Icons.help, "Tanya Jawab", () {
          // TODO: Navigasi ke tanya jawab
        }),
        _menuItem(Icons.support, "Hubungi Support", () {
          // TODO: Navigasi ke hubungi support
        }),
        const Divider(),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
