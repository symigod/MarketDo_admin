import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/firebase_services.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = 'Dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _services = FirebaseService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late List<CustomerVendorData> customerVendorData = [];
  late int customers = 0;
  late int vendors = 0;

  Future<void> getCustomersAndVendors() async {
    final CollectionReference customersCollection =
        firestore.collection('customers');
    final CollectionReference vendorsCollection =
        firestore.collection('vendors');
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

  // Future<void> getProducts() async {
  //   final CollectionReference productsCollection =
  //       firestore.collection('products');
  //   final CollectionReference categoriesCollection =
  //       firestore.collection('categories');
  //   final products = await productsCollection.get();
  //   final categories = await categoriesCollection.get();
  //   final int customersLength = products.docs.length;
  //   final int vendorsLength = categories.docs.length;
  //   if (mounted) {
  //     setState(() => productsData = [
  //           CustomerVendorData('Customers', customersLength),
  //           CustomerVendorData('Vendors', vendorsLength)
  //         ]);
  //   }
  // }

  @override
  void initState() {
    getCustomersAndVendors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(spacing: 15, runSpacing: 20, children: [
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
            stream: _services.product.snapshots(),
            builder: (context, snapshot) => snapshot.hasError
                ? Center(child: Text('Error: ${snapshot.error}'))
                : snapshot.connectionState == ConnectionState.waiting
                    ? loadingWidget()
                    : snapshot.hasData
                        ? analyticWidget(
                            title: "Products",
                            value: snapshot.data!.size.toString())
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
        // TOP SALES
        StreamBuilder(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
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
                for (var order in orders) {
                  final vendorName = order['vendorID'] as String;
                  vendorCountMap[vendorName] =
                      (vendorCountMap[vendorName] ?? 0) + 1;
                }
                String mostOccurringVendor = '';
                int maxOccurrences = 0;
                for (var entry in vendorCountMap.entries) {
                  if (entry.value > maxOccurrences) {
                    maxOccurrences = entry.value;
                    mostOccurringVendor = entry.key;
                  }
                }
                return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('vendors')
                        .where('vendorID', isEqualTo: mostOccurringVendor)
                        .get(),
                    builder: (context, vs) {
                      if (vs.connectionState == ConnectionState.waiting) {
                        return loadingWidget();
                      }
                      if (vs.hasData) {
                        return analyticWidget(
                            title: "Top Sellers",
                            value:
                                '${vs.data!.docs[0]['businessName']}\n$maxOccurrences orders sold');
                      }
                      return emptyWidget('VENDOR NOT FOUND');
                    });
              }
              return const SizedBox();
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

  // Widget loadingWidget({required String title}) => Padding(
  //     padding: const EdgeInsets.only(top: 20),
  //     child: SizedBox(
  //         height: 200,
  //         width: 275,
  //         child: Card(
  //             color: Colors.black45,
  //             child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Column(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Padding(
  //                             padding: const EdgeInsets.only(top: 10),
  //                             child: Text(title,
  //                                 style: const TextStyle(
  //                                     fontSize: 20,
  //                                     color: Colors.white,
  //                                     fontWeight: FontWeight.bold))),
  //                         const Divider(color: Colors.white)
  //                       ]),
  //                   const Center(
  //                       child: CircularProgressIndicator(color: Colors.white)),
  //                   Container()
  //                 ]))));
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
