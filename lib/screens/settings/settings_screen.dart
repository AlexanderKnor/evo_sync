import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Profile? userProfile;
  Map<String, dynamic>? groupedIds;
  late final Map<String, List<String>> _frontsideGroupedIds;
  late final Map<String, List<String>> _backsideGroupedIds;
  late final Map<String, int> _frontsideSliderValues;
  late final Map<String, int> _backsideSliderValues;
  Map<String, int> _currentSliderValues = {};
  String _svgFrontsideString = '';
  String _svgBacksideString = '';
  bool _isSwapped = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndGroupedIds();
  }

  Future<void> _loadProfileAndGroupedIds() async {
    try {
      final results = await Future.wait([
        _dbHelper.getProfiles(),
        rootBundle.loadString('assets/database/body_svg_ids.json')
      ]);
      final profiles = results[0] as List<Profile>;
      if (profiles.isNotEmpty) {
        userProfile = profiles.first;
        groupedIds = json.decode(results[1] as String);
        await _initializeSettings();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _initializeSettings() async {
    if (groupedIds == null || userProfile == null) return;

    final gender =
        userProfile!.gender.toLowerCase() == 'weiblich' ? 'female' : 'male';
    _frontsideGroupedIds =
        _convertToMapOfStringLists(groupedIds![gender]['frontside']);
    _backsideGroupedIds =
        _convertToMapOfStringLists(groupedIds![gender]['backside']);

    try {
      final svgResults = await Future.wait([
        rootBundle.loadString('assets/images/${gender}_frontside.svg'),
        rootBundle.loadString('assets/images/${gender}_backside.svg')
      ]);
      _svgFrontsideString = svgResults[0];
      _svgBacksideString = svgResults[1];
    } catch (e) {
      print('Error loading SVGs: $e');
    }

    _initializeSliderValues();
    setState(() => _isLoading = false);
  }

  Map<String, List<String>> _convertToMapOfStringLists(
      Map<String, dynamic> map) {
    return map
        .map((key, value) => MapEntry(key, List<String>.from(value as List)));
  }

  void _initializeSliderValues() {
    _frontsideSliderValues = {
      for (var group in _frontsideGroupedIds.keys) group: 2
    };
    _backsideSliderValues = {
      for (var group in _backsideGroupedIds.keys) group: 2
    };
    _currentSliderValues = _frontsideSliderValues;
  }

  void _swapSvgs() {
    setState(() {
      _isSwapped = !_isSwapped;
      _currentSliderValues =
          _isSwapped ? _backsideSliderValues : _frontsideSliderValues;
    });
  }

  Color _colorFromValue(int value) {
    const colors = [
      Color.fromARGB(255, 128, 128, 128),
      Color.fromARGB(255, 189, 189, 189),
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 222, 253, 255),
      Color.fromARGB(255, 190, 251, 255),
    ];
    return colors[value.clamp(0, colors.length - 1)];
  }

  String _updateSvgColors(
      String svgString, Map<String, List<String>> groupedIds) {
    final colorMap = {
      for (var group in _currentSliderValues.keys)
        if (groupedIds.containsKey(group))
          for (var id in groupedIds[group]!)
            id: _colorFromValue(_currentSliderValues[group]!)
    };

    colorMap.forEach((id, color) {
      final hexColor = color.value.toRadixString(16).substring(2);
      final regex = RegExp('(<path[^>]*id="$id"[^>]*fill=")[^"]+(")');
      svgString = svgString.replaceFirst(
        regex,
        '${regex.firstMatch(svgString)?.group(1)}#$hexColor${regex.firstMatch(svgString)?.group(2)}',
      );
    });

    return svgString;
  }

  String _getLabelText(int value) {
    const labels = [
      "Nicht trainieren",
      "Vernachlässigen",
      "Normal",
      "Etwas fokussieren",
      "Fokussieren"
    ];
    return labels[value.clamp(0, labels.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: SvgPicture.string(
                  _updateSvgColors(
                    _isSwapped ? _svgBacksideString : _svgFrontsideString,
                    _isSwapped ? _backsideGroupedIds : _frontsideGroupedIds,
                  ),
                  semanticsLabel: 'Frontside or Backside',
                  height: 560.0,
                ),
              ),
              Expanded(
                child: ListView(
                  children: _currentSliderValues.keys.map((group) {
                    return Column(
                      children: [
                        Text(
                          group,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getLabelText(_currentSliderValues[group]!),
                          style: const TextStyle(fontSize: 18),
                        ),
                        Slider(
                          value: _currentSliderValues[group]!.toDouble(),
                          min: 0,
                          max: 4,
                          divisions: 4,
                          onChanged: (value) {
                            setState(() =>
                                _currentSliderValues[group] = value.round());
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Positioned(
            top: 60,
            right: 20,
            child: GestureDetector(
              onTap: _swapSvgs,
              child: SvgPicture.string(
                _updateSvgColors(
                  _isSwapped ? _svgFrontsideString : _svgBacksideString,
                  _isSwapped ? _frontsideGroupedIds : _backsideGroupedIds,
                ),
                semanticsLabel: 'Frontside or Backside',
                width: 100.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsScreen(),
  ));
}
