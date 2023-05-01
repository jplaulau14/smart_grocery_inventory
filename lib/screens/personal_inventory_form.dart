import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInventoryFormScreen extends StatefulWidget {
  const PersonalInventoryFormScreen({Key? key}) : super(key: key);

  @override
  PersonalInventoryFormScreenState createState() =>
      PersonalInventoryFormScreenState();
}

class PersonalInventoryFormScreenState
    extends State<PersonalInventoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCategoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('categories')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .get();
    setState(() {
      _categories = querySnapshot.docs
          .map((doc) =>
              (doc.data()! as Map<String, dynamic>)['categoryName'] as String)
          .toList();
    });
  }

  Future<void> _addItem() async {
    CollectionReference items = _firestore.collection('items');

    await items.add({
      'itemName': _itemNameController.text,
      'itemCategory': _selectedCategory,
      'amount': double.parse(_amountController.text),
      'userId': _auth.currentUser?.uid,
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added successfully')),
    );

    // Clear the form fields
    _itemNameController.clear();
    _amountController.clear();
    _selectedCategory = null;
  }

  Future<void> _addCategory() async {
    if (_itemCategoryController.text.isEmpty) return;

    CollectionReference categories = _firestore.collection('categories');

    await categories.add({
      'categoryName': _itemCategoryController.text,
      'userId': _auth.currentUser?.uid,
    });

    _itemCategoryController.clear();
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Inventory Form'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter the item name'
                    : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'Item Category',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add Category'),
                            content: TextFormField(
                              controller: _itemCategoryController,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _addCategory();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Add'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
                value: _selectedCategory,
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an item category' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter the amount' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _addItem();
                      }
                    },
                    child: const Text('Add'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/main_screen'),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
