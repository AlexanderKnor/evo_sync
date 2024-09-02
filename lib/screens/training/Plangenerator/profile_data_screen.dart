import 'package:flutter/material.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';
import 'package:evosync/screens/training/Plangenerator/training_frequency_screen.dart';

class ProfileDataScreen extends StatefulWidget {
  @override
  _ProfileDataScreenState createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Profile? userProfile;
  final TextEditingController _weightController = TextEditingController();

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
        _weightController.text = userProfile?.weight.toStringAsFixed(1) ?? '';
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
      _saveProfile();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingFrequencyScreen(
            userProfile: userProfile!,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileForm(),
            SizedBox(
                height:
                    100), // Extra Platz, um zu verhindern, dass Inhalte den FAB überlappen
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 30.0, right: 16.0), // Erhöht den Abstand zum Bildschirmrand
        child: FloatingActionButton(
          onPressed: _navigateToNextScreen,
          backgroundColor: isDarkMode
              ? darkModePurple
              : theme.colorScheme.primary.withOpacity(0.8),
          child: const Icon(Icons.check, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      resizeToAvoidBottomInset:
          false, // Verhindert das Verschieben des FAB durch die Tastatur
    );
  }

  Widget _buildProfileForm() {
    if (userProfile == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildGenderSelection(),
        const SizedBox(height: 16),
        _buildExperienceSelection(),
        const SizedBox(height: 16),
        _buildWeightInput(),
      ],
    );
  }

  Widget _buildGenderSelection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: _buildBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getGenderIcon(),
                  color: isDarkMode ? Colors.white : Colors.black54),
              const SizedBox(width: 10),
              Text(
                'Geschlecht',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          DropdownButton<String>(
            value: userProfile?.gender,
            isExpanded: true,
            dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
            iconEnabledColor: isDarkMode ? Colors.white : Colors.black,
            onChanged: (String? newValue) {
              setState(() {
                userProfile = userProfile?.copyWith(gender: newValue);
              });
            },
            items: <String>['Männlich', 'Weiblich', 'Divers']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSelection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: _buildBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center,
                  color: isDarkMode ? Colors.white : Colors.black54),
              const SizedBox(width: 10),
              Text(
                'Erfahrung',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          DropdownButton<String>(
            value: userProfile?.trainingExperience,
            isExpanded: true,
            dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
            iconEnabledColor: isDarkMode ? Colors.white : Colors.black,
            onChanged: (String? newValue) {
              setState(() {
                userProfile =
                    userProfile?.copyWith(trainingExperience: newValue);
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
                child: Text(value,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: _buildBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight,
                  color: isDarkMode ? Colors.white : Colors.black54),
              const SizedBox(width: 10),
              Text(
                'Körpergewicht (kg)',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Geben Sie Ihr Gewicht ein',
              hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white38 : Colors.black38),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode ? Colors.white24 : Colors.black26),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.blueAccent
                        : theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              final double? weight = double.tryParse(value);
              if (weight != null) {
                setState(() {
                  userProfile = userProfile?.copyWith(weight: weight);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Adjust colors based on the theme brightness
    final startColor = isDarkMode
        ? Colors.deepPurpleAccent.withOpacity(0.1)
        : Colors.deepPurpleAccent.withOpacity(0.3);
    final endColor = isDarkMode
        ? Colors.deepPurpleAccent.withOpacity(0.4)
        : Colors.deepPurpleAccent.withOpacity(0.7);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    return BoxDecoration(
      gradient: LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8.0,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  IconData _getGenderIcon() {
    switch (userProfile?.gender) {
      case 'Männlich':
        return Icons.male;
      case 'Weiblich':
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }
}
