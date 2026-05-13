import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/emergency_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

/// VanguardNet — Emergency Enrichment Screen
///
/// Architecture: SOS fires BEFORE this screen opens.
/// This screen enriches the already-broadcast alert via WebSocket patches.
/// All fields are optional — "Skip" always available.
class EmergencyQuestionnaireScreen extends GetView<EmergencyController> {
  const EmergencyQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Obx(() => controller.isEmergencyConfirmed.value
          ? _ConfirmationScreen(sw: sw, sh: sh)
          : _EnrichmentBody(
              controller: controller,
              sw: sw,
              sh: sh,
              top: top,
            )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN ENRICHMENT BODY
// ─────────────────────────────────────────────────────────────────────────────
class _EnrichmentBody extends StatelessWidget {
  final EmergencyController controller;
  final double sw, sh, top;

  const _EnrichmentBody({
    required this.controller,
    required this.sw,
    required this.sh,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        SizedBox(height: top + 12),
        _TopBar(sw: sw),

        // SOS Confirmed Banner
        SizedBox(height: sh * 0.018),
        _SOSSentBanner(sw: sw),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05, vertical: sh * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'TYPE OF EMERGENCY', sw: sw),
                SizedBox(height: sh * 0.012),
                _IncidentTypeGrid(controller: controller, sw: sw),

                SizedBox(height: sh * 0.028),
                _SectionLabel(label: 'PEOPLE INVOLVED', sw: sw),
                SizedBox(height: sh * 0.012),
                _PeopleCounters(controller: controller, sw: sw),

                SizedBox(height: sh * 0.028),
                _SectionLabel(label: 'IMMEDIATE HAZARDS', sw: sw),
                SizedBox(height: sh * 0.012),
                _HazardRow(controller: controller, sw: sw),

                SizedBox(height: sh * 0.028),
                _SectionLabel(label: 'LOCATION NOTE  (OPTIONAL)', sw: sw),
                SizedBox(height: sh * 0.012),
                _LocationNote(controller: controller, sw: sw),

                SizedBox(height: sh * 0.04),
              ],
            ),
          ),
        ),

        // Bottom CTA
        _BottomActions(controller: controller, sw: sw, sh: sh),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double sw;
  const _TopBar({required this.sw});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            'ENRICH ALERT',
            style: TextStyle(
              color: Colors.white38,
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36), // balance
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOS SENT BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _SOSSentBanner extends StatelessWidget {
  final double sw;
  const _SOSSentBanner({required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.045, vertical: sw * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A0A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3A1A)),
      ),
      child: Row(
        children: [
          _PulseDot(),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS BROADCAST ACTIVE',
                  style: TextStyle(
                    color: const Color(0xFF4ADE80),
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Responders nearby have been notified. '
                  'Add details below to help them prepare.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: sw * 0.03,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 1.0, end: 0.2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4ADE80),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final double sw;
  const _SectionLabel({required this.label, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white24,
        fontSize: sw * 0.026,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INCIDENT TYPE GRID — 2 columns, 6 types
// ─────────────────────────────────────────────────────────────────────────────
class _IncidentTypeGrid extends StatelessWidget {
  final EmergencyController controller;
  final double sw;
  const _IncidentTypeGrid(
      {required this.controller, required this.sw});

  static const _types = [
    {'label': 'Medical', 'icon': Icons.medical_services_rounded},
    {'label': 'Accident', 'icon': Icons.car_crash_rounded},
    {'label': 'Fire', 'icon': Icons.local_fire_department_rounded},
    {'label': 'Violence', 'icon': Icons.shield_rounded},
    {'label': 'Disaster', 'icon': Icons.cyclone_rounded},
    {'label': 'Other', 'icon': Icons.warning_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.15,
            crossAxisSpacing: sw * 0.03,
            mainAxisSpacing: sw * 0.03,
          ),
          itemCount: _types.length,
          itemBuilder: (_, i) {
            final t = _types[i];
            final label = t['label'] as String;
            final icon = t['icon'] as IconData;

            return Obx(() {
              final selected = controller.incidentType.value == label;
              return GestureDetector(
                onTap: () => controller.setIncidentType(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.sosCrimson.withOpacity(0.12)
                        : const Color(0xFF0E0E0E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppTheme.sosCrimson.withOpacity(0.6)
                          : Colors.white.withOpacity(0.07),
                      width: selected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: selected
                            ? AppTheme.sosCrimson
                            : Colors.white38,
                        size: sw * 0.065,
                      ),
                      SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white38,
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PEOPLE COUNTERS — total + injured on two rows, injured clamped to total
// ─────────────────────────────────────────────────────────────────────────────
class _PeopleCounters extends StatelessWidget {
  final EmergencyController controller;
  final double sw;
  const _PeopleCounters({required this.controller, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Obx(() => _CounterRow(
              label: 'Total people',
              value: controller.peopleInvolved.value,
              valueColor: Colors.white,
              onDecrement: controller.decrementPeopleInvolved,
              onIncrement: controller.incrementPeopleInvolved,
              sw: sw,
            )),
            SizedBox(height: sw * 0.025),
            Obx(() => _CounterRow(
              label: 'Injured',
              value: controller.injuredCount.value,
              valueColor: controller.injuredCount.value > 0
                  ? AppTheme.sosCrimson
                  : Colors.white38,
              onDecrement: controller.decrementInjured,
              onIncrement: controller.incrementInjured,
              sw: sw,
              sublabel: controller.criticalInjured.value > 0
                  ? '${controller.criticalInjured.value} critical'
                  : null,
            )),
          ],
        );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final double sw;
  final String? sublabel;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.onDecrement,
    required this.onIncrement,
    required this.sw,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.045, vertical: sw * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Colors.white54, fontSize: sw * 0.034),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(
                      color: AppTheme.sosCrimson.withOpacity(0.8),
                      fontSize: sw * 0.028),
                ),
            ],
          ),
          const Spacer(),
          _CounterBtn(icon: Icons.remove, onTap: onDecrement, sw: sw),
          SizedBox(width: sw * 0.05),
          Text(
            '$value',
            style: TextStyle(
              color: valueColor,
              fontSize: sw * 0.06,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: sw * 0.05),
          _CounterBtn(icon: Icons.add, onTap: onIncrement, sw: sw),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double sw;
  const _CounterBtn(
      {required this.icon, required this.onTap, required this.sw});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sw * 0.08,
        height: sw * 0.08,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white54, size: sw * 0.04),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HAZARD ROW — 4 pills
// ─────────────────────────────────────────────────────────────────────────────
class _HazardRow extends StatelessWidget {
  final EmergencyController controller;
  final double sw;
  const _HazardRow({required this.controller, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Obx(() => _HazardPill(
              label: 'Fire',
              icon: Icons.local_fire_department_rounded,
              active: controller.hasFire.value,
              activeColor: Colors.orange,
              onTap: controller.toggleFire,
              sw: sw,
            )),
            SizedBox(width: sw * 0.025),
            Obx(() => _HazardPill(
              label: 'Weapons',
              icon: Icons.security_rounded,
              active: controller.hasWeapons.value,
              activeColor: AppTheme.sosCrimson,
              onTap: controller.toggleWeapons,
              sw: sw,
            )),
            SizedBox(width: sw * 0.025),
            Obx(() => _HazardPill(
              label: 'Collapse',
              icon: Icons.domain_disabled_rounded,
              active: controller.hasStructuralCollapse.value,
              activeColor: Colors.blueGrey,
              onTap: controller.toggleStructuralCollapse,
              sw: sw,
            )),
            SizedBox(width: sw * 0.025),
            Obx(() => _HazardPill(
              label: 'Danger',
              icon: Icons.warning_amber_rounded,
              active: controller.immediateDanger.value,
              activeColor: AppTheme.warningAmber,
              onTap: controller.toggleImmediateDanger,
              sw: sw,
            )),
          ],
        );
  }
}

class _HazardPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final double sw;

  const _HazardPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(vertical: sw * 0.03),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withOpacity(0.12)
                : const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? activeColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: active ? activeColor : Colors.white24,
                  size: sw * 0.055),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? activeColor : Colors.white24,
                  fontSize: sw * 0.026,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION NOTE — optional free-text, GPS already captured
// ─────────────────────────────────────────────────────────────────────────────
class _LocationNote extends StatelessWidget {
  final EmergencyController controller;
  final double sw;
  const _LocationNote({required this.controller, required this.sw});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (v) => controller.locationDescription.value = v,
      maxLines: 3,
      style: TextStyle(color: Colors.white70, fontSize: sw * 0.036),
      decoration: InputDecoration(
        hintText:
            'e.g. "Near the main gate, red car blocking road"',
        hintStyle:
            TextStyle(color: Colors.white24, fontSize: sw * 0.034),
        filled: true,
        fillColor: const Color(0xFF0E0E0E),
        contentPadding: EdgeInsets.all(sw * 0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppTheme.sosCrimson.withOpacity(0.5)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM ACTIONS
// ─────────────────────────────────────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  final EmergencyController controller;
  final double sw, sh;
  const _BottomActions(
      {required this.controller, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          sw * 0.05, sh * 0.018, sw * 0.05, bottom + sh * 0.018),
      decoration: BoxDecoration(
        color: AppTheme.oledBlack,
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          // Skip
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    'Skip',
                    style: TextStyle(
                        color: Colors.white38, fontSize: sw * 0.038),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          // Push update
          Expanded(
            flex: 2,
            child: Obx(() => GestureDetector(
                  onTap: controller.isSubmitting.value
                      ? null
                      : controller.submitEmergency,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 52,
                    decoration: BoxDecoration(
                      color: controller.isSubmitting.value
                          ? AppTheme.sosCrimson.withOpacity(0.5)
                          : AppTheme.sosCrimson,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Push update →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sw * 0.038,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMATION SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmationScreen extends StatelessWidget {
  final double sw, sh;
  const _ConfirmationScreen({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sw * 0.22,
              height: sw * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secureGreen.withOpacity(0.1),
                border: Border.all(
                    color: AppTheme.secureGreen.withOpacity(0.3),
                    width: 1.5),
              ),
              child: Icon(Icons.check_rounded,
                  color: AppTheme.secureGreen, size: sw * 0.1),
            ),
            SizedBox(height: sh * 0.04),
            Text(
              'Responders updated',
              style: TextStyle(
                color: Colors.white,
                fontSize: sw * 0.06,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: sh * 0.015),
            Text(
              'Your details have been pushed to all nearby responders. Stay safe and remain visible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: sw * 0.038,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}