import 'package:flutter/material.dart';
import 'package:knowfin/budget_generator.dart';

class BudgetingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgeting')),
      body: HomeScreen(),
    );
  }
}
