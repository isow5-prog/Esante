import 'package:flutter/material.dart';
import 'package:esante/models/notifs/notification_model.dart';
import 'package:esante/pages/detail_notification.dart';

class Notificationlue extends StatelessWidget {
  const Notificationlue({super.key});

  // Liste de notifications lues (exemple statique pour l’instant)
  final List<NotificationModel> _readNotifications = const [
    NotificationModel(
      id: '1',
      title: 'Carnet mis à jour',
      message: 'Le carnet de votre enfant a été mis à jour.',
      time: 'Aujourd\'hui • 10:24',
      isRead: true,
    ),
    NotificationModel(
      id: '2',
      title: 'Rappel de vaccination',
      message: 'La vaccination prévue hier a été confirmée.',
      time: 'Hier • 18:12',
      isRead: true,
    ),
    NotificationModel(
      id: '3',
      title: 'Nouveau message',
      message: 'Votre sage-femme a ajouté un commentaire.',
      time: '12 Nov • 14:05',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_readNotifications.isEmpty) {
      return const Center(
        child: Text(
          'Aucune notification lue',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _readNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _readNotifications[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
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