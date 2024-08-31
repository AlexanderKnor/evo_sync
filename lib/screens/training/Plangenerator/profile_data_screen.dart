import 'package:flutter/material.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';
import 'package:evosync/screens/training/Plangenerator/training_frequency_screen.dart'; // Importiere die nächste Seite

class ProfileDataScreen extends StatefulWidget {
  @override
  _ProfileDataScreenState createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
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
      });
    }
  }

  Future<void> _saveProfile() async {
    if (userProfile != null) {
      if (userProfile!.id == null) {
        await _dbHelper.insertProfile(userProfile!);
      } else {
        await _dbHelper.updateProfile(userProfile!);
      }
    }
  }

  void _navigateToNextScreen() {
    if (userProfile != null) {
      _saveProfile(); // Speichern der aktuellen Profiländerungen

      // Navigation zur nächsten Seite
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingFrequencyScreen(
            userProfile: userProfile!, // Übergabe des Profils
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define the dark purple color for dark mode
    final Color darkModePurple = Colors.deepPurpleAccent.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profildaten'),
      ),
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileForm(),
      // Floating Action Button with padding and specific dark mode color
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0, right: 10.0), // Padding to avoid screen edges
        child: FloatingActionButton(
          onPressed: _navigateToNextScreen,
          backgroundColor: isDarkMode
              ? darkModePurple
              : theme.colorScheme
                  .primary, // Dark purple in dark mode, primary in light mode
          child: const Icon(Icons.check,
              color: Colors.white), // White icon color for visibility
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geschlecht'),
          DropdownButton<String>(
            value: userProfile!.gender,
            onChanged: (String? newValue) {
              setState(() {
                userProfile = userProfile!.copyWith(gender: newValue!);
              });
            },
            items: <String>['Männlich', 'Weiblich', 'Divers']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Wie lange trainierst du schon?'),
          DropdownButton<String>(
            value: userProfile!.trainingExperience,
            onChanged: (String? newValue) {
              setState(() {
                userProfile =
                    userProfile!.copyWith(trainingExperience: newValue!);
              });
            },
            items: <String>[
              'Novice',
              'Beginner',
              'Intermediate',
              'Advanced',
              'Very Advanced',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Körpergewicht (kg)'),
          Slider(
            value: userProfile!.weight,
            min: 30.0,
            max: 150.0,
            divisions: 240,
            label: userProfile!.weight.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                userProfile = userProfile!.copyWith(weight: value);
              });
            },
          ),
        ],
      ),
    );
  }
}
