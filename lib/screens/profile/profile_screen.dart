import 'package:flutter/material.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Profile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    List<Profile> profiles = await _dbHelper.getProfiles();
    if (profiles.isNotEmpty) {
      setState(() {
        userProfile = profiles.first;
        print('Loaded Profile: $userProfile');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    final String gender =
        userProfile!.gender.isNotEmpty ? userProfile!.gender : 'Männlich';
    final String trainingExperience = userProfile!.trainingExperience.isNotEmpty
        ? userProfile!.trainingExperience
        : 'Novice';
    final double weight = userProfile!.weight;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geschlecht'),
          Text(
            gender,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text('Trainingslevel'),
          Text(
            trainingExperience,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text('Körpergewicht (kg)'),
          Text(
            weight.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
