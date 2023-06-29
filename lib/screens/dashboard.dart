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

  Future<void> getCustomersAndVendors() async {
    final customersQuerySnapshot = await customersCollection.get();
    final vendorsQuerySnapshot = await vendorsCollection.get();
    final int customersLength = customersQuerySnapshot.docs.length;
    final int vendorsLength = vendorsQuerySnapshot.docs.length;
    if (mounted) {
      setState(() => customerVendorData = [
            CustomerVendorData('Customers', customersLength),
            CustomerVendorData('Vendors', vendorsLength)
          ]);
    }
  }

  @override
  void initState() {
    getCustomersAndVendors();
    super.initState();
  }

  List<Color> colorPalette = [
    Colors.green.shade800,
    Colors.teal,
    Colors.cyan,
    Colors.brown,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.pink
  ];

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
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
                                    palette: colorPalette,
                                    tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                        textStyle:
                                            const TextStyle(fontFamily: 'Lato'),
                                        header: '',
                                        format: 'point.x\npoint.y orders sold'),
                                    series: <BarSeries<VendorData, String>>[
                                      BarSeries<VendorData, String>(
                                          // color: Colors.green,
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
                    })),
            // REGISTERED USERS
            SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: Card(
                    elevation: 10,
                    shadowColor: Colors.green.shade900,
                    shape: RoundedRectangleBorder(
                        side:
                            BorderSide(width: 2, color: Colors.green.shade900),
                        borderRadius: BorderRadius.circular(5)),
                    child: SfCircularChart(
                        title: ChartTitle(
                            text: 'REGISTERED USERS',
                            textStyle: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold)),
                        palette: [Colors.green, Colors.green.shade900],
                        tooltipBehavior: TooltipBehavior(enable: false),
                        series: <CircularSeries<CustomerVendorData, String>>[
                          PieSeries<CustomerVendorData, String>(
                              dataSource: customerVendorData,
                              xValueMapper: (CustomerVendorData data, _) =>
                                  data.x,
                              yValueMapper: (CustomerVendorData data, _) =>
                                  data.y,
                              dataLabelMapper: (datum, index) =>
                                  '${datum.x}: ${datum.y}',
                              dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.inside,
                                  textStyle: TextStyle(
                                      fontFamily: 'Lato')))
                        ]))),
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
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    textStyle:
                                        const TextStyle(fontFamily: 'Lato')),
                                series: <CircularSeries<CategoryData, String>>[
                                  DoughnutSeries<CategoryData, String>(
                                      strokeColor: Colors.white,
                                      strokeWidth: 2,
                                      dataSource: categoryDataList,
                                      xValueMapper: (CategoryData data, _) =>
                                          data.category,
                                      yValueMapper: (CategoryData data, _) =>
                                          data.count)
                                ])));
                  }
                  return const SizedBox.shrink();
                })
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
