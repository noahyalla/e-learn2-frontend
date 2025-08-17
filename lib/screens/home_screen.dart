// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/course_provider.dart';
import '../providers/user_provider.dart'; // Import the new provider
import '../screens/auth_screen.dart';
import '../homescreen_widgets/featured_courses.dart';
import '../homescreen_widgets/categories_widgets.dart';

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
    final userProvider = context.watch<UserProvider>(); // Watch the new provider
    final isAuthenticated = userProvider.isAuthenticated;

    // 🔹 Show loader if both are loading and empty
    if (categoryProvider.isLoading && courseProvider.courses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Show error
    if (categoryProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("E-Learning")),
        body: Center(child: Text(categoryProvider.errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Learning"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Conditionally show user details based on Strapi auth state
            if (isAuthenticated)
              SliverToBoxAdapter(
                child: _buildUserDetails(userProvider.userData?['username'] ?? 'User'),
              ),
            _buildHeader("Categories"),
            SliverToBoxAdapter(
              child: CategoriesSection(provider: categoryProvider),
            ),
            _buildHeader("Featured Courses"),
            SliverToBoxAdapter(
              child: FeaturedCourses(courseProvider: courseProvider),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 New method to build user details widget
  SliverToBoxAdapter _buildUserDetails(String username) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Section header builder
  SliverToBoxAdapter _buildHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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