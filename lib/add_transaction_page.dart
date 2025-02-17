import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final List<String> _transactionTypes = ["Credit", "Debit"];
  final List<String> _accountTypes = ["Cash", "Bank", "Credit Card"];
  final List<String> _utilityTypes = [
    "Transportation",
    "Food & Beverages",
    "Regular Services",
    "Daily Essentials"
  ];
  final Map<String, List<String>> _utilityCategories = {
    "Transportation": ["Fuel/Gas", "Public transport fares", "Parking fees"],
    "Food & Beverages": ["Groceries", "Coffee/Tea", "Lunch expenses"],
    "Regular Services": [
      "Mobile recharges",
      "Internet data packs",
      "Subscription services"
    ],
    "Daily Essentials": [
      "Personal care items",
      "Household supplies",
      "Medicine/Healthcare items"
    ],
  };

  final Map<String, String> _accountSelections = {
    "Cash": "",
    "Credit Card": "1099",
    "Bank": "8411",
  };

  String? _selectedTransactionType;
  String? _selectedAccountType;
  String? _selectedAccount;
  String? _selectedUtilityType;
  String? _selectedUtilityCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankMessageController = TextEditingController();
  final TextEditingController _notesController =
      TextEditingController(text: "No Notes");
  String _transactionID = "";

  @override
  void dispose() {
    _amountController.dispose();
    _bankMessageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: "Transaction Type",
                  items: _transactionTypes,
                  value: _selectedTransactionType,
                  onChanged: (value) =>
                      setState(() => _selectedTransactionType = value),
                ),
                const SizedBox(height: 15),
                _buildDropdownField(
                  label: "Account Type",
                  items: _accountTypes,
                  value: _selectedAccountType,
                  onChanged: (value) => setState(() {
                    _selectedAccountType = value;
                    _selectedAccount = null; // Reset account selection
                  }),
                ),
                const SizedBox(height: 15),
                if (_selectedAccountType != null)
                  _buildDropdownField(
                    label: "Account",
                    items: _getFilteredAccounts(),
                    value: _selectedAccount,
                    onChanged: (value) =>
                        setState(() => _selectedAccount = value),
                  ),
                const SizedBox(height: 15),
                _buildDropdownField(
                  label: "Utility Type",
                  items: _utilityTypes,
                  value: _selectedUtilityType,
                  onChanged: (value) => setState(() {
                    _selectedUtilityType = value;
                    _selectedUtilityCategory = null; // Reset utility category
                  }),
                ),
                const SizedBox(height: 15),
                if (_selectedUtilityType != null)
                  _buildDropdownField(
                    label: "Utility Category",
                    items: _utilityCategories[_selectedUtilityType] ?? [],
                    value: _selectedUtilityCategory,
                    onChanged: (value) =>
                        setState(() => _selectedUtilityCategory = value),
                  ),
                const SizedBox(height: 15),
                _buildTextInputField(
                  controller: _amountController,
                  label: "Amount",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                if (_selectedAccountType != "Cash")
                  _buildTextInputField(
                    controller: _bankMessageController,
                    label: "Paste Bank Message Here",
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                  ),
                if (_selectedAccountType != "Cash") const SizedBox(height: 15),
                _buildTextInputField(
                  controller: _notesController,
                  label: "Notes",
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _submitTransaction,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  List<String> _getFilteredAccounts() {
    switch (_selectedAccountType) {
      case "Cash":
        return ["Cash"];
      case "Credit Card":
        return ["Credit Card 1099"];
      case "Bank":
        return ["Bank 8411"];
      default:
        return [];
    }
  }

  Future<void> _submitTransaction() async {
    if (_selectedTransactionType == null ||
        _selectedAccountType == null ||
        _selectedAccount == null ||
        _amountController.text.isEmpty ||
        (_selectedAccountType != "Cash" &&
            _bankMessageController.text.isEmpty) ||
        _selectedUtilityType == null ||
        _selectedUtilityCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
        ),
      );
      return;
    }

    final String formattedDate = DateTime.now().toString();

    _transactionID = "TXN-$formattedDate";

    final transactionData = {
      'transactionID': _transactionID,
      'transactionType': _selectedTransactionType,
      'accountType': _selectedAccountType,
      'account': _selectedAccount,
      'utilityType': _selectedUtilityType,
      'utilityCategory': _selectedUtilityCategory,
      'amount': _amountController.text,
      'bankMessage': _bankMessageController.text,
      'notes': _notesController.text,
      'timestamp': formattedDate,
    };

    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];
    transactions.add(jsonEncode(transactionData));
    await prefs.setStringList('transactions', transactions);

    debugPrint('Transaction Submitted');
    debugPrint('Transaction Data: $transactionData');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Transaction ID: $_transactionID submitted successfully!')),
    );

    // Clear fields after submission
    setState(() {
      _selectedTransactionType = null;
      _selectedAccountType = null;
      _selectedAccount = null;
      _selectedUtilityType = null;
      _selectedUtilityCategory = null;
      _amountController.clear();
      _bankMessageController.clear();
      _notesController.clear();
    });
  }
}
