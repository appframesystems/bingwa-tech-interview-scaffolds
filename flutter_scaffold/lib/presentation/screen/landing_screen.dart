import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  bool _scrolled = false;
  bool _mobileMenuOpen = false;
  int _taskCount = 10000;
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startCounterAnimation();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_scrolled) {
      setState(() => _scrolled = true);
    } else if (_scrollController.offset <= 50 && _scrolled) {
      setState(() => _scrolled = false);
    }
  }

  void _startCounterAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _taskCount += 500;
        });
        _startCounterAnimation();
      }
    });
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    final authController = Get.find<AuthController>();
    if (route == AppRoutes.home && authController.isAuthenticated.value) {
      Get.offAllNamed(AppRoutes.home);
    } else if (route == AppRoutes.register) {
      Get.offAllNamed(AppRoutes.register);
    } else if (route == AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4f46e5);
    final primaryDark = const Color(0xFF4338ca);
    final bgColor = Colors.white;
    final textColor = const Color(0xFF1a1a2e);
    final grayText = const Color(0xFF6b7280);
    final lightBg = const Color(0xFFf8fafc);
    final borderColor = const Color(0xFFe5e7eb);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Navbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _scrolled
                    ? Colors.white.withOpacity(0.95)
                    : Colors.white.withOpacity(0.9),
                border: Border(
                  bottom: BorderSide(
                    color: borderColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                boxShadow: _scrolled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist_rtl, color: primaryColor, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'TaskFlow',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (!_mobileMenuOpen) ...[
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _scrollToSection(_featuresKey),
                          child: Text('Features', style: TextStyle(color: grayText)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _scrollToSection(_howItWorksKey),
                          child: Text('How It Works', style: TextStyle(color: grayText)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _scrollToSection(_testimonialsKey),
                          child: Text('Testimonials', style: TextStyle(color: grayText)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _navigateTo(AppRoutes.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Get Started'),
                        ),
                      ],
                    ),
                  ],
                  IconButton(
                    onPressed: () {
                      setState(() => _mobileMenuOpen = !_mobileMenuOpen);
                    },
                    icon: Icon(
                      _mobileMenuOpen ? Icons.close : Icons.menu,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_mobileMenuOpen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMobileNavItem('Features', () => _scrollToSection(_featuresKey)),
                    _buildMobileNavItem('How It Works', () => _scrollToSection(_howItWorksKey)),
                    _buildMobileNavItem('Testimonials', () => _scrollToSection(_testimonialsKey)),
                    const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateTo(AppRoutes.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Get Started'),
                        ),
                      ),
                  ],
                ),
              ),
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFf8fafc),
                    const Color(0xFFeef2ff),
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      children: [
                        Expanded(child: _buildHeroContent(primaryColor, textColor, grayText)),
                        const SizedBox(width: 40),
                        Expanded(child: _buildHeroMockup(primaryColor, borderColor)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildHeroContent(primaryColor, textColor, grayText),
                      const SizedBox(height: 40),
                      _buildHeroMockup(primaryColor, borderColor),
                    ],
                  );
                },
              ),
            ),
            // Features Section
            KeyedSubtree(
              key: _featuresKey,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              color: bgColor,
              child: Column(
                children: [
                  const Text(
                    'Why Choose TaskFlow?',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Everything you need to manage your tasks efficiently and stay productive',
                    style: TextStyle(fontSize: 16, color: grayText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900
                          ? 3
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.9,
                        children: [
                          _buildFeatureCard(Icons.flash_on, 'Lightning Fast',
                              'Built with performance in mind. Your tasks load instantly with real-time updates.', primaryColor),
                          _buildFeatureCard(Icons.security, 'Secure & Private',
                              'Your data is encrypted and secure. JWT authentication ensures only you access your tasks.', primaryColor),
                          _buildFeatureCard(Icons.sync, 'Cross-Platform',
                              'Access your tasks anywhere. Web, mobile, or desktop - your tasks sync in real-time.', primaryColor),
                          _buildFeatureCard(Icons.show_chart, 'Smart Analytics',
                              'Track your productivity with detailed statistics and insights about your task completion.', primaryColor),
                          _buildFeatureCard(Icons.people, 'Team Collaboration',
                              'Share tasks, assign priorities, and collaborate seamlessly with your team members.', primaryColor),
                          _buildFeatureCard(Icons.phone_android, 'Mobile Ready',
                              'Beautiful responsive design that works perfectly on any device - phone, tablet, or desktop.', primaryColor),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ),
            // How It Works
            KeyedSubtree(
              key: _howItWorksKey,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              color: lightBg,
              child: Column(
                children: [
                  const Text(
                    'How TaskFlow Works',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get started in minutes with these simple steps',
                    style: TextStyle(fontSize: 16, color: grayText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStep('1', 'Create Account',
                              'Sign up for free with your email and get started immediately.', primaryColor),
                          _buildStep('2', 'Add Tasks',
                              'Create tasks with titles, descriptions, priorities, and due dates.', primaryColor),
                          _buildStep('3', 'Track Progress',
                              'Mark tasks complete, track your progress, and stay productive.', primaryColor),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ),
            // Testimonials
            KeyedSubtree(
              key: _testimonialsKey,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              color: bgColor,
              child: Column(
                children: [
                  const Text(
                    'What Our Users Say',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Real feedback from real people who love TaskFlow',
                    style: TextStyle(fontSize: 16, color: grayText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900
                          ? 3
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                        children: [
                          _buildTestimonialCard('JD', 'John Doe', 'Software Engineer', primaryColor),
                          _buildTestimonialCard('JS', 'Jane Smith', 'Product Manager', primaryColor),
                          _buildTestimonialCard('MW', 'Mike Wilson', 'Freelance Designer', primaryColor),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ),
            // CTA Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF7c3aed)],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Ready to Get Started?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join thousands of users who are already managing their tasks efficiently with TaskFlow.',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateTo(AppRoutes.register),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Start Free Trial',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No credit card required. Free forever for individual use.',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              color: const Color(0xFF1a1a2e),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildFooterBrand(primaryColor)),
                          Expanded(child: _buildFooterLinks('Product', ['Features', 'Pricing', 'Integrations', 'Roadmap'])),
                          Expanded(child: _buildFooterLinks('Company', ['About', 'Blog', 'Careers', 'Contact'])),
                          Expanded(child: _buildFooterLinks('Support', ['Help Center', 'Documentation', 'Community', 'Status'])),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Divider(color: const Color(0xFF374151)),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 TaskFlow. Built with ❤️ by Your Team',
                    style: TextStyle(color: const Color(0xFF9ca3af), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroContent(Color primaryColor, Color textColor, Color grayText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organize Your',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: textColor,
            height: 1.1,
          ),
        ),
        Text(
          'Tasks Effortlessly',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            height: 1.1,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [primaryColor, const Color(0xFF7c3aed)],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'TaskFlow helps you manage your tasks, boost productivity, and achieve your goals. Simple, beautiful, and built for teams of any size.',
          style: TextStyle(fontSize: 16, color: grayText, height: 1.6),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _navigateTo(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
              child: const Text('Get Started Free', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: const BorderSide(color: Color(0xFFe5e7eb)),
              ),
              child: const Text('See Features', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: const Color(0xFFe5e7eb), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_taskCount.toString()}+',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1a1a2e)),
                    ),
                    Text('Tasks Managed', style: TextStyle(fontSize: 13, color: grayText)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('98%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1a1a2e))),
                    Text('Satisfaction Rate', style: TextStyle(fontSize: 13, color: Color(0xFF6b7280))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('4.9★', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1a1a2e))),
                    Text('User Rating', style: TextStyle(fontSize: 13, color: Color(0xFF6b7280))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroMockup(Color primaryColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 80,
            offset: const Offset(0, 30),
          ),
        ],
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist_rtl, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: const [
                  CircleAvatar(radius: 6, backgroundColor: Color(0xFFef4444)),
                  SizedBox(width: 6),
                  CircleAvatar(radius: 6, backgroundColor: Color(0xFFf59e0b)),
                  SizedBox(width: 6),
                  CircleAvatar(radius: 6, backgroundColor: Color(0xFF10b981)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMockupTask('Design Dashboard UI', 'Complete design system for web app', true, 'High', primaryColor, Colors.red),
          _buildMockupTask('Build API Integration', 'Connect to NestJS backend', false, 'Medium', primaryColor, Colors.orange),
          _buildMockupTask('Write Documentation', 'API docs and user guide', false, 'Low', primaryColor, Colors.green),
          _buildMockupTask('Deploy to Production', 'Setup CI/CD pipeline', true, 'High', primaryColor, Colors.red),
        ],
      ),
    );
  }

  Widget _buildMockupTask(String title, String subtitle, bool completed, String badge, Color primary, Color badgeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf9fafb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: completed ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFd1d5db)),
            ),
            child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFf1f3f5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFeef2ff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF6b7280), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String desc, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          desc,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6b7280), height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(String initials, String name, String role, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFf1f3f5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star, color: Color(0xFFf59e0b), size: 16),
              Icon(Icons.star, color: Color(0xFFf59e0b), size: 16),
              Icon(Icons.star, color: Color(0xFFf59e0b), size: 16),
              Icon(Icons.star, color: Color(0xFFf59e0b), size: 16),
              Icon(Icons.star, color: Color(0xFFf59e0b), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"TaskFlow has completely transformed how I manage my projects. It\'s intuitive, fast, and beautiful!"',
            style: const TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.6, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(role, style: const TextStyle(fontSize: 13, color: Color(0xFF6b7280))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist_rtl, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'TaskFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Smart task management for modern teams. Stay organized, stay productive.',
          style: TextStyle(color: const Color(0xFF9ca3af), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(link, style: const TextStyle(color: Color(0xFF9ca3af))),
            )),
      ],
    );
  }

  Widget _buildMobileNavItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
