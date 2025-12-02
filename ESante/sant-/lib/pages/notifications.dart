import 'package:esante/pages/components/notifications/notificationLue.dart';
import 'package:esante/pages/components/notifications/notificationNonLue.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text('Notifications',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.blueGrey,
          bottom: const TabBar(
            indicatorColor:
                Colors.white, // Couleur du trait sous l’onglet sélectionné
            labelColor: Colors.white, // Couleur du texte sélectionné
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Non lues'),
              Tab(text: 'Lues'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [Notificationnonlue(), Notificationlue()],
        ),
      ),
    );
  }
}
