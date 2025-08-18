import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/course_provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth_screen.dart';
import '../homescreen_widgets/featured_courses.dart';
import '../homescreen_widgets/categories_widgets.dart';
import '../screens/user_dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<CourseProvider>().fetchCourses();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<CategoryProvider>().fetchCategories(forceRefresh: true),
      context.read<CourseProvider>().fetchCourses(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final userProvider = context.watch<UserProvider>();

    if (categoryProvider.isLoading && courseProvider.courses.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (categoryProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("E-Learning")),
        body: Center(child: Text(categoryProvider.errorMessage)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(userProvider),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (!userProvider.isAuthenticated) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 16));
                }
                final username = userProvider.userData?['username'] ?? 'User';
                return _buildWelcomeHeader(username);
              },
            ),
            _buildSectionHeader("Categories"),
            SliverToBoxAdapter(
              child: CategoriesSection(provider: categoryProvider),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16), // Spacing between sections
            ),
            _buildSectionHeader("Featured Courses"),
            SliverToBoxAdapter(
              child: FeaturedCourses(courseProvider: courseProvider),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16), // Bottom padding
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(UserProvider userProvider) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      title: const Text(
        "E-Learning",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) return const SizedBox.shrink();

            return userProvider.isAuthenticated
                ? PopupMenuButton(
              icon: const Icon(Icons.account_circle, color: Colors.black54, size: 32),
              onSelected: (value) async {
                if (value == 'dashboard') {
                  final username = userProvider.userData?['username'] ?? 'User';
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen(username: username)),
                  );
                } else if (value == 'logout') {
                  await userProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'dashboard', child: Text('Dashboard')),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            )
                : IconButton(
              icon: const Icon(Icons.login, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
            );
          },
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildWelcomeHeader(String username) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Continue your learning journey!",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  final CategoryProvider provider;
  const CategoriesSection({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    if (provider.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No categories available.")),
      );
    }
    return HomeScreenCategories(categoryProvider: provider);
  }
}