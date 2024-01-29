import 'package:expense_tracker/expense_item.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _registeredExpenses = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('expense-tracker-af778-default-rtdb.firebaseio.com',
        'expense-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode > 400) {
        setState(() {
          _error = "Failed to load data. Please try again later. ";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      print(response.statusCode);
      final List<Expense> loadedItems = [];
      for (var item in listData.entries) {
        loadedItems.add(
          Expense(
            id: item.key,
            title: item.value['title'],
            amount: item.value['amount'],
            date: DateTime.parse(item.value['date']),
            category: convertStringToCategory(item.value['category']),
          ),
        );
      }
      setState(() {
        _registeredExpenses = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
      });
    }
  }

  Category convertStringToCategory(String categoryString) {
    return Category.values.firstWhere(
      (item) => item.name == categoryString,
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(
          seconds: 3,
        ),
        content: const Text('Expense deleted'),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, expense);
              });
            }),
      ),
    );
    final url = Uri.https('expense-tracker-af778-default-rtdb.firebaseio.com',
        'expense-list/${expense.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _registeredExpenses.insert(expenseIndex, expense);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No contents added yet'),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_registeredExpenses.isNotEmpty) {
      content = ListView.builder(
        itemCount: _registeredExpenses.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_registeredExpenses[index]),
          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
            margin: EdgeInsets.symmetric(
                horizontal: Theme.of(context).cardTheme.margin!.horizontal),
          ),
          onDismissed: (direction) =>
              _removeExpense(_registeredExpenses[index]),
          child: ExpenseItem(expense: _registeredExpenses[index]),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              useSafeArea: true,
              isScrollControlled: true,
              context: context,
              builder: (context) => NewExpense(
                onAddExpense: _addExpense,
              ),
            );
          },
          child: const Icon(Icons.add)),
    );
  }
}
