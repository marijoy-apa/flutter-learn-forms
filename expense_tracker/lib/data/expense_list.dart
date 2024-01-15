import 'package:expense_tracker/model/expense.dart';

List<Expense> expenseList = [
  Expense(
      title: 'Flutter Course',
      amount: 22.12,
      date: DateTime.now(),
      category: Category.food),
  Expense(
      title: 'Flutter Food',
      amount: 12.12,
      date: DateTime.now(),
      category: Category.leisure),
];
