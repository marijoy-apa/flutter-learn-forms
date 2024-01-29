import 'dart:io';
import 'package:expense_tracker/photo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredAmount = '';
  DateTime _selectedDate = DateTime.now();
  Category _selectedCategory = Category.leisure;
  File? _selectedImage;
  var _isSending = false;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate!;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    }
  }

  void _submitExpenseData() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      _showDialog();
      return;
    }
    formKey.currentState!.save();
    setState(() {
      _isSending = true;
    });
    final url = Uri.https('expense-tracker-af778-default-rtdb.firebaseio.com',
        'expense-list.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {
          'title': _enteredTitle,
          'amount': double.tryParse(_enteredAmount),
          'date': _selectedDate.toString(),
          'category': _selectedCategory.name,
          'imageFile': _selectedImage?.path,
        },
      ),
    );
    if (!context.mounted) {
      return;
    }
    final Map<String, dynamic> resData = json.decode(response.body);
    widget.onAddExpense(
      Expense(
          id: resData['name'],
          title: _enteredTitle,
          amount: double.tryParse(_enteredAmount)!,
          date: _selectedDate,
          category: _selectedCategory),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: 16, top: 16, right: 16, bottom: keyboardSpace + 16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  if (width >= 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddPhoto(
                          onPickImage: (pickedImage) =>
                              _selectedImage = pickedImage,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title cannot be empty';
                              }
                            },
                            onSaved: (newValue) => _enteredTitle = newValue!,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                            maxLength: 50,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Amount cannot be empty';
                              }
                              final enteredAmount = double.tryParse(value);
                              if (enteredAmount == null || enteredAmount <= 1) {
                                return 'Invalid amount';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$',
                              label: Text('Amount'),
                            ),
                            onSaved: (newValue) => _enteredAmount = newValue!,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        AddPhoto(
                          onPickImage: (pickedImage) =>
                              _selectedImage = pickedImage,
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title cannot be empty';
                              }
                              return null;
                            },
                            onSaved: (newValue) => _enteredTitle = newValue!,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                            maxLength: 50,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    width: 16,
                  ),
                  if (width >= 600)
                    Row(
                      children: [
                        const SizedBox(
                          width: 90,
                        ),
                        Expanded(
                          child: DropdownButtonFormField(
                              value: _selectedCategory,
                              items: Category.values
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                _selectedCategory = value!;
                              }),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(formatter.format(_selectedDate)),
                              IconButton(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.calendar_month),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Amount cannot be empty';
                              }
                              final enteredAmount = double.tryParse(value);
                              if (enteredAmount == null || enteredAmount <= 1) {
                                return 'Invalid amount';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$',
                              label: Text('Amount'),
                            ),
                            onSaved: (newValue) => _enteredAmount = newValue!,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(formatter.format(_selectedDate)),
                              IconButton(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.calendar_month),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (width >= 600)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _isSending ? null : _submitExpenseData,
                          child: _isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Save Expense'),
                        )
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                              value: _selectedCategory,
                              items: Category.values
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                _selectedCategory = value!;
                              }),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _isSending ? null : _submitExpenseData,
                          child: _isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Save Expense'),
                        )
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
