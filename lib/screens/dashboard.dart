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

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(spacing: 15, runSpacing: 20, children: [
        // TOP SALES
        Card(
          elevation: 10,
          shadowColor: Colors.green.shade900,
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Colors.green.shade900),
              borderRadius: BorderRadius.circular(5)),
          child: StreamBuilder(
              stream: ordersCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                }
                if (snapshot.hasData) {
                  final orders = snapshot.data!.docs;
                  Map<String, int> vendorCountMap = {};
                  return StreamBuilder(
                      stream: vendorsCollection.snapshots(),
                      builder: (context, vendorSnapshot) {
                        if (vendorSnapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (vendorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return loadingWidget();
                        }
                        if (vendorSnapshot.hasData) {
                          final vendors = vendorSnapshot.data!.docs;
                          Map<String, String> vendorNameMap = {};
                          for (var vendor in vendors) {
                            final vendorName = vendor['vendorID'] as String;
                            final businessName =
                                vendor['businessName'] as String;
                            vendorNameMap[vendorName] = businessName;
                          }
                          for (var order in orders) {
                            final vendorName = order['vendorID'] as String;
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
                                    color: Colors.green,
                                    dataSource: vendorDataList,
                                    xValueMapper: (VendorData data, _) =>
                                        data.vendorName,
                                    yValueMapper: (VendorData data, _) =>
                                        data.orderCount)
                              ]);
                        }
                        return const SizedBox.shrink();
                      });
                }
                return const SizedBox.shrink();
              }),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Card(
                elevation: 10,
                shadowColor: Colors.green.shade900,
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.green.shade900),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: SfCircularChart(
                        palette: const [Colors.blue, Colors.green],
                        legend: Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(
                            enable: true,
                            textStyle: const TextStyle(fontFamily: 'Lato')),
                        series: <CircularSeries<CustomerVendorData, String>>[
                          DoughnutSeries<CustomerVendorData, String>(
                              dataSource: customerVendorData,
                              xValueMapper: (CustomerVendorData data, _) =>
                                  data.x,
                              yValueMapper: (CustomerVendorData data, _) =>
                                  data.y)
                        ])))),
        //PRODUCTS TOTAL
        StreamBuilder(
            stream: productsCollection.snapshots(),
            builder: (context, ps) => ps.hasError
                ? Center(child: Text('Error: ${ps.error}'))
                : ps.connectionState == ConnectionState.waiting
                    ? loadingWidget()
                    : ps.hasData
                        ? analyticWidget(
                            title: "Products", value: ps.data!.size.toString())
                        : const SizedBox()),
        //TOTAL CATEGORIES
        // StreamBuilder(
        //     stream: _services.categories.snapshots(),
        //     builder: (context, snapshot) => snapshot.hasError
        //         ? Center(child: Text('Error: ${snapshot.error}'))
        //         : snapshot.connectionState == ConnectionState.waiting
        //             ? loadingWidget(title: 'Categories')
        //             : snapshot.hasData
        //                 ? analyticWidget(
        //                     title: "Categories",
        //                     value: snapshot.data!.size.toString())
        //                 : const SizedBox()),
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
