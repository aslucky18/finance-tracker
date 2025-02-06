import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RandomDataGenerator {
  static final Faker faker = Faker();

  // Generates a random transaction for testing
  static Map<String, dynamic> generateRandomTransaction() {
    final String transactionID =
        "TXN-${faker.date.dateTime().millisecondsSinceEpoch}";
    final String transactionType =
        faker.randomGenerator.element(['Credit', 'Debit']);
    final String accountType =
        faker.randomGenerator.element(['Cash', 'Bank', 'Credit Card']);
    final String account = faker.randomGenerator
        .element(['Cash', 'Bank 8411', 'Credit Card 1099']);
    final String utilityType = faker.randomGenerator.element([
      'Transportation',
      'Food & Beverages',
      'Regular Services',
      'Daily Essentials'
    ]);
    final String utilityCategory = faker.randomGenerator.element(
        ['Fuel/Gas', 'Groceries', 'Mobile recharges', 'Personal care items']);
    final String amount =
        List.generate(5, (_) => faker.randomGenerator.integer(10))
            .join(); // Random 3 digit amount
    final String bankMessage = faker.lorem.sentence();
    final String notes = faker.lorem.sentence();
    final String timestamp = DateTime.now().toIso8601String();

    return {
      'transactionID': transactionID,
      'transactionType': transactionType,
      'accountType': accountType,
      'account': account,
      'utilityType': utilityType,
      'utilityCategory': utilityCategory,
      'amount': amount,
      'bankMessage': bankMessage,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  // Save a list of random transactions to SharedPreferences
  static Future<void> generateAndSaveRandomTransactions(
      int numberOfTransactions) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactions = [];

    for (int i = 0; i < numberOfTransactions; i++) {
      final transaction = generateRandomTransaction();
      transactions.add(jsonEncode(transaction));
    }

    await prefs.setStringList('transactions', transactions);
  }
}
