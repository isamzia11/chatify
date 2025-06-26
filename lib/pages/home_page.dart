import 'package:chatify/pages/profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late double height;
  late double width;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Clean up to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Chatify'),

        titleTextStyle: TextStyle(fontSize: 16),
        centerTitle: true,
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Colors.blue),
            insets: EdgeInsets.symmetric(horizontal: -50),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,

          tabs: [
            Tab(icon: Icon(Icons.people_outline, size: 25)),
            Tab(icon: Icon(Icons.chat_bubble_outline, size: 25)),
            Tab(icon: Icon(Icons.person_outline, size: 25)),
          ],
        ),
      ),
      body: _tabBarPages(),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: [
        ProfilePage(height: height, width: width),
        ProfilePage(height: height, width: width),
        ProfilePage(height: height, width: width),
      ],
    );
  }
}
