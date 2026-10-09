import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const SmartInterestX());
}

// ============================================================
// SMARTINTERESTX
// Loan & Interest Management Application
// ============================================================

class SmartInterestX extends StatelessWidget {
  const SmartInterestX({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartInterestX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF2563EB),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

enum ContactType { borrower, lender }

enum TransactionType { given, taken }

enum PaymentMode { upi, bankTransfer, cash, other }

class Contact {
  final int id;
  String name;
  String mobile;
  String email;
  ContactType type;

  Contact({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.type,
  });
}

class LoanTransaction {
  final int id;
  final int contactId;
  double amount;
  TransactionType type;
  double interestRate;
  DateTime startDate;
  DateTime dueDate;
  String notes;
  double paidAmount;

  LoanTransaction({
    required this.id,
    required this.contactId,
    required this.amount,
    required this.type,
    required this.interestRate,
    required this.startDate,
    required this.dueDate,
    required this.notes,
    this.paidAmount = 0,
  });

  double get remainingAmount {
    final total = amount + interestTillDueDate;
    final remaining = total - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  double interestForDays(int days) {
    if (days <= 0) return 0;
    return amount * interestRate * (days / 365) / 100;
  }

  double get interestTillToday {
    final today = DateTime.now();
    final difference = today.difference(startDate).inDays;
    return interestForDays(difference);
  }

  double get interestTillDueDate {
    final difference = dueDate.difference(startDate).inDays;
    return interestForDays(difference);
  }

  double get totalDue {
    return amount + interestTillDueDate;
  }

  double get paymentProgress {
    if (totalDue <= 0) return 0;
    final value = paidAmount / totalDue;
    return value.clamp(0.0, 1.0);
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && remainingAmount > 0;
  }
}

class Payment {
  final int id;
  final int transactionId;
  final DateTime date;
  final double amount;
  final PaymentMode mode;

  Payment({
    required this.id,
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.mode,
  });
}

// ============================================================
// APP DATA
// ============================================================

class AppData {
  static int _contactId = 3;
  static int _transactionId = 3;
  static int _paymentId = 2;

  static final List<Contact> contacts = [
    Contact(
      id: 1,
      name: 'Rahul Sharma',
      mobile: '9876543210',
      email: 'rahul@example.com',
      type: ContactType.borrower,
    ),
    Contact(
      id: 2,
      name: 'Akash Kumar',
      mobile: '9123456780',
      email: 'akash@example.com',
      type: ContactType.lender,
    ),
    Contact(
      id: 3,
      name: 'Priya Singh',
      mobile: '9988776655',
      email: 'priya@example.com',
      type: ContactType.borrower,
    ),
  ];

  static final List<LoanTransaction> transactions = [
    LoanTransaction(
      id: 1,
      contactId: 1,
      amount: 10000,
      type: TransactionType.given,
      interestRate: 12,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      notes: 'Personal loan',
      paidAmount: 2000,
    ),
    LoanTransaction(
      id: 2,
      contactId: 2,
      amount: 20000,
      type: TransactionType.taken,
      interestRate: 10,
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      dueDate: DateTime.now().add(const Duration(days: 60)),
      notes: 'Business requirement',
      paidAmount: 5000,
    ),
    LoanTransaction(
      id: 3,
      contactId: 3,
      amount: 15000,
      type: TransactionType.given,
      interestRate: 8,
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().add(const Duration(days: 70)),
      notes: 'Emergency loan',
      paidAmount: 0,
    ),
  ];

  static final List<Payment> payments = [
    Payment(
      id: 1,
      transactionId: 1,
      date: DateTime.now().subtract(const Duration(days: 10)),
      amount: 1000,
      mode: PaymentMode.upi,
    ),
    Payment(
      id: 2,
      transactionId: 1,
      date: DateTime.now().subtract(const Duration(days: 2)),
      amount: 1000,
      mode: PaymentMode.cash,
    ),
  ];

  static int nextContactId() => ++_contactId;
  static int nextTransactionId() => ++_transactionId;
  static int nextPaymentId() => ++_paymentId;
}

// ============================================================
// UTILITIES
// ============================================================

String money(double value) {
  return '₹${value.toStringAsFixed(2)}';
}

String dateText(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String shortDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]}';
}

String contactTypeText(ContactType type) {
  return type == ContactType.borrower ? 'Borrower' : 'Lender';
}

String transactionTypeText(TransactionType type) {
  return type == TransactionType.given ? 'Given' : 'Taken';
}

String paymentModeText(PaymentMode mode) {
  switch (mode) {
    case PaymentMode.upi:
      return 'UPI';
    case PaymentMode.bankTransfer:
      return 'Bank Transfer';
    case PaymentMode.cash:
      return 'Cash';
    case PaymentMode.other:
      return 'Other';
  }
}

Contact? getContact(int id) {
  for (final contact in AppData.contacts) {
    if (contact.id == id) return contact;
  }
  return null;
}

LoanTransaction? getTransaction(int id) {
  for (final transaction in AppData.transactions) {
    if (transaction.id == id) return transaction;
  }
  return null;
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 55,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'SmartInterestX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loan & Interest Manager',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 45),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int page = 0;

  final List<Map<String, dynamic>> slides = [
    {
      'icon': Icons.people_alt_rounded,
      'title': 'Manage Your Contacts',
      'description':
          'Keep borrowers and lenders organized in one simple place.',
    },
    {
      'icon': Icons.calculate_rounded,
      'title': 'Calculate Interest',
      'description':
          'Calculate simple interest automatically based on amount, rate and time.',
    },
    {
      'icon': Icons.payments_rounded,
      'title': 'Track Payments',
      'description':
          'Record payments and monitor your remaining balance and progress.',
    },
  ];

  void finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (value) {
                  setState(() => page = value);
                },
                itemBuilder: (context, index) {
                  final item = slides[index];

                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'],
                            size: 85,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          item['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          item['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: page == index ? 25 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: page == index
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: () {
                    if (page == slides.length - 1) {
                      finish();
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    page == slides.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onRefresh: refresh),
      ContactsScreen(onRefresh: refresh),
      TransactionsScreen(onRefresh: refresh),
      NotificationsScreen(onRefresh: refresh),
      SettingsScreen(onRefresh: refresh),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() => currentIndex = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const DashboardScreen({
    super.key,
    required this.onRefresh,
  });

  double get totalGiven {
    return AppData.transactions
        .where((t) => t.type == TransactionType.given)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalTaken {
    return AppData.transactions
        .where((t) => t.type == TransactionType.taken)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get interestEarned {
    return AppData.transactions
        .where((t) => t.type == TransactionType.given)
        .fold(0, (sum, t) => sum + t.interestTillToday);
  }

  double get interestPaid {
    return AppData.transactions
        .where((t) => t.type == TransactionType.taken)
        .fold(0, (sum, t) => sum + t.interestTillToday);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final hour = today.hour;

    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SmartInterestX',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Main balance card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Receivables',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(totalGiven),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniWhiteStat(
                          title: 'Given',
                          value: money(totalGiven),
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      Expanded(
                        child: _MiniWhiteStat(
                          title: 'Taken',
                          value: money(totalTaken),
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Interest Earned',
                    value: money(interestEarned),
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Interest Paid',
                    value: money(interestPaid),
                    icon: Icons.trending_down_rounded,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Contacts',
                    value: '${AppData.contacts.length}',
                    icon: Icons.people_alt_rounded,
                    iconColor: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Active Loans',
                    value: '${AppData.transactions.length}',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const SectionTitle(
              title: 'Given vs Taken',
              subtitle: 'Current transaction distribution',
            ),

            const SizedBox(height: 15),

            _GivenTakenChart(
              given: totalGiven,
              taken: totalTaken,
            ),

            const SizedBox(height: 25),

            const SectionTitle(
              title: 'Recent Transactions',
              subtitle: 'Latest loan activity',
            ),

            const SizedBox(height: 10),

            ...AppData.transactions
                .take(3)
                .map(
                  (transaction) => TransactionTile(
                    transaction: transaction,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailScreen(
                            transactionId: transaction.id,
                            onChanged: onRefresh,
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MiniWhiteStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniWhiteStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GivenTakenChart extends StatelessWidget {
  final double given;
  final double taken;

  const _GivenTakenChart({
    required this.given,
    required this.taken,
  });

  @override
  Widget build(BuildContext context) {
    final total = given + taken;
    final givenPercentage = total == 0 ? 0.5 : given / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 125,
            height: 125,
            child: CustomPaint(
              painter: DonutPainter(
                givenPercentage: givenPercentage,
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              children: [
                LegendRow(
                  color: const Color(0xFF2563EB),
                  title: 'Money Given',
                  value: money(given),
                ),
                const SizedBox(height: 18),
                LegendRow(
                  color: const Color(0xFFF59E0B),
                  title: 'Money Taken',
                  value: money(taken),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  final double givenPercentage;

  DonutPainter({
    required this.givenPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFF59E0B);

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final givenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2563EB);

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      2 * math.pi * givenPercentage,
      false,
      givenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.givenPercentage != givenPercentage;
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const LegendRow({
    super.key,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CONTACTS
// ============================================================

class ContactsScreen extends StatefulWidget {
  final VoidCallback onRefresh;

  const ContactsScreen({
    super.key,
    required this.onRefresh,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = AppData.contacts.where((contact) {
      final query = search.toLowerCase();

      return contact.name.toLowerCase().contains(query) ||
          contact.mobile.contains(query) ||
          contactTypeText(contact.type).toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Contacts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddContactScreen(
                      onSaved: () {
                        setState(() {});
                        widget.onRefresh();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddContactScreen(
                  onSaved: () {
                    setState(() {});
                    widget.onRefresh();
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Contact'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 100),
          children: [
            TextField(
              onChanged: (value) {
                setState(() => search = value);
              },
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${filtered.length} Contacts',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.people_outline,
                title: 'No contacts found',
                subtitle: 'Add a borrower or lender to get started.',
              ),
            ...filtered.map(
              (contact) => ContactTile(
                contact: contact,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactDetailScreen(
                        contactId: contact.id,
                        onChanged: () {
                          setState(() {});
                          widget.onRefresh();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBorrower = contact.type == ContactType.borrower;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isBorrower
              ? const Color(0xFFE8F0FF)
              : const Color(0xFFFFF3DC),
          child: Text(
            contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBorrower
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFD97706),
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(contact.mobile),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isBorrower
                ? const Color(0xFFE8F0FF)
                : const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            contactTypeText(contact.type),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isBorrower
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFD97706),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADD CONTACT
// ============================================================

class AddContactScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const AddContactScreen({
    super.key,
    required this.onSaved,
  });

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  ContactType type = ContactType.borrower;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void save() {
    if (nameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter name and mobile number.'),
        ),
      );
      return;
    }

    AppData.contacts.add(
      Contact(
        id: AppData.nextContactId(),
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
        type: type,
      ),
    );

    widget.onSaved();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact saved successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormLabel(text: 'Full Name'),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 18),
          const FormLabel(text: 'Mobile Number'),
          TextField(
            controller: mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Enter mobile number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 18),
          const FormLabel(text: 'Email'),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 18),
          const FormLabel(text: 'Contact Type'),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SegmentedButton<ContactType>(
              segments: const [
                ButtonSegment(
                  value: ContactType.borrower,
                  label: Text('Borrower'),
                  icon: Icon(Icons.person_rounded),
                ),
                ButtonSegment(
                  value: ContactType.lender,
                  label: Text('Lender'),
                  icon: Icon(Icons.account_balance_rounded),
                ),
              ],
              selected: {type},
              onSelectionChanged: (selection) {
                setState(() => type = selection.first);
              },
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'SAVE CONTACT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONTACT DETAILS
// ============================================================

class ContactDetailScreen extends StatelessWidget {
  final int contactId;
  final VoidCallback onChanged;

  const ContactDetailScreen({
    super.key,
    required this.contactId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final contact = getContact(contactId);

    if (contact == null) {
      return const Scaffold(
        body: Center(
          child: Text('Contact not found'),
        ),
      );
    }

    final loans = AppData.transactions
        .where((transaction) => transaction.contactId == contactId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFE8F0FF),
              child: Text(
                contact.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              contact.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                contactTypeText(contact.type),
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          InfoCard(
            children: [
              InfoRow(
                icon: Icons.phone,
                title: 'Mobile',
                value: contact.mobile,
              ),
              if (contact.email.isNotEmpty)
                InfoRow(
                  icon: Icons.email,
                  title: 'Email',
                  value: contact.email,
                ),
            ],
          ),
          const SizedBox(height: 25),
          const SectionTitle(
            title: 'Transactions',
            subtitle: 'Loans connected to this contact',
          ),
          const SizedBox(height: 10),
          if (loans.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions',
              subtitle: 'Create a transaction for this contact.',
            ),
          ...loans.map(
            (transaction) => TransactionTile(
              transaction: transaction,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(
                      transactionId: transaction.id,
                      onChanged: onChanged,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TRANSACTIONS SCREEN
// ============================================================

class TransactionsScreen extends StatefulWidget {
  final VoidCallback onRefresh;

  const TransactionsScreen({
    super.key,
    required this.onRefresh,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? filter;

  @override
  Widget build(BuildContext context) {
    List<LoanTransaction> transactions = AppData.transactions;

    if (filter != null) {
      transactions = transactions
          .where((t) => t.type == filter)
          .toList();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Loans & Transactions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(
                  onSaved: () {
                    setState(() {});
                    widget.onRefresh();
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Loan'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: filter == null,
                    onSelected: (_) {
                      setState(() => filter = null);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Given'),
                    selected: filter == TransactionType.given,
                    onSelected: (_) {
                      setState(
                        () => filter = TransactionType.given,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Taken'),
                    selected: filter == TransactionType.taken,
                    onSelected: (_) {
                      setState(
                        () => filter = TransactionType.taken,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (transactions.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions',
                subtitle: 'Add your first loan transaction.',
              ),
            ...transactions.map(
              (transaction) => TransactionTile(
                transaction: transaction,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(
                        transactionId: transaction.id,
                        onChanged: () {
                          setState(() {});
                          widget.onRefresh();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADD TRANSACTION
// ============================================================

class AddTransactionScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const AddTransactionScreen({
    super.key,
    required this.onSaved,
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final interestController = TextEditingController(text: '12');
  final notesController = TextEditingController();

  int? contactId;
  TransactionType type = TransactionType.given;

  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(
    const Duration(days: 30),
  );

  @override
  void initState() {
    super.initState();

    if (AppData.contacts.isNotEmpty) {
      contactId = AppData.contacts.first.id;
    }

    amountController.addListener(refresh);
    interestController.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    amountController.dispose();
    interestController.dispose();
    notesController.dispose();
    super.dispose();
  }

  double get amount {
    return double.tryParse(amountController.text) ?? 0;
  }

  double get rate {
    return double.tryParse(interestController.text) ?? 0;
  }

  int get days {
    return dueDate.difference(startDate).inDays;
  }

  double get estimatedInterest {
    return amount * rate * (days / 365) / 100;
  }

  double get total {
    return amount + estimatedInterest;
  }

  Future<void> chooseStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        if (dueDate.isBefore(startDate)) {
          dueDate = startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> chooseDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  void save() {
    if (contactId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact.'),
        ),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      return;
    }

    AppData.transactions.add(
      LoanTransaction(
        id: AppData.nextTransactionId(),
        contactId: contactId!,
        amount: amount,
        type: type,
        interestRate: rate,
        startDate: startDate,
        dueDate: dueDate,
        notes: notesController.text.trim(),
      ),
    );

    widget.onSaved();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction saved successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FormLabel(text: 'Contact'),
          DropdownButtonFormField<int>(
            value: contactId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: AppData.contacts.map((contact) {
              return DropdownMenuItem<int>(
                value: contact.id,
                child: Text(contact.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => contactId = value);
            },
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Transaction Type'),
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.given,
                label: Text('Given'),
                icon: Icon(Icons.arrow_upward_rounded),
              ),
              ButtonSegment(
                value: TransactionType.taken,
                label: Text('Taken'),
                icon: Icon(Icons.arrow_downward_rounded),
              ),
            ],
            selected: {type},
            onSelectionChanged: (selection) {
              setState(() => type = selection.first);
            },
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Amount'),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee),
              hintText: 'Enter amount',
            ),
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Annual Interest Rate'),
          TextField(
            controller: interestController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.percent_rounded),
              suffixText: '% / year',
            ),
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Start Date'),
          DateSelector(
            date: startDate,
            onTap: chooseStartDate,
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Due Date'),
          DateSelector(
            date: dueDate,
            onTap: chooseDueDate,
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Notes'),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add notes...',
            ),
          ),
          const SizedBox(height: 25),

          // LIVE INTEREST PREVIEW
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
              ),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.calculate_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Interest Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CalculationRow(
                  title: 'Principal',
                  value: money(amount),
                ),
                CalculationRow(
                  title: 'Rate',
                  value: '${rate.toStringAsFixed(2)}%',
                ),
                CalculationRow(
                  title: 'Duration',
                  value: '$days days',
                ),
                const Divider(height: 25),
                CalculationRow(
                  title: 'Interest Till Due Date',
                  value: money(estimatedInterest),
                  bold: true,
                ),
                CalculationRow(
                  title: 'Total Payable',
                  value: money(total),
                  bold: true,
                  large: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'SAVE TRANSACTION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TRANSACTION TILE
// ============================================================

class TransactionTile extends StatelessWidget {
  final LoanTransaction transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contact = getContact(transaction.contactId);
    final isGiven = transaction.type == TransactionType.given;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isGiven
                          ? const Color(0xFFE8F0FF)
                          : const Color(0xFFFFF3DC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isGiven
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isGiven
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact?.name ?? 'Unknown Contact',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transactionTypeText(transaction.type)} • ${transaction.interestRate}% interest',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    money(transaction.amount),
                    style: TextStyle(
                      color: isGiven
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due: ${dateText(transaction.dueDate)}',
                      style: TextStyle(
                        color: transaction.isOverdue
                            ? Colors.red
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'Paid ${money(transaction.paidAmount)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: transaction.paymentProgress,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TRANSACTION DETAILS
// ============================================================

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;
  final VoidCallback onChanged;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.onChanged,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends State<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final transaction = getTransaction(widget.transactionId);

    if (transaction == null) {
      return const Scaffold(
        body: Center(
          child: Text('Transaction not found'),
        ),
      );
    }

    final contact = getContact(transaction.contactId);

    final transactionPayments = AppData.payments
        .where((p) => p.transactionId == transaction.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: transaction.type == TransactionType.given
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFD97706),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Text(
                  contact?.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  money(transaction.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  transactionTypeText(transaction.type),
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          InfoCard(
            children: [
              InfoRow(
                icon: Icons.percent_rounded,
                title: 'Interest Rate',
                value: '${transaction.interestRate}% per year',
              ),
              InfoRow(
                icon: Icons.calendar_today_rounded,
                title: 'Start Date',
                value: dateText(transaction.startDate),
              ),
              InfoRow(
                icon: Icons.event_available_rounded,
                title: 'Due Date',
                value: dateText(transaction.dueDate),
              ),
              InfoRow(
                icon: Icons.notes_rounded,
                title: 'Notes',
                value: transaction.notes.isEmpty
                    ? 'No notes'
                    : transaction.notes,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Interest Calculation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                CalculationRow(
                  title: 'Principal',
                  value: money(transaction.amount),
                ),
                CalculationRow(
                  title: 'Interest till today',
                  value: money(transaction.interestTillToday),
                ),
                CalculationRow(
                  title: 'Interest till due date',
                  value: money(transaction.interestTillDueDate),
                ),
                const Divider(height: 25),
                CalculationRow(
                  title: 'Total Payable',
                  value: money(transaction.totalDue),
                  bold: true,
                  large: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Payment Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(transaction.paymentProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: transaction.paymentProgress,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Paid: ${money(transaction.paidAmount)}',
                      ),
                    ),
                    Text(
                      'Remaining: ${money(transaction.remainingAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordPaymentScreen(
                      transaction: transaction,
                      onSaved: () {
                        setState(() {});
                        widget.onChanged();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.payments_rounded),
              label: const Text(
                'RECORD PAYMENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const SectionTitle(
            title: 'Payment History',
            subtitle: 'Recorded payments',
          ),

          const SizedBox(height: 10),

          if (transactionPayments.isEmpty)
            const EmptyState(
              icon: Icons.payments_outlined,
              title: 'No payments',
              subtitle: 'No payment has been recorded yet.',
            ),

          ...transactionPayments.reversed.map(
            (payment) => Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE8F0FF),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
                title: Text(
                  money(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${paymentModeText(payment.mode)} • ${dateText(payment.date)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECORD PAYMENT
// ============================================================

class RecordPaymentScreen extends StatefulWidget {
  final LoanTransaction transaction;
  final VoidCallback onSaved;

  const RecordPaymentScreen({
    super.key,
    required this.transaction,
    required this.onSaved,
  });

  @override
  State<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState
    extends State<RecordPaymentScreen> {
  final amountController = TextEditingController();
  PaymentMode mode = PaymentMode.upi;
  DateTime paymentDate = DateTime.now();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => paymentDate = picked);
    }
  }

  void save() {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid payment amount.'),
        ),
      );
      return;
    }

    if (amount > widget.transaction.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment cannot be greater than the remaining amount.',
          ),
        ),
      );
      return;
    }

    widget.transaction.paidAmount += amount;

    AppData.payments.add(
      Payment(
        id: AppData.nextPaymentId(),
        transactionId: widget.transaction.id,
        date: paymentDate,
        amount: amount,
        mode: mode,
      ),
    );

    widget.onSaved();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment recorded successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Record Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Remaining Amount',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  money(widget.transaction.remainingAmount),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const FormLabel(text: 'Payment Amount'),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee),
              hintText: 'Enter payment amount',
            ),
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Payment Date'),
          DateSelector(
            date: paymentDate,
            onTap: chooseDate,
          ),
          const SizedBox(height: 20),
          const FormLabel(text: 'Payment Mode'),
          DropdownButtonFormField<PaymentMode>(
            value: mode,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            items: PaymentMode.values.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(paymentModeText(item)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => mode = value);
              }
            },
          ),
          const SizedBox(height: 25),

          // Payment proof UI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 45,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Payment Proof',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Receipt upload can be connected to Firebase Storage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Proof upload UI ready. Firebase Storage can be connected.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload Proof'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'SAVE PAYMENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const NotificationsScreen({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = AppData.transactions
        .where((transaction) => transaction.isOverdue)
        .toList();

    final upcoming = AppData.transactions.where((transaction) {
      final days = transaction.dueDate
          .difference(DateTime.now())
          .inDays;

      return days >= 0 && days <= 7;
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (overdue.isNotEmpty) ...[
              const SectionTitle(
                title: 'Overdue',
                subtitle: 'Transactions that need attention',
              ),
              const SizedBox(height: 10),
              ...overdue.map(
                (transaction) => NotificationCard(
                  icon: Icons.warning_rounded,
                  title: 'Payment overdue',
                  description:
                      '${getContact(transaction.contactId)?.name ?? 'Contact'} has an overdue payment.',
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
            ],
            const SectionTitle(
              title: 'Upcoming Due Dates',
              subtitle: 'Next 7 days',
            ),
            const SizedBox(height: 10),
            if (upcoming.isEmpty)
              const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No upcoming reminders',
                subtitle: 'You have no payments due in the next 7 days.',
              ),
            ...upcoming.map(
              (transaction) {
                final days = transaction.dueDate
                    .difference(DateTime.now())
                    .inDays;

                return NotificationCard(
                  icon: Icons.event_available_rounded,
                  title: 'Payment due soon',
                  description:
                      '${getContact(transaction.contactId)?.name ?? 'Contact'} is due in $days day(s).',
                  color: const Color(0xFF2563EB),
                );
              },
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    size: 50,
                    color: Color(0xFF2563EB),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Reminder Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SmartInterestX can remind you before loan due dates.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('1 Day')),
                      Chip(label: Text('3 Days')),
                      Chip(label: Text('7 Days')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const SettingsScreen({
    super.key,
    required this.onRefresh,
  });

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE8F0FF),
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2563EB),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartInterestX User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Loan & Interest Manager',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SettingsSection(
              title: 'Data Management',
              children: [
                SettingsTile(
                  icon: Icons.file_download_rounded,
                  title: 'Export Transactions',
                  subtitle: 'Export your transaction records',
                  onTap: () {
                    showMessage(
                      context,
                      'CSV export screen is ready to connect.',
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.cloud_upload_rounded,
                  title: 'Backup to Cloud',
                  subtitle: 'Backup data using Firebase',
                  onTap: () {
                    showMessage(
                      context,
                      'Firebase backup can be connected here.',
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.restore_rounded,
                  title: 'Restore Data',
                  subtitle: 'Restore previously backed up data',
                  onTap: () {
                    showMessage(
                      context,
                      'Restore functionality is ready for Firebase integration.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            SettingsSection(
              title: 'Notifications',
              children: [
                SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Reminder Settings',
                  subtitle: '1 day, 3 days and 7 days',
                  onTap: () {
                    showMessage(
                      context,
                      'Reminder settings opened.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            SettingsSection(
              title: 'Application',
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About SmartInterestX',
                  subtitle: 'Loan & Interest Management',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'SmartInterestX',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.account_balance_wallet_rounded,
                      ),
                      children: const [
                        Text(
                          'SmartInterestX is a loan and interest management application built using Flutter.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const DateSelector({
    super.key,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 12),
            Text(
              dateText(date),
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
            ),
          ],
        ),
      ),
    );
  }
}

class CalculationRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;
  final bool large;

  const CalculationRow({
    super.key,
    required this.title,
    required this.value,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: large
                  ? const Color(0xFF2563EB)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(35),
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.settings_rounded,
          color: Color(0xFF2563EB),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
    );
  }
}