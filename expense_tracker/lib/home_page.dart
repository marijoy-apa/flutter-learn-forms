import 'package:expense_tracker/data/expense_list.dart';
import 'package:expense_tracker/expense_item.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
      floatingActionButton: FloatingActionButton(onPressed: () {
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const NewExpense(),
        );
      },
      child: const Icon(Icons.add)),
    );
  }
}
