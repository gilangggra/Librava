import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class DepositPage extends StatelessWidget {
  final VoidCallback? onPaymentSuccess;
  final String? depositAmount;

  const DepositPage({
    super.key,
    this.onPaymentSuccess,
    this.depositAmount,
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
              child: DepositModalContent(
                depositAmount: depositAmount,
                onClose: () => Navigator.pop(context),
                onPaymentConfirmed: () {
                  onPaymentSuccess?.call();
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

class DepositModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onPaymentConfirmed;
  final String? depositAmount;

  const DepositModalContent({
    super.key,
    required this.onClose,
    required this.onPaymentConfirmed,
    this.depositAmount,
  });

  @override
  State<DepositModalContent> createState() => _DepositModalContentState();
}

class _BankOption {
  final String code;
  final String name;
  final String vaNumber;

  const _BankOption({
    required this.code,
    required this.name,
    required this.vaNumber,
  });
}

class _DepositModalContentState extends State<DepositModalContent> {
  static const List<_BankOption> _banks = [
    _BankOption(
      code: 'BCA',
      name: 'BCA Virtual Account',
      vaNumber: '8801 2345 6789 0123',
    ),
    _BankOption(
      code: 'Mandiri',
      name: 'Mandiri Virtual Account',
      vaNumber: '8902 4567 8901 2345',
    ),
    _BankOption(
      code: 'BNI',
      name: 'BNI Virtual Account',
      vaNumber: '9883 5678 9012 3456',
    ),
    _BankOption(
      code: 'BRI',
      name: 'BRI Virtual Account',
      vaNumber: '1284 6789 0123 4567',
    ),
  ];

  late _BankOption _selectedBank;

  @override
  void initState() {
    super.initState();
    _selectedBank = _banks[0];
  }

  String get _displayAmount {
    if (widget.depositAmount == null || widget.depositAmount!.trim().isEmpty) {
      return 'RP 50.000';
    }
    final trimmed = widget.depositAmount!.trim();
    if (trimmed.toUpperCase().startsWith('RP')) {
      return trimmed
          .toUpperCase()
          .replaceAll('RP.', 'RP ')
          .replaceAll('RP  ', 'RP ');
    }
    final rawNumber = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawNumber.isNotEmpty) {
      final parsed = int.tryParse(rawNumber) ?? 50000;
      final formatted = parsed.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return 'RP $formatted';
    }
    return trimmed;
  }

  Widget _buildBankLogo(String code, {double width = 26, double height = 18}) {
    final filename = code.toLowerCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SvgPicture.asset(
        'assets/images/bank/$filename.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) =>
            _buildFallbackLogo(code, width: width, height: height),
      ),
    );
  }

  Widget _buildFallbackLogo(String code, {double width = 26, double height = 18}) {
    switch (code.toUpperCase()) {
      case 'BCA':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF005BAC),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: const Center(
            child: Text(
              'BCA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      case 'MANDIRI':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF002855),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: const Center(
            child: Text(
              'mandiri',
              style: TextStyle(
                color: Color(0xFFF5A623),
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      case 'BNI':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF005E6A),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: const Center(
            child: Text(
              'BNI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      case 'BRI':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF00529C),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: const Center(
            child: Text(
              'BRI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      default:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: Center(
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
    }
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
              'Complete your deposit',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF130F26),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scan this QR code below to complete your deposit for this transaction',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757489),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 190,
                height: 190,
                color: Colors.white,
                padding: const EdgeInsets.all(18),
                child: Image.asset(
                  'assets/images/deposit_qr.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.qr_code_2_rounded,
                      size: 130,
                      color: Color(0xFF130F26),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF130F26).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deposit amount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757489),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0EFF8),
                    ),
                  ),
                  const Text(
                    'Virtual Account',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757489),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PopupMenuButton<_BankOption>(
                        initialValue: _selectedBank,
                        tooltip: 'Pilih Bank',
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: Colors.white,
                        onSelected: (val) {
                          setState(() {
                            _selectedBank = val;
                          });
                        },
                        itemBuilder: (context) {
                          return _banks.map((bank) {
                            final isSelected = bank.code == _selectedBank.code;
                            return PopupMenuItem<_BankOption>(
                              value: bank,
                              child: Row(
                                children: [
                                  _buildBankLogo(bank.code, width: 28, height: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      bank.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFF130F26),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2FD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBankLogo(_selectedBank.code, width: 25, height: 18),
                              const SizedBox(width: 5),
                              Text(
                                _selectedBank.code,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Color(0xFF757489),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedBank.vaNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: _selectedBank.vaNumber.replaceAll(' ', ''),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_selectedBank.code} VA number copied!',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEEFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'The deposit will be held securely and will be refunded after the book is returned',
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
                onPressed: widget.onPaymentConfirmed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "I've made the payment",
                  style: TextStyle(
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
