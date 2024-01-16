import 'package:expense_tracker/data/expense_list.dart';
import 'package:expense_tracker/expense_item.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Expense> _registeredExpenses = expenseList;

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: ListView.builder(
        itemCount: expenseList.length,
        itemBuilder: (context, index) =>
            ExpenseItem(expense: expenseList[index]),
      ),
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
