import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNumberInputScreen extends StatefulWidget {
  final String initialValue;
  final String title;
  final String suffix;
  final double step;
  final double minValue;
  final double maxValue;
  final Function(String) onValueChanged;

  const CustomNumberInputScreen({
    Key? key,
    required this.initialValue,
    required this.title,
    required this.suffix,
    this.step = 0.1,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomNumberInputScreenState createState() =>
      _CustomNumberInputScreenState();
}

class _CustomNumberInputScreenState extends State<CustomNumberInputScreen> {
  late int _selectedIndex;
  late List<String> _numberOptions;
  late TextEditingController _controller;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _numberOptions = List.generate(
      ((widget.maxValue - widget.minValue) / widget.step).round() + 1,
      (index) {
        final value = widget.minValue + index * widget.step;
        return value == value.roundToDouble()
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
      },
    );

    _selectedIndex = _numberOptions.indexOf(widget.initialValue);
    _controller = TextEditingController(text: widget.initialValue);
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedIndex);

    _controller.addListener(() {
      final text = _controller.text;
      final index = _numberOptions.indexOf(text);
      if (index != -1 && index != _selectedIndex) {
        setState(() {
          _selectedIndex = index;
          if (_scrollController.selectedItem != _selectedIndex) {
            _scrollController.jumpToItem(_selectedIndex);
          }
        });
      }
    });
  }

  void _onConfirm() {
    widget.onValueChanged(_numberOptions[_selectedIndex]);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor = isDarkMode ? Colors.blueAccent : Colors.blue;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor:
          backgroundColor, // Dunklerer Hintergrund nur im Dark Mode
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode ? Colors.white54 : Colors.black26,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: widget.suffix,
                    suffixStyle: TextStyle(
                      color: textColor,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: CupertinoPicker(
                scrollController: _scrollController,
                itemExtent: 80.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                    _controller.text = _numberOptions[index];
                  });
                },
                selectionOverlay: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                children: _numberOptions.map((number) {
                  return Center(
                    child: Text(
                      '$number ${widget.suffix}',
                      style: TextStyle(
                        fontSize: 26,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onConfirm,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Bestätigen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
