import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/firebase_services.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = 'Dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _services = FirebaseService();

  @override
  Widget build(BuildContext context) {
    Widget analyticWidget({required String title, required String value}) =>
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
                height: 200,
                width: 275,
                child: Card(
                    color: Colors.black45,
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
                                          fontSize: 18, color: Colors.white)))),
                          Container()
                        ]))));

    Widget loadingWidget({required String title}) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
            height: 200,
            width: 275,
            child: Card(
                color: Colors.black45,
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
                      const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)),
                      Container()
                    ]))));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 15, runSpacing: 20, children: [
        //VENDORS TOTAL
        StreamBuilder(
            stream: _services.vendor.snapshots(),
            builder: (context, snapshot) => snapshot.hasError
                ? Center(child: Text('Error: ${snapshot.error}'))
                : snapshot.connectionState == ConnectionState.waiting
                    ? loadingWidget(title: 'Vendors')
                    : snapshot.hasData
                        ? analyticWidget(
                            title: "Vendors",
                            value: snapshot.data!.size.toString())
                        : const SizedBox()),
        //CUSTOMERS TOTAL
        StreamBuilder(
            stream: _services.customer.snapshots(),
            builder: (context, snapshot) => snapshot.hasError
                ? Center(child: Text('Error: ${snapshot.error}'))
                : snapshot.connectionState == ConnectionState.waiting
                    ? loadingWidget(title: 'Customers')
                    : snapshot.hasData
                        ? analyticWidget(
                            title: "Customers",
                            value: snapshot.data!.size.toString())
                        : const SizedBox()),
        //PRODUCTS TOTAL
        StreamBuilder(
            stream: _services.product.snapshots(),
            builder: (context, snapshot) => snapshot.hasError
                ? Center(child: Text('Error: ${snapshot.error}'))
                : snapshot.connectionState == ConnectionState.waiting
                    ? loadingWidget(title: 'Products')
                    : snapshot.hasData
                        ? analyticWidget(
                            title: "Products",
                            value: snapshot.data!.size.toString())
                        : const SizedBox()),
        //TOTAL CATEGORIES
        StreamBuilder(
            stream: _services.categories.snapshots(),
            builder: (context, snapshot) => snapshot.hasError
                ? Center(child: Text('Error: ${snapshot.error}'))
                : snapshot.connectionState == ConnectionState.waiting
                    ? loadingWidget(title: 'Categories')
                    : snapshot.hasData
                        ? analyticWidget(
                            title: "Categories",
                            value: snapshot.data!.size.toString())
                        : const SizedBox()),
        // TOP SALES
        // StreamBuilder(
        //     stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasError) {
        //         return const Text('Something went wrong');
        //       }
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return loadingWidget(title: 'Top Sales');
        //       }
        //       if (snapshot.hasData) {
        //         final orders = snapshot.data!.docs;
        //         Map<String, int> vendorCountMap = {};
        //         for (var order in orders) {
        //           final vendorName = order['vendorName'] as String;
        //           vendorCountMap[vendorName] =
        //               (vendorCountMap[vendorName] ?? 0) + 1;
        //         }
        //         String mostOccurringVendor = '';
        //         int maxOccurrences = 0;
        //         for (var entry in vendorCountMap.entries) {
        //           if (entry.value > maxOccurrences) {
        //             maxOccurrences = entry.value;
        //             mostOccurringVendor = entry.key;
        //           }
        //         }
        //         return analyticWidget(
        //             title: "Top Sales",
        //             value: '$mostOccurringVendor\n$maxOccurrences orders sold');
        //       }
        //       return const SizedBox();
        //     })
      ])
    ]);
  }
}
