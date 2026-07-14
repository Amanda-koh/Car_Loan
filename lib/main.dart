import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Car Loan Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _loanAmount = 0.0;
  double _netIncome = 0.0;
  double _interestRate = 0.0;
  int _loanPeriod = 1;
  bool _hasGuarentor = false;
  int _carType = 1;
  double _repaymentAmount = 0.0;
  String _repaymentOutput = '';
  final _years = {1, 2, 3, 4, 5, 6, 7, 8, 9};

  //Controller
  final loanAmountCtrl = TextEditingController();
  final netIncomeCtrl = TextEditingController();
  final interestRateCtrl = TextEditingController();

  //setfocus
  final _myFocusNode = FocusNode();
  final myCurrency = intl.NumberFormat('#,##0.00', 'ms_MY');

  final _formKey = GlobalKey<FormState>();

  void myAlertDialog() {
    AlertDialog eligibilityAlertDialog = AlertDialog(
      title: const Text('Eligibility'),
      content: const Text(
          'You are not eligible on this loan. Get a guarantor to proceed.'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return eligibilityAlertDialog;
      },
    );
  }

  void _calculateRepayment() {
    if (_formKey.currentState!.validate()) {
      _loanAmount = double.parse(loanAmountCtrl.text);
      _netIncome = double.parse(netIncomeCtrl.text);
      _interestRate = double.parse(interestRateCtrl.text);

      var interest = _loanAmount * _loanPeriod * (_interestRate / 100);
      _repaymentAmount = (_loanAmount + interest) / (_loanPeriod * 12);

      bool eligibility = _netIncome * 0.3 > _repaymentAmount;

      if (eligibility || _hasGuarentor) {
        setState(() {
          _repaymentOutput = 'Repayment Amount: '
              '${myCurrency.currencySymbol}'
              '${myCurrency.format(_repaymentAmount)}'
              '\n'
              'Eligibility: ${eligibility ? 'Eligible' : 'Not Eligible'}';
        });
      } else {
        myAlertDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Loan Amount'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: loanAmountCtrl,
                  focusNode: _myFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Loan Amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Net Income'),
                  keyboardType: TextInputType.number,
                  controller: netIncomeCtrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Net Income';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Interest Rate'),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal:true, signed:false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  controller: interestRateCtrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Interest Rate';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _loanPeriod,
                  items: _years.map((int item) {
                    return DropdownMenuItem<int>(
                      value: item,
                      child: Text('$item year(s)'),
                    );
                  }).toList(),
                  onChanged: (int? item) {
                    setState(() {
                      _loanPeriod = item!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Loan Period'),
                ),
                SwitchListTile(
                  title: const Text('Has Guarantor'),
                  value: _hasGuarentor,
                  onChanged: (bool value) {
                    setState(() {
                      _hasGuarentor = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculateRepayment,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 20),
                Text(
                  _repaymentOutput,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
