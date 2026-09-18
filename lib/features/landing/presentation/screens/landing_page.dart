import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../auth/presentation/screens/register_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.58;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: heroHeight > 460 ? heroHeight : 460,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/bookshelf.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.40, 0.70, 1.0],
                            colors: [
                              Color(0x156356FF),
                              Color(0x556356FF),
                              Color(0xB56356FF),
                              Color(0xFF6356FF),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        child: Text(
                          'Your next chapter\nstarts here',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover books, exchange with fellow\nstudents, and be part of a growing\nreading community',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF333045),
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const RegisterPage(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    final tween = Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(curve: Curves.easeOut));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 600),
                                ),
                              );
                            },
                            child: const Text(
                              'Get started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Color(0xFF1E1A34),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/images/github_logo.png',
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
