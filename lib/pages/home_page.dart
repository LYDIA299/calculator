import 'package:calculator/components/buttons_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String num1 = '';
  String num2 = '';
  String op = '';

  Color getBtnColor(String val) {
    return [Btn.del, Btn.clr].contains(val)
        ? Colors.blueGrey
        : [Btn.add, Btn.divide, Btn.subtract, Btn.dot, Btn.multiply, Btn.per]
                .contains(val)
            ? Colors.orange
            : Btn.calculate.contains(val)
                ? Colors.white70
                : Colors.black87;
  }

  void writeValue(String value) {
    setState(() {
      checkValue(value);
    });
  }

  void checkValue(String value) {
    if (int.tryParse(value) != null) {
      if (op.isEmpty) {
        num1 += value;
      } else {
        num2 += value;
      }
    } else {
      if ([Btn.add, Btn.subtract, Btn.divide, Btn.multiply].contains(value)) {
        if (op.isEmpty) {
          op = value;
        } else if (op.isNotEmpty && num2.isNotEmpty) {
          num1 = calculateResults().toStringAsPrecision(3);
          op = value;
          num2 = '';
        } else if (op.isNotEmpty) {
          return;
        } else if (num1.isEmpty && Btn.subtract.contains(value)) {
          num1 += value;
        }
      } else if ([Btn.del, Btn.clr, Btn.per, Btn.calculate].contains(value)) {
        if (Btn.del.contains(value)) {
          deleteValue();
        } else if (Btn.clr.contains(value)) {
          clearAll();
        } else if (Btn.per.contains(value)) {
          convertToPercentage();
        } else {
          num1 = calculateResults().toStringAsPrecision(3);
          op = '';
          num2 = '';
        }
      } else if (Btn.dot.contains(value)) {
        if (num1.contains(value) && op.isEmpty) {
          return;
        } else if (num2.contains(value) && op.isNotEmpty) {
          return;
        } else if (num1.isEmpty && num2.isEmpty) {
          num1 += "0.";
        } else if ((op.isEmpty && num2.isEmpty) &&
            !(num1.contains(value) || num2.contains(value))) {
          num1 += value;
        } else if (op.isNotEmpty && num2.isEmpty) {
          num2 += "0.";
        } else if (num2.isNotEmpty) {
          num2 += value;
        }
      }
    }
  }

  double calculateResults() {
    double result = 0.0;
    if (num1.isNotEmpty && op.isNotEmpty && num2.isNotEmpty) {
      double nbr1 = double.parse(num1);
      double nbr2 = double.parse(num2);
      switch (op) {
        case '+':
          result = nbr1 + nbr2;
          break;
        case '-':
          result = nbr1 - nbr2;
          break;
        case '×':
          result = nbr1 * nbr2;
          break;
        default:
          result = nbr2 != 0 ? nbr1 / nbr2 : 0;
      }
    }
    return result;
  }

  void deleteValue() {
    if (num2.isNotEmpty) {
      // 12323 => 1232
      num2 = num2.substring(0, num2.length - 1);
    } else if (op.isNotEmpty) {
      op = "";
    } else if (num1.isNotEmpty) {
      num1 = num1.substring(0, num1.length - 1);
    }
  }

  void clearAll() {
    num1 = '';
    num2 = '';
    op = '';
  }

  void convertToPercentage() {
    // ex: 434+324
    if (num1.isNotEmpty && op.isNotEmpty && num2.isNotEmpty) {
      // calculate before conversion
      num1 = calculateResults().toStringAsPrecision(3);
      op = '';
      num2 = '';
    }

    if (op.isNotEmpty) {
      // cannot be converted
      return;
    }

    final number = double.parse(num1);
    num1 = "${(number / 100)}";
  }

  Widget buildButton(val) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
          color: getBtnColor(val),
          clipBehavior: Clip.hardEdge,
          shape: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(100.0)),
          child: InkWell(
              onTap: () => writeValue(val),
              child: Center(
                  child: Text(
                val,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24.0),
              )))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final btnSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // text
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "$num1$op$num2".isEmpty ? '0' : "$num1$op$num2",
                  style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 60),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),

          //buttons
          Wrap(
            children: Btn.buttonValues
                .map((val) => SizedBox(
                    width: Btn.n0.contains(val)
                        ? btnSize.width / 2
                        : btnSize.width / 4,
                    height: btnSize.width / 5,
                    child: buildButton(val)))
                .toList(),
          )
        ],
      ),
    ));
  }
}
