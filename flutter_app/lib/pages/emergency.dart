import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<dynamic> emergencyResources = [];

  @override
  void initState() {
    super.initState();
    fetchEmergencyResources();
  }

  Future<void> fetchEmergencyResources() async {
    final response = await http.get(Uri.parse('${globals.api_base_url}/emergency'));

    if (response.statusCode == 200) {
      setState(() {
        emergencyResources = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load emergency resources');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      body: emergencyResources.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: emergencyResources.length,
        itemBuilder: (context, index) {
          final resource = emergencyResources[index];
          return Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                resource['name'],
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  resource['description'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.phone, color: Theme.of(context).colorScheme.secondary),
                onPressed: () => _launchPhone(resource['phone']),
              ),
            ),
          );
        },
      ),
    );
  }
}
