import 'package:flutter/material.dart';

List<Color> creditColors = [
  Color(0xff1C6433),
  Color(0xff2A974D),
  Color(0xff32B05A),
  Color(0xff39CA67),
];
List<Color> debitColors = [
  Color(0xff240B0B),
  Color(0xff571A1A),
  Color(0xff712222),
  Color(0xff8A2929),
];
List<String> _transactionTypes = ["Credit", "Debit"];
List<String> _accountTypes = ["Cash", "Bank", "Credit Card"];
List<String> _utilityTypes = [
  "Transportation",
  "Food & Beverages",
  "Regular Services",
  "Daily Essentials"
];
Map<String, List<String>> _utilityCategories = {
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

Map<String, String> _accountSelections = {
  "Cash": "",
  "Credit Card": "1099",
  "Bank": "8411",
};
