import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';


final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { food, travel, leisure, work }


class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.imageFile,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final File? imageFile;

  String get formattedDate {
    return formatter.format(date);
  }
}