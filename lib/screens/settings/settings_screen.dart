import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _svgString = '';
  String _selectedGroup = 'Group 1'; // Default selected group

  final Map<String, List<String>> _groupedIds = {
    "Group 1": ['_x30_5', '_x33_1'],
    "Group 2": ['_x30_7', '_x33_3'],
    "Group 3": ['_x30_6', '_x33_2'],
  };

  // Map to store the slider value (color) for each group, initialized at 2 (middle position)
  Map<String, int> _sliderValues = {};

  @override
  void initState() {
    super.initState();
    _loadSvg();
    // Initialize slider values to 2 (middle position) for each group
    _sliderValues = {
      for (var group in _groupedIds.keys) group: 2,
    };
  }

  Future<void> _loadSvg() async {
    String svgString =
        await rootBundle.loadString('assets/female_frontside.svg');
    setState(() {
      _svgString = svgString;
    });
  }

  // Generate color based on the slider value
  Color _colorFromValue(int value) {
    switch (value) {
      case 0:
        return const Color.fromARGB(255, 0, 208, 255); // "Nicht trainieren"
      case 1:
        return const Color.fromARGB(255, 192, 242, 255); // "Vernachlässigen"
      case 2:
        return Colors.white; // "Normal"
      case 3:
        return const Color.fromARGB(255, 252, 121, 121); // "Etwas fokussieren"
      case 4:
        return const Color.fromARGB(255, 255, 3, 3); // "Fokussieren"
      default:
        return Colors.white; // Default to "Normal"
    }
  }

  // Update the SVG with the colors based on current slider values
  String _updateSvgColors(String svgString, Map<String, Color> colors) {
    for (var group in _groupedIds.values) {
      for (var id in group) {
        final color = colors[id]!;
        final hexColor = color.value
            .toRadixString(16)
            .substring(2); // Ignoring the alpha value

        final regex =
            RegExp(r'(<path[^>]*id="' + id + r'"[^>]*fill=")[^"]+(")');
        svgString = svgString.replaceFirst(regex,
            '${regex.firstMatch(svgString)?.group(1)}#$hexColor${regex.firstMatch(svgString)?.group(2)}');
      }
    }
    return svgString;
  }

  // Get text label based on slider value
  String _getLabelText(int value) {
    switch (value) {
      case 0:
        return "Nicht trainieren";
      case 1:
        return "Vernachlässigen";
      case 2:
        return "Normal";
      case 3:
        return "Etwas fokussieren";
      case 4:
        return "Fokussieren";
      default:
        return "Normal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_svgString.isNotEmpty)
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: Colors.white, // Initial color before animation
                end: _colorFromValue(_sliderValues[_selectedGroup]!),
              ),
              duration: Duration(milliseconds: 500),
              builder: (context, color, child) {
                Map<String, Color> currentColors = {
                  for (var group in _groupedIds.keys)
                    for (var id in _groupedIds[group]!)
                      id: group == _selectedGroup
                          ? color!
                          : _colorFromValue(_sliderValues[group]!)
                };
                return SvgPicture.string(
                  _updateSvgColors(_svgString, currentColors),
                  semanticsLabel: 'Female Frontside',
                  height: 560.0,
                );
              },
            ),
          DropdownButton<String>(
            value: _selectedGroup,
            onChanged: (String? newValue) {
              setState(() {
                _selectedGroup = newValue!;
              });
            },
            items:
                _groupedIds.keys.map<DropdownMenuItem<String>>((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
          ),
          Text(
            _getLabelText(_sliderValues[_selectedGroup]!),
            style: TextStyle(fontSize: 18),
          ),
          Slider(
            value: _sliderValues[_selectedGroup]!.toDouble(),
            min: 0,
            max: 4,
            divisions: 4, // 5 positions
            onChanged: (value) {
              setState(() {
                _sliderValues[_selectedGroup] = value.round();
              });
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsScreen(),
  ));
}
