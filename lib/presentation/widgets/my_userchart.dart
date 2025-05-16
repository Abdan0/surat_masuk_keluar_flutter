import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyUserchart extends StatelessWidget {
  final int userAdmin;
  final int userDekan;
  final int userWakilDekan;
  final int userStaff;

  const MyUserchart(
      {super.key,
      required this.userAdmin,
      required this.userDekan,
      required this.userStaff,
      required this.userWakilDekan});

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
            "${userAdmin + userDekan + userStaff + userWakilDekan}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // Pie chart
          PieChart(
            swapAnimationDuration: const Duration(milliseconds: 750),
            swapAnimationCurve: Curves.easeInOutQuint,
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: userAdmin.toDouble(),
                  color: Colors.lightBlue,
                ),
                PieChartSectionData(
                  value: userDekan.toDouble(),
                  color: Colors.lightGreen,
                ),
                PieChartSectionData(
                  value: userWakilDekan.toDouble(),
                  color: Colors.red,
                ),
                PieChartSectionData(
                  value: userStaff.toDouble(),
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
