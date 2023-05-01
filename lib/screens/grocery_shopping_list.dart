import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroceryShoppingList extends StatefulWidget {
  const GroceryShoppingList({Key? key}) : super(key: key);

  @override
  GroceryShoppingListState createState() => GroceryShoppingListState();
}

class GroceryShoppingListState extends State<GroceryShoppingList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemAmountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _itemCategoryController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  final List<Map<String, dynamic>> _groceryItems = [];
  bool _isFormVisible = false;

  late final Stream<QuerySnapshot> _categoriesStream = FirebaseFirestore
      .instance
      .collection('categories')
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadGroceryItems(); // add this line
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemAmountController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_itemCategoryController.text.isEmpty) return;

    await _firestore.collection('categories').doc().set({
      'categoryName': _itemCategoryController.text,
      'userId': _auth.currentUser?.uid,
    });

    _itemCategoryController.clear();
  }

  Future<void> _loadCategories() async {
    _categoriesStream.listen((QuerySnapshot querySnapshot) {
      setState(() {
        _categories = querySnapshot.docs
            .map((doc) =>
                (doc.data()! as Map<String, dynamic>)['categoryName'] as String)
            .toList();
      });
    });
  }

  void _toggleFormVisibility() {
    setState(() {
      _isFormVisible = !_isFormVisible;
    });
  }

  Future<void> _addItem() async {
    await _firestore.collection('groceryItems').add({
      'name': _itemNameController.text,
      'category': _selectedCategory,
      'amount': int.parse(_itemAmountController.text),
      'isChecked': false,
      'userId': _auth.currentUser?.uid,
    });
    _itemNameController.clear();
    _itemAmountController.clear();
    _toggleFormVisibility();
  }

  Future<void> _loadGroceryItems() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('groceryItems')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .get();
    setState(() {
      _groceryItems.clear();
      _groceryItems.addAll(querySnapshot.docs
          .map((doc) => (doc.data()! as Map<String, dynamic>))
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isFormVisible) {
          _toggleFormVisibility();
        }
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: _groceryItems.isEmpty ? 1 : _groceryItems.length,
            itemBuilder: (context, index) {
              if (_groceryItems.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 150.0),
                    child: Text('No items to buy for now!'),
                  ),
                );
              } else {
                final item = _groceryItems[index];
                return ListTile(
                  leading: Checkbox(
                    value: item['isChecked'] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        item['isChecked'] = value;
                      });
                    },
                  ),
                  title: Text(item['name']),
                  trailing: Text(item['amount'].toString()),
                );
              }
            },
          ),
          if (_isFormVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          if (_isFormVisible)
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                        ),
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
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        value: _selectedCategory,
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
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
                        validator: (value) => value == null
                            ? 'Please select an item category'
                            : null,
                      ),
                      TextFormField(
                        controller: _itemAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Item Amount',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter the amount'
                            : null,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _addItem();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: Visibility(
              visible: !_isFormVisible,
              child: FloatingActionButton(
                onPressed: _toggleFormVisibility,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
