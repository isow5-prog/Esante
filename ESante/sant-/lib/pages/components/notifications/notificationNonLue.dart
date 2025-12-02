import 'package:flutter/material.dart';
import 'package:esante/models/notifs/notification_model.dart';
import 'package:esante/pages/detail_notification.dart';

class Notificationnonlue extends StatelessWidget {
  const Notificationnonlue({super.key});

  // Exemple de notifications non lues
  final List<NotificationModel> _unreadNotifications = const [
    NotificationModel(
      id: '4',
      title: 'Nouveau carnet disponible',
      message: 'Un nouveau carnet a été partagé avec vous.',
      time: 'Il y a 5 min',
      isRead: false,
    ),
    NotificationModel(
      id: '5',
      title: 'Rappel de rendez-vous',
      message: 'Vous avez un rendez-vous demain à 09:00.',
      time: 'Il y a 1 h',
      isRead: false,
    ),
    NotificationModel(
      id: '6',
      title: 'Mise à jour de profil',
      message: 'Vos informations de profil ont été validées.',
      time: 'Aujourd\'hui • 08:15',
      isRead: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_unreadNotifications.isEmpty) {
      return const Center(
        child: Text(
          'Aucune notification non lue',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _unreadNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _unreadNotifications[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0A7A33).withOpacity(0.1),
              child: const Icon(
                Icons.markunread,
                color: Color(0xFF0A7A33),
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailNotification(
                    notification: item,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}