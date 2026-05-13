import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/emergency_controller.dart';
import 'package:vanguard/components/shared/step_progress_indicator.dart';
import 'package:vanguard/components/shared/counter_widget.dart';
import 'package:vanguard/components/shared/hazard_checkbox.dart';
import 'package:vanguard/components/shared/incident_type_grid.dart';
import 'package:vanguard/components/shared/form_field.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class EmergencyStepper extends GetView<EmergencyController> {
  const EmergencyStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        StepProgressIndicator(
          currentStep: controller.currentStep.value,
          totalSteps: 5,
        ),
        
        // Content
        Expanded(
          child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: PageController(initialPage: controller.currentStep.value),
            onPageChanged: (index) => controller.currentStep.value = index,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildStepContent(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, int step) {
    switch (step) {
      case 0:
        return _buildIncidentTypeStep(context);
      case 1:
        return _buildPeopleInvolvedStep(context);
      case 2:
        return _buildInjuriesStep(context);
      case 3:
        return _buildHazardsStep(context);
      case 4:
        return _buildLocationStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIncidentTypeStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of emergency are you experiencing?',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'This helps us dispatch the right emergency services.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          IncidentTypeGrid(
            incidentTypes: controller.incidentTypes,
            selectedType: controller.incidentType.value,
            onTypeSelected: controller.setIncidentType,
          ),
          
          // Error message
          if (controller.incidentTypeError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
              child: Text(
                controller.incidentTypeError.value,
                style: TextStyle(
                  color: AppTheme.warningAmber,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeopleInvolvedStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many people are involved?',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          CounterWidget(
            value: controller.peopleInvolved.value,
            label: 'Total People',
            onIncrement: controller.incrementPeopleInvolved,
            onDecrement: controller.decrementPeopleInvolved,
          ),
          
          // Error message
          if (controller.peopleInvolvedError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
              child: Text(
                controller.peopleInvolvedError.value,
                style: TextStyle(
                  color: AppTheme.warningAmber,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInjuriesStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are there any injured people?',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          CounterWidget(
            value: controller.injuredCount.value,
            label: 'Injured People',
            onIncrement: controller.incrementInjured,
            onDecrement: controller.decrementInjured,
            valueColor: Colors.orange,
          ),
          
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          // Critical injured counter
          if (controller.injuredCount.value > 0)
            CounterWidget(
              value: controller.criticalInjured.value,
              label: 'Critical/Life-threatening',
              onIncrement: controller.incrementCritical,
              onDecrement: controller.decrementCritical,
              valueColor: Colors.red,
            ),
          
          // Error message
          if (controller.injuredCountError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
              child: Text(
                controller.injuredCountError.value,
                style: TextStyle(
                  color: AppTheme.warningAmber,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHazardsStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are there any immediate hazards?',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'Select all that apply',
            style: TextStyle(
              color: Colors.white70,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          // Hazard checkboxes
          Obx(() => Column(
            children: [
              HazardCheckbox(
                title: 'Fire or Explosion',
                icon: Icons.local_fire_department,
                isChecked: controller.hasFire.value,
                onTap: controller.toggleFire,
                color: Colors.orange,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              HazardCheckbox(
                title: 'Weapons or Violence',
                icon: Icons.security,
                isChecked: controller.hasWeapons.value,
                onTap: controller.toggleWeapons,
                color: Colors.red,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              HazardCheckbox(
                title: 'Building Collapse',
                icon: Icons.domain_disabled,
                isChecked: controller.hasStructuralCollapse.value,
                onTap: controller.toggleStructuralCollapse,
                color: Colors.grey,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              HazardCheckbox(
                title: 'Immediate Danger',
                icon: Icons.warning_rounded,
                isChecked: controller.immediateDanger.value,
                onTap: controller.toggleImmediateDanger,
                color: AppTheme.warningAmber,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provide location details',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'Describe your location to help responders find you quickly.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          // Location description field
          CustomFormField(
            label: '',
            hintText: 'e.g., "Near the main entrance of the shopping mall, next to the red car"',
            errorText: controller.locationDescriptionError.value,
            onChanged: (value) => controller.locationDescription.value = value,
            maxLines: 4,
          ),
          
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          
          // Emergency services
          Text(
            'Emergency services needed:',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          
          Obx(() => Wrap(
            spacing: MediaQuery.of(context).size.width * 0.02,
            runSpacing: MediaQuery.of(context).size.height * 0.01,
            children: controller.availableServices.map((service) {
              final isSelected = controller.emergencyServices.contains(service);
              return FilterChip(
                label: Text(
                  service,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.toggleEmergencyService(service),
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: AppTheme.sosCrimson,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
