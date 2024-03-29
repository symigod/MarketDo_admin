import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/firebase.services.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = 'dashboard-screen';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<CustomerVendorData> customerVendorData = [];
  late int customers = 0;
  late int vendors = 0;

  List<VendorData> chartData = [];
  List<CategoryData> productCategoryData = [];

  Stream<List<CustomerVendorData>> getCustomersAndVendors() {
    Stream<List<CustomerVendorData>> stream = Stream.fromFuture(Future.wait([
      customersCollection.get(),
      vendorsCollection.get(),
    ])).asyncMap((List<QuerySnapshot> snapshots) {
      final customersQuerySnapshot = snapshots[0];
      final vendorsQuerySnapshot = snapshots[1];
      final int customersLength = customersQuerySnapshot.docs.length;
      final int vendorsLength = vendorsQuerySnapshot.docs.length;
      return [
        CustomerVendorData('Customers', customersLength),
        CustomerVendorData('Vendors', vendorsLength),
      ];
    });

    return stream;
  }

  late StreamController<List<CustomerVendorData>>
      _customerVendorDataStreamController;

  @override
  void initState() {
    _customerVendorDataStreamController =
        StreamController<List<CustomerVendorData>>();
    _customerVendorDataStreamController.addStream(getCustomersAndVendors());
    super.initState();
  }

  List<Color> colorPalette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black
  ];

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            // REGISTERED USERS
            StreamBuilder(
                stream: _customerVendorDataStreamController.stream,
                builder: (context, rus) {
                  if (rus.hasData) {
                    List<CustomerVendorData>? customerVendorData = rus.data;
                    return SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Card(
                            elevation: 10,
                            shadowColor: Colors.green.shade900,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: Colors.green.shade900),
                                borderRadius: BorderRadius.circular(5)),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'REGISTERED USERS',
                                    textStyle: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold)),
                                palette: [
                                  Colors.pink.shade900,
                                  Colors.blue.shade900
                                ],
                                tooltipBehavior: TooltipBehavior(enable: false),
                                series: <CircularSeries<CustomerVendorData,
                                    String>>[
                                  PieSeries<CustomerVendorData, String>(
                                      dataSource: customerVendorData,
                                      xValueMapper: (CustomerVendorData data,
                                              _) =>
                                          data.x,
                                      yValueMapper:
                                          (CustomerVendorData data, _) =>
                                              data.y,
                                      dataLabelMapper: (datum, index) =>
                                          '${datum.x}: ${datum.y}',
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                              isVisible: true,
                                              labelPosition:
                                                  ChartDataLabelPosition
                                                      .outside,
                                              useSeriesColor: true,
                                              textStyle: TextStyle(
                                                  fontFamily: 'Lato')))
                                ])));
                  } else if (rus.hasError) {
                    return errorWidget(rus.error.toString());
                  } else {
                    return loadingWidget();
                  }
                }),
            // PRODUCT CATEGORIES
            StreamBuilder(
                stream: productsCollection.snapshots(),
                builder: (context, ps) {
                  if (ps.hasError) {
                    return errorWidget(ps.error.toString());
                  }
                  if (ps.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  }
                  if (ps.hasData) {
                    final products = ps.data!.docs;
                    Map<String, int> categoryCountMap = {};
                    for (var product in products) {
                      final category = product['category'] as String;
                      categoryCountMap[category] =
                          (categoryCountMap[category] ?? 0) + 1;
                    }
                    List<CategoryData> categoryDataList = [];
                    categoryCountMap.forEach((category, count) =>
                        categoryDataList.add(CategoryData(category, count)));
                    return SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Card(
                            elevation: 10,
                            shadowColor: Colors.green.shade900,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: Colors.green.shade900),
                                borderRadius: BorderRadius.circular(5)),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'PRODUCT CATEGORIES',
                                    textStyle: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold)),
                                palette: colorPalette,
                                legend: Legend(
                                    isVisible: true,
                                    toggleSeriesVisibility: false,
                                    overflowMode: LegendItemOverflowMode.wrap),
                                tooltipBehavior: TooltipBehavior(enable: false),
                                series: <CircularSeries<CategoryData, String>>[
                                  DoughnutSeries<CategoryData, String>(
                                      strokeColor: Colors.white,
                                      strokeWidth: 2,
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                              isVisible: true,
                                              labelPosition:
                                                  ChartDataLabelPosition
                                                      .outside,
                                              textStyle: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.bold)),
                                      dataSource: categoryDataList,
                                      xValueMapper: (CategoryData data, _) =>
                                          data.category,
                                      yValueMapper: (CategoryData data, _) =>
                                          data.count)
                                ])));
                  }
                  return const SizedBox.shrink();
                }),
            // SALES REPORT
            Card(
                elevation: 10,
                shadowColor: Colors.green.shade900,
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.green.shade900),
                    borderRadius: BorderRadius.circular(5)),
                child: StreamBuilder(
                    stream: ordersCollection.snapshots(),
                    builder: (context, os) {
                      if (os.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (os.connectionState == ConnectionState.waiting) {
                        return loadingWidget();
                      }
                      if (os.hasData) {
                        final orders = os.data!.docs;
                        Map<String, int> vendorCountMap = {};
                        return StreamBuilder(
                            stream: vendorsCollection.snapshots(),
                            builder: (context, vs) {
                              if (vs.hasError) {
                                return const Text('Something went wrong');
                              }
                              if (vs.connectionState ==
                                  ConnectionState.waiting) {
                                return loadingWidget();
                              }
                              if (vs.hasData) {
                                final vendors = vs.data!.docs;
                                Map<String, String> vendorNameMap = {};
                                for (var vendor in vendors) {
                                  final vendorName =
                                      vendor['vendorID'] as String;
                                  final businessName =
                                      vendor['businessName'] as String;
                                  vendorNameMap[vendorName] = businessName;
                                }
                                for (var order in orders) {
                                  final vendorName =
                                      order['vendorID'] as String;
                                  vendorCountMap[vendorName] =
                                      (vendorCountMap[vendorName] ?? 0) + 1;
                                }
                                List<VendorData> vendorDataList = [];
                                for (var entry in vendorCountMap.entries) {
                                  final vendorName =
                                      vendorNameMap[entry.key] ?? 'Unknown';
                                  vendorDataList
                                      .add(VendorData(vendorName, entry.value));
                                }
                                return SfCartesianChart(
                                    title: ChartTitle(
                                        text: 'SALES REPORT',
                                        textStyle: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.bold)),
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(),
                                    tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                        textStyle:
                                            const TextStyle(fontFamily: 'Lato'),
                                        header: '',
                                        format: 'point.x\npoint.y orders sold'),
                                    series: <BarSeries<VendorData, String>>[
                                      BarSeries<VendorData, String>(
                                          color: Colors.green.shade900,
                                          dataSource: vendorDataList,
                                          xValueMapper: (VendorData data, _) =>
                                              data.vendorName,
                                          yValueMapper: (VendorData data, _) =>
                                              data.orderCount)
                                    ]);
                              }
                              return loadingWidget();
                            });
                      }
                      return loadingWidget();
                    }))
          ]));

  Widget analyticWidget({required String title, required String value}) =>
      Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SizedBox(
              height: 200,
              width: 275,
              child: Card(
                  color: Colors.green,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(title,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                              const Divider(color: Colors.white)
                            ]),
                        Center(
                            child: FittedBox(
                                child: Text(value,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    textAlign: TextAlign.center))),
                        Container()
                      ]))));
}

class CustomerVendorData {
  final String x;
  final int y;

  CustomerVendorData(this.x, this.y);

  Map<String, dynamic> getChartData() {
    return {'x': x, 'y': y};
  }
}

class ProductsData {
  final String x;
  final int y;

  ProductsData(this.x, this.y);

  Map<String, dynamic> getChartData() {
    return {'x': x, 'y': y};
  }
}

class VendorData {
  final String vendorName;
  final int orderCount;

  VendorData(this.vendorName, this.orderCount);
}

class CategoryData {
  final String category;
  final int count;

  CategoryData(this.category, this.count);
}
