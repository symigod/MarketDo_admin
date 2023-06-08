import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';

class CustomerList extends StatefulWidget {
  final bool? isApproved;

  const CustomerList({this.isApproved, Key? key}) : super(key: key);

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  List<String> blockedCustomers = [];

  void _blockCustomer(String customerID, bool isApproved) {
    bool newApprovedStatus;
    isApproved == true ? newApprovedStatus = false : newApprovedStatus = true;

    FirebaseFirestore.instance
        .collection('customers')
        .doc(customerID)
        .update({'isApproved': newApprovedStatus}).then((value) {
      Fluttertoast.showToast(
          msg:
              'Customer ${newApprovedStatus == true ? 'approved!' : 'unapproved!'}',
          timeInSecForIosWeb: 3,
          webBgColor:
              '${newApprovedStatus == true ? 'rgb(27, 94, 32)' : 'rgb(183, 28, 28)'} ',
          webPosition: 'center');
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => showDialog(
            context: context,
            builder: (_) => errorDialog(context, e.toString())));
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('isApproved', isEqualTo: widget.isApproved)
          .snapshots(),
      builder: (context, cs) {
        if (cs.hasError) {
          return errorWidget(cs.error.toString());
        }
        if (cs.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        final List<DataRow> rows =
            cs.data!.docs.map((QueryDocumentSnapshot document) {
          final Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
          return DataRow(cells: [
            DataCell(Wrap(children: [
              SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(data['logo'], fit: BoxFit.cover)))
            ])),
            DataCell(Align(
                alignment: Alignment.centerLeft,
                child: Text(data['name'], softWrap: true))),
            DataCell(Text(data['mobile'], softWrap: true)),
            DataCell(Text(data['email'], softWrap: true)),
            DataCell(Text(data['address'], softWrap: true)),
            DataCell(Text(data['landMark'], softWrap: true)),
            // DataCell(Center(
            //     child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //             backgroundColor: data['isApproved'] == true
            //                 ? Colors.green.shade900
            //                 : Colors.red.shade900),
            //         onPressed: () =>
            //             _blockCustomer(data['customerID'], data['isApproved']),
            //         child: Text(data['isApproved'] == false
            //             ? 'UNAPPROVED'
            //             : 'APPROVED'))))
          ]);
        }).toList();
        return DataTable(
            border: TableBorder.all(width: 0.5),
            headingRowColor:
                MaterialStateProperty.resolveWith((states) => Colors.green),
            headingTextStyle: const TextStyle(
                color: Colors.white,
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold),
            columns: const [
              DataColumn(label: Text('IMAGE', textAlign: TextAlign.center)),
              DataColumn(label: Text('NAME')),
              DataColumn(label: Text('MOBILE')),
              DataColumn(label: Text('EMAIL')),
              DataColumn(label: Text('ADDRESS')),
              DataColumn(label: Text('LANDMARK')),
              // DataColumn(
              //     label: Center(
              //         child: Text('STATUS', textAlign: TextAlign.center)))
            ],
            rows: rows);
      });

  Widget _customerData({int? flex, String? text, Widget? widget}) => Expanded(
      flex: flex!,
      child: Container(
          height: 70,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget ?? Text(text!))));
}

// class CustomerList extends StatefulWidget {
//   final bool? isApproved;

//   const CustomerList({this.isApproved, Key? key}) : super(key: key);

//   @override
//   State<CustomerList> createState() => _CustomerListState();
// }

// class _CustomerListState extends State<CustomerList> {
//   late final Customer? customer;
//   Set<String> blockedCustomers = {}; // Set to store the IDs of blocked customers

//   void _blockCustomer(String customerId) {
//     setState(() {
//       if (blockedCustomers.contains(customerId)) {
//         blockedCustomers.remove(customerId); // Unblock customer
//       } else {
//         blockedCustomers.add(customerId); // Block customer
//       }
//     });

//     // Update the status of the customer with the given ID
//     String newStatus = blockedCustomers.contains(customerId) ? 'blocked' : 'active';

//     // First, get a reference to the customers collection in Firestore
//     CollectionReference customersCollection =
//         FirebaseFirestore.instance.collection('customer');

//     customersCollection
//         .doc(customerId)
//         .update({'status': newStatus})
//         .then((value) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Customer ${blockedCustomers.contains(customerId) ? "Blocked" : "Unblocked"}'),
//             content: Text('The registered customer is successfully ${blockedCustomers.contains(customerId) ? "blocked" : "unblocked"}.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }).catchError((error) => print('Failed to update customer status: $error'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     FirebaseService _service = FirebaseService();

//     Widget _customerData({int? flex, String? text, Widget? widget}) {
//       return Expanded(
//         flex: flex!,
//         child: Container(
//           height: 66,
//           decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400)),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: widget ?? Text(text!),
//           ),
//         ),
//       );
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: _service.customer.snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const LinearProgressIndicator();
//         }

//         if (snapshot.data!.size == 0) {
//           return const Center(
//             child: Text(
//               'No Customers to show',
//               style: TextStyle(fontSize: 22),
//             ),
//           );
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           itemCount: snapshot.data!.size,
//           itemBuilder: (context, index) {
//             Customer customer = Customer.fromJson(
//                 snapshot.data!.docs[index].data() as Map<String, dynamic>);
//             bool isBlocked = blockedCustomers.contains(customer.uid!);
//             return Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _customerData(
//                   flex: 1,
//                   widget: SizedBox(
//                     height: 50,
//                     width: 50,
//                     child: Image.network(customer.logo!),
//                   ),
//                 ),
//                 _customerData(flex: 3, text: customer.customerName),
//                 _customerData(flex: 2, text: customer.mobile),
//                 _customerData(flex: 2, text: customer.email),
//                 _customerData(flex: 2, text: customer.address),
//                 _customerData(flex: 2, text: customer.landMark),
//                 Expanded(
//                   flex: 2,
//                   child: TextButton(
//                     onPressed: () => _blockCustomer(customer.uid!),
//                     child: Text(isBlocked ? 'Unblock' : 'Block'), // Toggle the text
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class Customer {
//   final String? uid;
//   final String? logo;
//   final String? customerName;
//   final String? mobile;
//   final String? email;
//   final String? address;
//   final String? landMark;

//   Customer({
//     this.uid,
//     this.logo,
//     this.customerName,
//     this.mobile,
//     this.email,
//     this.address,
//     this.landMark,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       uid: json['uid'] as String?,
//       logo: json['logo'] as String?,
//       customerName: json['customerName'] as String?,
//       mobile: json['mobile'] as String?,
//       email: json['email'] as String?,
//       address: json['address'] as String?,
//       landMark: json['landMark'] as String?,
//     );
//   }
// }

// class FirebaseService {
//   final CollectionReference customer =
//       FirebaseFirestore.instance.collection('customer');
// }
