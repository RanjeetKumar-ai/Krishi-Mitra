library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/crop_model.dart';

class PhasePreparationPage extends StatefulWidget {
  final CropModel crop;

  const PhasePreparationPage({super.key, required this.crop});

  @override
  State<PhasePreparationPage> createState() => _PhasePreparationPageState();
}

class _PhasePreparationPageState extends State<PhasePreparationPage> {
  String _currentLanguage = 'EN'; // EN or HI
  bool _isSpeaking = false;
  final Set<int> _checkedTasks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Phase Preparation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Language Selector - FIXED with highlighted state
          _buildLanguageSelector(),

          const SizedBox(width: 8),

          // Voice button
          IconButton(
            icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop' : 'Listen',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _toggleVoice();
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with crop info
            _buildHeader(),

            const SizedBox(height: 20),

            // Next Phase Card
            _buildNextPhaseCard(),

            const SizedBox(height: 20),

            // Preparation Checklist
            _buildPreparationChecklist(),

            const SizedBox(height: 20),

            // Fertilizer Guidance
            _buildFertilizerGuidance(),

            const SizedBox(height: 16),

            // Water Management
            _buildWaterManagement(),

            const SizedBox(height: 16),

            // Pest Prevention
            _buildPestPrevention(),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== LANGUAGE SELECTOR (FIXED HIGHLIGHTING) ====================
  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showLanguageSheet();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _currentLanguage == 'HI'
              ? const Color(0xFF2E7D32).withValues(alpha: (0.15))
              : const Color(0xFF2E7D32).withValues(alpha: (0.1)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _currentLanguage == 'HI'
                ? const Color(0xFF2E7D32)
                : const Color(0xFF2E7D32).withValues(alpha: (0.3)),
            width: _currentLanguage == 'HI' ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.language,
              size: 16,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(width: 4),
            Text(
              _currentLanguage,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.crop.iconEmoji,
            style: const TextStyle(fontSize: 70),
          ),
          const SizedBox(height: 12),
          Text(
            widget.crop.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: (0.25)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Current: ${widget.crop.phaseText}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NEXT PHASE CARD ====================
  Widget _buildNextPhaseCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF42A5F5).withValues(alpha: (0.3)),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: (0.25)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Phase',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPhaseText(widget.crop.nextPhase!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: (0.2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Expected in ${widget.crop.daysToNextPhase} days',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PREPARATION CHECKLIST ====================
  Widget _buildPreparationChecklist() {
    final tasks = _getPreparationTasks(widget.crop.nextPhase!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: (0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.04)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.checklist,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'What to Prepare',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(tasks.length, (index) {
              return _buildChecklistItem(tasks[index], index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String task, int index) {
    final isChecked = _checkedTasks.contains(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (isChecked) {
              _checkedTasks.remove(index);
            } else {
              _checkedTasks.add(index);
            }
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF2E7D32) : Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  task,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isChecked ? Colors.grey[600] : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FERTILIZER GUIDANCE ====================
  Widget _buildFertilizerGuidance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: (0.4)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF66BB6A).withValues(alpha: (0.1)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Color(0xFF66BB6A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Fertilizer & Nutrients',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withValues(alpha: (0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPK Requirements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getFertilizerGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WATER MANAGEMENT ====================
  Widget _buildWaterManagement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF42A5F5).withValues(alpha: (0.4)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF42A5F5).withValues(alpha: (0.1)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Color(0xFF42A5F5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Water Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withValues(alpha: (0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Irrigation Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getWaterGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PEST PREVENTION ====================
  Widget _buildPestPrevention() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: (0.4)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA726).withValues(alpha: (0.1)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Color(0xFFFFA726),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pest Prevention',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withValues(alpha: (0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preventive Measures',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getPestGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.bookmark),
              label: const Text(
                'Save Preparation Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _savePlan();
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
              label: const Text(
                'Set Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _setReminder();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LANGUAGE SHEET ====================
  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageTile(
                'English', 'Default voice', 'EN', _currentLanguage == 'EN'),
            const SizedBox(height: 12),
            _buildLanguageTile(
                'हिन्दी', 'Hindi voice', 'HI', _currentLanguage == 'HI'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
      String title, String subtitle, String code, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentLanguage = code;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7D32).withValues(alpha: (0.1))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          selected ? const Color(0xFF2E7D32) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================
  void _savePlan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparation plan saved successfully'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setReminder() {
    final daysUntilReminder = (widget.crop.daysToNextPhase ?? 0) - 5;
    final reminderDays = daysUntilReminder > 0 ? daysUntilReminder : 1;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for $reminderDays days from now'),
        backgroundColor: const Color(0xFF42A5F5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleVoice() {
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
    // TODO: Integrate TtsService
    if (_isSpeaking) {
      print('Speaking phase preparation in $_currentLanguage...');
    } else {
      print('Stopped speaking');
    }
  }

  // ==================== HELPERS ====================
  String _getPhaseText(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Seedling';
      case CropPhase.vegetative:
        return 'Vegetative';
      case CropPhase.flowering:
        return 'Flowering';
      case CropPhase.fruiting:
        return 'Fruiting';
      case CropPhase.maturation:
        return 'Maturation';
      case CropPhase.harvest:
        return 'Harvest';
    }
  }

  List<String> _getPreparationTasks(CropPhase phase) {
    switch (phase) {
      case CropPhase.flowering:
        return [
          'Arrange phosphorus-rich fertilizers',
          'Check irrigation system',
          'Set up pest traps',
          'Prepare for increased watering',
          'Stock organic fungicides',
        ];
      default:
        return [
          'Prepare necessary inputs',
          'Check field conditions',
          'Plan irrigation schedule',
        ];
    }
  }

  String _getFertilizerGuidance(CropPhase phase) {
    return 'Apply NPK 10:52:10 @ 2kg per acre during early flowering stage. '
        'Supplement with micronutrients (Zinc, Boron) for better flower development.';
  }

  String _getWaterGuidance(CropPhase phase) {
    return 'Increase irrigation frequency to once every 3 days. '
        'Maintain soil moisture at 70-80%. Use drip irrigation for better results.';
  }

  String _getPestGuidance(CropPhase phase) {
    return 'Apply neem oil spray weekly as preventive measure. '
        'Monitor for aphids and thrips. Install yellow sticky traps.';
  }
}
