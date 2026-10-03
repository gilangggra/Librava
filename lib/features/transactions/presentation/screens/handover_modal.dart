import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SetHandoverPage extends StatelessWidget {
  final Function(String location)? onHandoverConfirmed;

  const SetHandoverPage({
    super.key,
    this.onHandoverConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: HandoverModalContent(
                onClose: () => Navigator.pop(context),
                onHandoverConfirmed: (loc) {
                  onHandoverConfirmed?.call(loc);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HandoverModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String location) onHandoverConfirmed;
  final String initialLocation;
  final String buttonText;

  const HandoverModalContent({
    super.key,
    required this.onClose,
    required this.onHandoverConfirmed,
    this.initialLocation = 'Open Library Telkom University',
    this.buttonText = "I've made the payment",
  });

  @override
  State<HandoverModalContent> createState() => _HandoverModalContentState();
}

class _HandoverModalContentState extends State<HandoverModalContent> {
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: 'Aug 23, 2026');
    _timeController = TextEditingController(text: '14:00 WIB');
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _dateController.dispose;
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF757489),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD2D2D6),
              width: 1.1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            onTap: onTap,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130F26),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0ACC4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEFF),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 26,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Set handover',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF130F26),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose the date, time, and location for the book handover',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757489),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Date',
              controller: _dateController,
              hintText: 'e.g. Aug 23, 2026',
            ),
            const SizedBox(height: 14),
            _buildInputField(
              label: 'Time',
              controller: _timeController,
              hintText: 'e.g. 14:00 WIB',
            ),
            const SizedBox(height: 14),
            _buildInputField(
              label: 'Location',
              controller: _locationController,
              hintText: 'e.g. Open Library Telkom University',
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Please make sure the details are correct. You and the book owner will meet at the selected location on the choosen date and time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5A5671),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final loc = _locationController.text.trim().isNotEmpty
                      ? _locationController.text.trim()
                      : widget.initialLocation;
                  widget.onHandoverConfirmed(loc);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
