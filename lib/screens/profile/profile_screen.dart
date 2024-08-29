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

  final List<String> genderOptions = ['Männlich', 'Weiblich'];
  final List<String> trainingExperienceOptions = [
    'Novice',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Very Advanced'
  ];

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

  Future<void> _updateProfile() async {
    if (userProfile != null) {
      await _dbHelper.updateProfile(userProfile!);
      print('Profile updated: $userProfile');
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geschlecht'),
          DropdownButton<String>(
            value: userProfile!.gender.isNotEmpty
                ? userProfile!.gender
                : genderOptions.first,
            items: genderOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  userProfile = userProfile!.copyWith(gender: newValue);
                  _updateProfile();
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Trainingslevel'),
          DropdownButton<String>(
            value: userProfile!.trainingExperience.isNotEmpty
                ? userProfile!.trainingExperience
                : trainingExperienceOptions.first,
            items: trainingExperienceOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  userProfile =
                      userProfile!.copyWith(trainingExperience: newValue);
                  _updateProfile();
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Körpergewicht (kg)'),
          Text(
            userProfile!.weight.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
