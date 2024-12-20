import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class BestSellingProductsChart extends StatefulWidget {
  @override
  _BestSellingProductsChartState createState() => _BestSellingProductsChartState();
}

class _BestSellingProductsChartState extends State<BestSellingProductsChart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> productSales = {};

  @override
  void initState() {
    super.initState();
    _fetchBestSellingProducts();
  }

  Future<void> _fetchBestSellingProducts() async {
    try {
      final querySnapshot = await _firestore.collection('transactions').get();
      Map<String, int> sales = {};

      for (var doc in querySnapshot.docs) {
        final transaction = doc.data();
        if (transaction.containsKey('products')) {
          List<dynamic> products = transaction['products'];
          for (var product in products) {
            String name = product['name'] ?? 'Unnamed Product';
            int quantity = product['quantity'] ?? 0;
            sales[name] = (sales[name] ?? 0) + quantity;
          }
        }
      }

      setState(() {
        productSales = sales;
      });
    } catch (e) {
      print('Error fetching product sales data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chart data.')),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Selling Products'),
      ),
      body: productSales.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Best Selling Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= productSales.keys.length) {
                            return SizedBox.shrink();
                          }
                          return Transform.rotate(
                            angle: -0.4, // Slight rotation for better readability
                            child: Text(
                              productSales.keys.elementAt(value.toInt()),
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: productSales.values.toList().asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
