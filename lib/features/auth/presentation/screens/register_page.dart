import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prosesDaftarAkun() async {
    if (_formKey.currentState?.validate() ?? true) {
      final namaUser = _namaController.text.trim();
      final emailUser = _emailController.text.trim();
      final passwordUser = _passwordController.text;

      final berhasil = await context.read<AuthProvider>().daftar(
            nama: namaUser.isEmpty ? 'Pengguna' : namaUser,
            email: emailUser,
            password: passwordUser,
          );

      if (berhasil && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akun untuk ${namaUser.isEmpty ? 'Pengguna' : namaUser} berhasil dibuat!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                const Text(
                  'Continue with email',
                  style: TextStyle(
                    color: AppColors.textPurple,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Name',
                  controller: _namaController,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 48),

                Center(
                  child: CustomButton(
                    text: 'Create account',
                    width: 250,
                    height: 58,
                    fontSize: 22,
                    isLoading: authProvider.isLoading,
                    onPressed: _prosesDaftarAkun,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
