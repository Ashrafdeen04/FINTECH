import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebtManagementPage extends StatefulWidget {
  @override
  _DebtManagementPageState createState() => _DebtManagementPageState();
}

class _DebtManagementPageState extends State<DebtManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _sourceNameController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  String _selectedType = 'Bank';
  String _selectedInterestType = 'Annual';
  DateTime _deadline = DateTime.now();
  DateTime _startDate = DateTime.now();

  void _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('debts').add({
        'debtAmount': double.parse(_debtAmountController.text),
        'type': _selectedType,
        'sourceName': _sourceNameController.text,
        'interestType': _selectedInterestType,
        'interestRate': _interestRateController.text,
        'deadline': _deadline,
        'startDate': _startDate,
      });

      // Clear the form after saving
      _debtAmountController.clear();
      _sourceNameController.clear();
      _interestRateController.clear();
      setState(() {
        _selectedType = 'Bank';
        _selectedInterestType = 'Annual';
        _deadline = DateTime.now();
        _startDate = DateTime.now();
      });
    }
  }

  void _deleteDebt(String id) async {
    await FirebaseFirestore.instance.collection('debts').doc(id).delete();
  }

  void _paybackDebt(String id, double currentAmount) async {
    final TextEditingController _paybackAmountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payback Debt'),
          content: TextFormField(
            controller: _paybackAmountController,
            decoration: InputDecoration(labelText: 'Enter payback amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double paybackAmount =
                    double.parse(_paybackAmountController.text);
                double newAmount = currentAmount - paybackAmount;

                if (newAmount < 0) newAmount = 0;

                await FirebaseFirestore.instance
                    .collection('debts')
                    .doc(id)
                    .update({
                  'debtAmount': newAmount,
                });

                Navigator.of(context).pop();
              },
              child: Text('Payback'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debt Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _debtAmountController,
                      decoration: InputDecoration(labelText: 'Debt Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter debt amount' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(labelText: 'Select Type'),
                      items: ['Bank', 'Third Party'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _sourceNameController,
                      decoration: InputDecoration(labelText: 'Source Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter source name' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedInterestType,
                      decoration: InputDecoration(labelText: 'Interest Type'),
                      items: ['Annual', 'Monthly', 'Other'].map((interestType) {
                        return DropdownMenuItem(
                          value: interestType,
                          child: Text(interestType),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInterestType = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _interestRateController,
                      decoration:
                          InputDecoration(labelText: 'Rate of Interest'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter interest rate' : null,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _startDate = selectedDate;
                          });
                        }
                      },
                      child: Text(
                          'StartDate ${_startDate.toLocal()}'.split(' ')[0]),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _deadline,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _deadline = selectedDate;
                          });
                        }
                      },
                      child:
                          Text('Deadline ${_deadline.toLocal()}'.split(' ')[0]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveDebt,
                      child: Text('Save Debt'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('debts').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final debts = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: debts.length,
                    itemBuilder: (context, index) {
                      final debt = debts[index];
                      return ListTile(
                        title: Text('Amount: ${debt['debtAmount']}'),
                        subtitle: Text(
                            'Source: ${debt['sourceName']} | Interest: ${debt['interestRate']} ${debt['interestType']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.payment, color: Colors.green),
                              onPressed: () {
                                _paybackDebt(debt.id, debt['debtAmount']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteDebt(debt.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
