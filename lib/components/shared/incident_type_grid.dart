import 'package:flutter/material.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class IncidentTypeGrid extends StatelessWidget {
  final List<String> incidentTypes;
  final String selectedType;
  final Function(String) onTypeSelected;

  const IncidentTypeGrid({
    super.key,
    required this.incidentTypes,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
        mainAxisSpacing: MediaQuery.of(context).size.height * 0.02,
      ),
      itemCount: incidentTypes.length,
      itemBuilder: (context, index) {
        final type = incidentTypes[index];
        final isSelected = selectedType == type;
        
        return GestureDetector(
          onTap: () => onTypeSelected(type),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.sosCrimson.withOpacity(0.2) : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppTheme.sosCrimson : Colors.white24,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIncidentIcon(type),
                  color: isSelected ? AppTheme.sosCrimson : Colors.white70,
                  size: MediaQuery.of(context).size.width * 0.08,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppTheme.sosCrimson : Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIncidentIcon(String type) {
    switch (type) {
      case 'Medical Emergency':
        return Icons.medical_services;
      case 'Traffic Accident':
        return Icons.car_crash;
      case 'Fire':
        return Icons.local_fire_department;
      case 'Violence/Assault':
        return Icons.security;
      case 'Natural Disaster':
        return Icons.cyclone;
      case 'Structural Collapse':
        return Icons.domain_disabled;
      case 'Chemical Spill':
        return Icons.science;
      default:
        return Icons.emergency;
    }
  }
}
