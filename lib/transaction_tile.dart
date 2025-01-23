import 'package:flutter/material.dart';

class ViewTransactionPage extends StatelessWidget {
  const ViewTransactionPage({
    super.key,
    required this.transactionData,
  });
  final transactionData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(18),
          padding: EdgeInsets.all(18),
          color: Colors.blueGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Transaction Reciept",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                "'transactionID':${transactionData['transactionID']},'\ntransactionType':${transactionData['transactionType']},'\naccountType':${transactionData['accountType']},'\naccount':${transactionData['account']},'\namount':${transactionData['amount']},'\nbankMessage':${transactionData['bankMessage']},'\nnotes':${transactionData['notes']},'\ntimestamp':${transactionData['timestamp']},",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
