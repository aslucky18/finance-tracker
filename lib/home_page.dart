import 'package:flutter/material.dart';
import 'package:ftracker/transaction_tile.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [];
  String _sortOrder = 'Date'; // Sorting criteria
  String? _selectedAccountTypeFilter;
  String? _selectedAccountFilter;

  final List<String> _accountTypes = ["Cash", "Bank", "Credit Card"];
  final Map<String, List<String>> _accountSelections = {
    "Cash": ["Cash"],
    "Credit Card": ["Credit Card 1099"],
    "Bank": ["Bank 8411"],
  };

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionList = prefs.getStringList('transactions') ?? [];
    setState(() {
      transactions = transactionList
          .map((transaction) => jsonDecode(transaction) as Map<String, dynamic>)
          .toList();
    });
    _applyFilters();
    _sortTransactions();
  }

  void _applyFilters() {
    if (_selectedAccountTypeFilter != null && _selectedAccountFilter != null) {
      transactions = transactions.where((transaction) {
        final accountType = transaction['accountType'];
        final account = transaction['account'];
        return accountType == _selectedAccountTypeFilter &&
            account == _selectedAccountFilter;
      }).toList();
    }
  }

  void _sortTransactions() {
    switch (_sortOrder) {
      case 'Date':
        transactions.sort((a, b) =>
            b['timestamp'].compareTo(a['timestamp'])); // Sort by timestamp
        break;
      case 'Amount':
        transactions.sort((a, b) => double.parse(b['amount'])
            .compareTo(double.parse(a['amount']))); // Sort by amount
        break;
      case 'Type':
        transactions.sort((a, b) => a['transactionType']
            .compareTo(b['transactionType'])); // Sort by transaction type
        break;
    }
  }

  void _navigateToAddTransactionPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
    _loadTransactions(); // Refresh transactions after returning
  }

  Future<void> _deleteTransaction(String transactionID) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionList = prefs.getStringList('transactions') ?? [];
    transactionList.removeWhere((transaction) {
      final transactionData = jsonDecode(transaction) as Map<String, dynamic>;
      return transactionData['transactionID'] == transactionID;
    });
    await prefs.setStringList('transactions', transactionList);
    _loadTransactions(); // Refresh after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
                _sortTransactions(); // Sort after selecting the criteria
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Date', child: Text('Sort by Date')),
              const PopupMenuItem(
                  value: 'Amount', child: Text('Sort by Amount')),
              const PopupMenuItem(value: 'Type', child: Text('Sort by Type')),
            ],
          ),
          // Account Type Filter
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Filter by Account Type'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          hint: const Text("Select Account Type"),
                          value: _selectedAccountTypeFilter,
                          items: _accountTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountTypeFilter = value;
                              // Automatically select 'Cash' for Cash account type
                              if (value == "Cash") {
                                _selectedAccountFilter = "Cash";
                              } else {
                                _selectedAccountFilter = null;
                              }
                            });
                          },
                        ),
                        if (_selectedAccountTypeFilter != null)
                          DropdownButton<String>(
                            hint: const Text("Select Account"),
                            value: _selectedAccountFilter,
                            items:
                                _accountSelections[_selectedAccountTypeFilter]!
                                    .map((account) => DropdownMenuItem(
                                          value: account,
                                          child: Text(account),
                                        ))
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountFilter = value;
                              });
                            },
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _selectedAccountTypeFilter = null;
                          _selectedAccountFilter = null;
                          _loadTransactions(); // Reset filter
                        },
                        child: const Text('Clear Filter'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _loadTransactions(); // Apply filter after selecting
                        },
                        child: const Text('Apply Filter'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text('No transactions available. Add a new transaction!'),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ViewTransactionPage(
                      transactionData: transaction,
                    ),
                  )),
                  child: Center(
                    child: Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(transaction['account']),
                            Row(
                              children: [
                                Icon(Icons.currency_rupee),
                                Text(transaction['amount'])
                              ],
                            ),
                          ],
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction['transactionType']),
                                Text(transaction['transactionID']),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  _deleteTransaction(
                                      transaction['transactionID']);
                                },
                                icon: Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransactionPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
