import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() {
    return _ToDoScreen();
  }
}

class _ToDoScreen extends State<ToDoScreen> {

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> initDatabase() async {
    await DatabaseHelper.initDatabase();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final data = await DatabaseHelper.database.query('items');
      setState(() {
        items = data;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching items: $e');
      }
      setState(() {
        items = [];
      });
    }
  }

  Future<void> _addItem(String title, String description) async {
    if (title.isNotEmpty && description.isNotEmpty) {
      await DatabaseHelper.database.insert(
        'items',
        {'title': title, 'description': description}
      );
      _fetchItems();
    }
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.database.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id]
    );
    _fetchItems();
  }

  Future<void> _updateItem(int id, String title, String description) async {
    await DatabaseHelper.database.update(
      'items', 
      {'title': title, 'description': description},
      where: 'id = ?',
      whereArgs: [id]
    );
    _fetchItems();
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you Sure ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteItem(id);
              _fetchItems();
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int id, String currentTitle, String currentDescription) {
    final TextEditingController editTitle = TextEditingController(text: currentTitle);
    final TextEditingController editDescription = TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          children: [
            TextField(
              controller: editTitle,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add Title',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: editDescription,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateItem(id, editTitle.text, editDescription.text);
              _fetchItems();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      )
    );
  }

  void _showAddDialog() {
    final TextEditingController addTitleController = TextEditingController();
    final TextEditingController addDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          children: [
            TextField(
              controller: addTitleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Title',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: addDescriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addItem(addTitleController.text, addDescriptionController.text);
              addTitleController.clear();
              addDescriptionController.clear();
              _fetchItems();
              Navigator.pop(context);
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('To-Do List'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.black,
        ),
        toolbarHeight: 70,
        centerTitle: true,
        elevation: 10,
        actions: [
          IconButton(
            onPressed: () {
              null;
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30,),
          const Text('To-do Tasks:'),
          Expanded(
            child: items.isEmpty
            ? const Center(child: Text('no tasks yet!'),)
            : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Checkbox.adaptive(
                      value: item['completed'] ?? false,
                      onChanged: (bool? value){
                        null;
                      },
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showEditDialog(item['id'], item['title'], item['description']);
                            },
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(item['id']);
                            },
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}