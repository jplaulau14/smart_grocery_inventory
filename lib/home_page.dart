import 'package:flutter/material.dart';
import 'screens/grocery_shopping_list.dart';
import 'screens/personal_inventory_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
                icon: Icon(Icons.shopping_cart),
                text: 'Grocery & Shopping List'),
            Tab(icon: Icon(Icons.inventory), text: 'Personal Inventory List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GroceryShoppingList(),
          PersonalInventoryList(),
        ],
      ),
    );
  }
}
