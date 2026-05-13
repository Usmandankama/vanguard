import 'package:flutter/material.dart';

class HazardCheckbox extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isChecked;
  final VoidCallback onTap;
  final Color color;

  const HazardCheckbox({
    super.key,
    required this.title,
    required this.icon,
    required this.isChecked,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        decoration: BoxDecoration(
          color: isChecked ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isChecked ? color : Colors.white24,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isChecked ? color : Colors.white70,
              size: MediaQuery.of(context).size.width * 0.06,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isChecked ? color : Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.06,
              height: MediaQuery.of(context).size.width * 0.06,
              decoration: BoxDecoration(
                color: isChecked ? color : Colors.transparent,
                border: Border.all(
                  color: isChecked ? color : Colors.white24,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width * 0.04,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
