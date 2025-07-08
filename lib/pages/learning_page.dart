import 'package:flutter/material.dart';
import 'package:knowfin/pages/learning_page_pages/books.dart';
import 'package:knowfin/pages/learning_page_pages/loan.dart';
import 'package:knowfin/pages/learning_page_pages/scholarship.dart';
import 'learning_page_pages/debt_management_page.dart';
import 'learning_page_pages/taxation.dart';
import 'learning_page_pages/basic_of_finance.dart';
import 'learning_page_pages/government_schemes.dart';
import 'learning_page_pages/budgeting_page.dart';
import 'learning_page_pages/insurance.dart';

class LearningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Learning')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modules",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildModuleCard(context, 'Budgeting', '', Icons.calculate,
                      BudgetingPage()),
                  _buildModuleCard(context, 'DEBT Management', '',
                      Icons.account_balance, DebtManagementPage()),
                  _buildModuleCard(
                      context, 'Books', '', Icons.book, BookScreen()),
                  _buildModuleCard(context, 'Insurance', '', Icons.lightbulb,
                      InsuranceListPage()),
                  _buildModuleCard(
                      context, 'Taxation', '', Icons.school, TaxationPage()),
                  _buildModuleCard(context, 'Basic of Finance', '', Icons.money,
                      FinanceBasicsPage()),
                  _buildModuleCard(context, 'Government Schemes', '',
                      Icons.schedule, SchemesPage()),
                  _buildModuleCard(context, 'scholarships', '',
                      Icons.monetization_on, ScholarshipList()),
                  _buildModuleCard(context, 'loan', '',
                      Icons.monetization_on_sharp, LoanList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, String subtitle,
      IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple, // Adjust the color as needed
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              // const Text(
              //   "0% Completed",
              //   style: TextStyle(
              //     color: Colors.white70,
              //     fontSize: 12,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
