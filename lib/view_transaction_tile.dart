// Importing the Flutter Material package
import 'package:flutter/material.dart';

import 'constants.dart';

// Stateless widget for displaying a transaction page
class ViewTransactionPage extends StatelessWidget {
  const ViewTransactionPage({
    super.key,
    required this.transactionData, // Transaction data passed to the widget
  });

  final Map<String, dynamic>
      transactionData; // Strongly typed for clarity and safety

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildCloseButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          _buildUpperContainer(
              context), // Displays transaction details at the top
          _buildLowerContainer(), // Displays additional details like notes and bank message
        ],
      ),
    );
  }

  /// Creates a circular close button for navigating back
  CircleAvatar _buildCloseButton(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: transactionData['transactionType'] == "Credit"
          ? creditColors[3]
          : debitColors[3],
      child: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context); // Close the page
        },
      ),
    );
  }

  /// Displays additional details such as amount, notes, and optional bank message
  Padding _buildLowerContainer() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountDisplay(),
          const SizedBox(height: 20),
          if (transactionData['account'] !=
              "Cash") // Show bank message only if account is not "Cash"
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bank Message:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transactionData['bankMessage'] ??
                      "No message", // Handle null safety
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          const Text(
            "Notes:",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            transactionData['notes'] ??
                "No notes available", // Handle null safety
          ),
        ],
      ),
    );
  }

  /// Displays the transaction amount in a large, bold style
  Row _buildAmountDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '₹${transactionData['amount'] ?? '0.00'}', // Handle null safety
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Displays the upper section of the page with transaction summary
  Container _buildUpperContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 50),
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: transactionData['transactionType'] == "Credit"
              ? creditColors
              : debitColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Stretch contents horizontally
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transaction Receipt",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transactionData['transactionType'] ??
                    "Unknown", // Handle null safety
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transactionData['transactionID'] ?? "N/A", // Handle null safety
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transactionData['account'] ??
                    "Unknown Account", // Handle null safety
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Adds spacing
        ],
      ),
    );
  }
}
