import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/firebase_services.dart';
import 'package:marketdo_admin/model/orders_model.dart';

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
    Widget analyticWidget({required String title, required String value}) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 190,
          width: 270,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.black45,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Center(
                    child: FittedBox(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 15,
          runSpacing: 20,
          children: [
            //VENDORS TOTAL
            StreamBuilder<QuerySnapshot>(
              stream: _services.vendor.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                  );
                }
                if (snapshot.hasData) {
                  return analyticWidget(
                      title: "Vendor", value: snapshot.data!.size.toString());
                }
                return const SizedBox();
              },
            ),
            //CUSTOMERS TOTAL
            StreamBuilder<QuerySnapshot>(
              stream: _services.customer.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                  );
                }
                if (snapshot.hasData) {
                  return analyticWidget(
                      title: "Customers",
                      value: snapshot.data!.size.toString());
                }
                return const SizedBox();
              },
            ),
            //PRODUCTS TOTAL
            StreamBuilder<QuerySnapshot>(
              stream: _services.product.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                  );
                }
                if (snapshot.hasData) {
                  return analyticWidget(
                      title: "Products", value: snapshot.data!.size.toString());
                }
                return const SizedBox();
              },
            ),
            //TOTAL CATEGORIES
            StreamBuilder<QuerySnapshot>(
              stream: _services.categories.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                  );
                }
                if (snapshot.hasData) {
                  return analyticWidget(
                      title: "Categories",
                      value: snapshot.data!.size.toString());
                }
                return const SizedBox();
              },
            ),
            // TOP SALES
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                  );
                }
                if (snapshot.hasData) {
                  final orders = snapshot.data!.docs;
                  Map<String, int> vendorCountMap =
                      {}; // Map to store vendor name and occurrence count

                  for (var order in orders) {
                    final vendorName = order['vendorName'] as String;
                    vendorCountMap[vendorName] =
                        (vendorCountMap[vendorName] ?? 0) + 1;
                  }

                  // Find the vendor name with the maximum occurrence count
                  String mostOccurringVendor = '';
                  int maxOccurrences = 0;

                  for (var entry in vendorCountMap.entries) {
                    if (entry.value > maxOccurrences) {
                      maxOccurrences = entry.value;
                      mostOccurringVendor = entry.key;
                    }
                  }

                  return analyticWidget(
                      title: "Top Sales",
                      value:
                          '$mostOccurringVendor\n$maxOccurrences orders sold');
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ],
    );
  }
}
