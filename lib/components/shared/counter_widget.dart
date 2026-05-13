import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color? valueColor;
  final double? iconSize;
  final double? fontSize;

  const CounterWidget({
    super.key,
    required this.value,
    required this.label,
    required this.onIncrement,
    required this.onDecrement,
    this.valueColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: fontSize ?? MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: iconSize ?? MediaQuery.of(context).size.width * 0.08,
                color: Colors.white70,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.06),
              Text(
                '$value',
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: fontSize ?? MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.06),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: iconSize ?? MediaQuery.of(context).size.width * 0.08,
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
