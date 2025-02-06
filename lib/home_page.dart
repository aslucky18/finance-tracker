import 'package:flutter/material.dart';
import 'package:ftracker/view_transaction_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_transaction_page.dart';
import 'constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Define the lists for transaction types, account types, and utility types
  final List<String> _transactionTypes = ["Credit", "Debit"];
  final List<String> _accountTypes = ["Cash", "Bank", "Credit Card"];
  final List<String> _utilityTypes = [
    "Transportation",
    "Food & Beverages",
    "Regular Services",
    "Daily Essentials",
  ];

  // Define the map for utility categories
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

  // Define the map for account selections
  final Map<String, List<String>> _accountSelections = {
    "Cash": ["Cash"],
    "Credit Card": ["Credit Card 1099"],
    "Bank": ["Bank 8411"],
  };

  // Define the filters
  String? _selectedTransactionTypeFilter;
  String? _selectedAccountTypeFilter;
  String? _selectedAccountFilter;
  String? _selectedUtilityTypeFilter;
  String? _selectedUtilityCategoryFilter;
  double? _minAmount;
  double? _maxAmount;
  DateTime? _startDate;
  DateTime? _endDate;

  // Define the controllers for amount input fields
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // List to store transactions
  List<Map<String, dynamic>> transactions = [];
  String _sortOrder = 'Date';

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Load transactions when the widget is initialized
  }

  // Load transactions from shared preferences
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransactions = prefs.getStringList('transactions') ?? [];

    setState(() {
      transactions = savedTransactions
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });

    _applyFilters(); // Apply filters to the loaded transactions
    _sortTransactions(); // Sort the transactions
  }

  // Sort transactions based on the selected sort order
  void _sortTransactions() {
    setState(() {
      switch (_sortOrder) {
        case 'Date':
          transactions.sort((a, b) =>
              b['timestamp'].compareTo(a['timestamp'])); // Descending by date
          break;
        case 'Amount':
          transactions.sort((a, b) => double.parse(b['amount'])
              .compareTo(double.parse(a['amount']))); // Descending by amount
          break;
        case 'Type':
          transactions.sort((a, b) => a['transactionType']
              .compareTo(b['transactionType'])); // Alphabetical by type
          break;
      }
    });
  }

  // Navigate to the AddTransactionPage
  void _navigateToAddTransactionPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
    _loadTransactions(); // Reload transactions after adding a new one
  }

  // Delete a transaction by its ID
  Future<void> _deleteTransaction(String transactionID) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransactions = prefs.getStringList('transactions') ?? [];
    savedTransactions.removeWhere((item) {
      final transaction = jsonDecode(item) as Map<String, dynamic>;
      return transaction['transactionID'] == transactionID;
    });
    await prefs.setStringList('transactions', savedTransactions);
    _loadTransactions(); // Reload transactions after deletion
  }

  // Show a confirmation dialog before deleting a transaction
  void _showDeleteConfirmationDialog(String transactionID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
              'Are you sure you want to delete this transaction? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(transactionID); // Delete the transaction
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Show the bottom sheet for account filters
  void _showAccountFilterBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Transaction type filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Select Transaction Type"),
                          DropdownButton<String>(
                            hint: const Text("Select Transaction Type"),
                            value: _selectedTransactionTypeFilter,
                            items: [null, ..._transactionTypes]
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type ?? "All"),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTransactionTypeFilter = value;
                              });
                            },
                          ),
                        ],
                      ),
                      // Account type filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Select Account Type"),
                          DropdownButton<String>(
                            hint: const Text("Select Account Type"),
                            value: _selectedAccountTypeFilter,
                            items: [null, ..._accountTypes]
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type ?? "All"),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountTypeFilter = value;
                                if (value == "Cash") {
                                  _selectedAccountFilter = "Cash";
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      // Account filter

                      if (_selectedAccountTypeFilter != null &&
                          _selectedAccountTypeFilter != "Cash")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Select Account"),
                            DropdownButton<String>(
                              hint: const Text("Select Account"),
                              value: _selectedAccountFilter,
                              items: [
                                null,
                                ...?_accountSelections[
                                    _selectedAccountTypeFilter]
                              ]
                                  .map<DropdownMenuItem<String>>(
                                      (account) => DropdownMenuItem(
                                            value: account,
                                            child: Text(account ?? "All"),
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
                      // Utility type filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Select Utility Type"),
                          DropdownButton<String>(
                            hint: const Text("Select Utility Type"),
                            value: _selectedUtilityTypeFilter,
                            items: [null, ..._utilityTypes]
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type ?? "All"),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUtilityTypeFilter = value;
                                _selectedUtilityCategoryFilter = null;
                              });
                            },
                          ),
                        ],
                      ),
                      // Utility category filter
                      if (_selectedUtilityTypeFilter != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Select Utility Category"),
                            DropdownButton<String>(
                              hint: const Text("Select Utility Category"),
                              value: _selectedUtilityCategoryFilter,
                              items: [
                                null,
                                ...?_utilityCategories[
                                    _selectedUtilityTypeFilter]
                              ]
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category ?? "All"),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUtilityCategoryFilter = value;
                                });
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      // Amount range filter
                      Column(
                        children: [
                          const Text(
                            "Select Amount Range",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minAmountController,
                                  decoration: const InputDecoration(
                                      labelText: "Min Amount"),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _minAmount = value.isNotEmpty
                                          ? double.tryParse(value)
                                          : null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _maxAmountController,
                                  decoration: const InputDecoration(
                                      labelText: "Max Amount"),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _maxAmount = value.isNotEmpty
                                          ? double.tryParse(value)
                                          : null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Date range filter
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _startDate = picked;
                                  });
                                }
                              },
                              child: Text(_startDate == null
                                  ? "Start Date"
                                  : _startDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _endDate = picked;
                                  });
                                }
                              },
                              child: Text(_endDate == null
                                  ? "End Date"
                                  : _endDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Clear and Apply filters buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedTransactionTypeFilter = null;
                                _selectedAccountTypeFilter = null;
                                _selectedAccountFilter = null;
                                _selectedUtilityTypeFilter = null;
                                _selectedUtilityCategoryFilter = null;
                                _minAmountController.clear();
                                _maxAmountController.clear();
                                _startDate = null;
                                _endDate = null;
                                _loadTransactions(); // Reload transactions without filters
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Clear Filters'),
                          ),
                          TextButton(
                            onPressed: () {
                              _applyFilters(); // Apply the selected filters
                              Navigator.of(context).pop();
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  // Apply the selected filters to the transactions
  Future<void> _applyFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransactions = prefs.getStringList('transactions') ?? [];
    List<Map<String, dynamic>> filteredTransactions = savedTransactions
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    if (_selectedTransactionTypeFilter != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction['transactionType'] == _selectedTransactionTypeFilter;
      }).toList();
    }

    if (_selectedAccountTypeFilter != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction['accountType'] == _selectedAccountTypeFilter;
      }).toList();
    }

    if (_selectedAccountFilter != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction['account'] == _selectedAccountFilter;
      }).toList();
    }

    if (_selectedUtilityTypeFilter != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction['utilityType'] == _selectedUtilityTypeFilter;
      }).toList();
    }

    if (_selectedUtilityCategoryFilter != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction['utilityCategory'] == _selectedUtilityCategoryFilter;
      }).toList();
    }

    if (_minAmount != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return double.parse(transaction['amount']) >= _minAmount!;
      }).toList();
    }

    if (_maxAmount != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return double.parse(transaction['amount']) <= _maxAmount!;
      }).toList();
    }

    if (_startDate != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateTime.parse(transaction['timestamp'])
            .isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_endDate != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return DateTime.parse(transaction['timestamp'])
            .isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      transactions = filteredTransactions; // Update the transactions list
    });
  }

  // Build the transaction tile widget
  Widget _buildTransactionTile(
      BuildContext context, Map<String, dynamic> transaction) {
    return Dismissible(
      key: Key(transaction['transactionID']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _showDeleteConfirmationDialog(transaction['transactionID']);
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewTransactionPage(
            transactionData: transaction,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: transaction['transactionType'] == "Credit"
                ? LinearGradient(colors: [creditColors[2], creditColors[3]])
                : LinearGradient(colors: [debitColors[2], debitColors[3]]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction['account'],
                  style: const TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.white),
                    Text(
                      transaction['amount'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['transactionType'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      transaction['transactionID'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  "${DateTime.parse(transaction['timestamp']).toLocal().day.toString().padLeft(2, '0')}-${DateTime.parse(transaction['timestamp']).toLocal().month.toString().padLeft(2, '0')}-${DateTime.parse(transaction['timestamp']).toLocal().year}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalRecords = transactions.length;
    final double totalAmount = transactions.fold(
      0.0,
      (sum, transaction) => sum + double.parse(transaction['amount']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _sortOrder = value;
              _sortTransactions(); // Sort transactions based on the selected order
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Date', child: Text('Sort by Date')),
              const PopupMenuItem(
                  value: 'Amount', child: Text('Sort by Amount')),
              const PopupMenuItem(value: 'Type', child: Text('Sort by Type')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showAccountFilterBottomSheet, // Show filter options
          ),
        ],
      ),
      body: Column(
        children: [
          // Display total records and total amount
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Records: $totalRecords',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 20),
                    Text(
                      totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Display the list of transactions
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                        'No transactions available. Add a new transaction!'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionTile(
                          context, transactions[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _navigateToAddTransactionPage, // Navigate to add transaction page
        child: const Icon(Icons.add),
      ),
    );
  }
}
