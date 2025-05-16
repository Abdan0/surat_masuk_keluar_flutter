import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPiechart extends StatelessWidget {
  final int suratDone;
  final int suratNew;
  final int suratProcess;
  // final int jumlah;

  const MyPiechart(
    {super.key,
    required this.suratDone,
    required this.suratNew,
    required this.suratProcess,
    // required this.jumlah,
    }
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Teks di tengah pie chart
          Text(
            "${suratDone + suratNew + suratProcess}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // Pie chart
          PieChart(
            swapAnimationDuration: const Duration(milliseconds: 750),
            swapAnimationCurve: Curves.easeInOutQuint,
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: suratProcess.toDouble(),
                  color: Colors.lightBlue,
                ),
                PieChartSectionData(
                  value: suratDone.toDouble(),
                  color: Colors.lightGreen,
                ),
                PieChartSectionData(
                  value: suratNew.toDouble(),
                  color: Colors.yellow[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
