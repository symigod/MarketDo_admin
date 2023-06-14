import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/firebase.services.dart';

class CustomerScreen extends StatefulWidget {
  static const String id = 'customer-screen';
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  bool? selectedButton;

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REGISTERED CUSTOMERS',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  // Row(children: [
                  //   //APPROVED BUTTON
                  //   ElevatedButton(
                  //       style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(
                  //               selectedButton == true
                  //                   ? Theme.of(context).primaryColor
                  //                   : Colors.grey.shade500)),
                  //       onPressed: () => setState(() => selectedButton = true),
                  //       child: const Text('Approved')),
                  //   //REJECTED BUTTON
                  //   const SizedBox(width: 10),
                  //   ElevatedButton(
                  //       style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(
                  //               selectedButton == false
                  //                   ? Theme.of(context).primaryColor
                  //                   : Colors.grey.shade500)),
                  //       onPressed: () => setState(() => selectedButton = false),
                  //       child: const Text('Not Approved')),
                  //   //All BUTTON
                  //   const SizedBox(width: 10),
                  //   ElevatedButton(
                  //       style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(
                  //               selectedButton == null
                  //                   ? Theme.of(context).primaryColor
                  //                   : Colors.grey.shade500)),
                  //       onPressed: () => setState(() => selectedButton = null),
                  //       child: const Text('All'
                  //           ''))
                  // ])
                ]),
            const SizedBox(height: 10),
            CustomerList(isApproved: selectedButton)
          ]));
}

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

    customersCollection
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
      stream: customersCollection
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
            DataCell(Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: data['isOnline'] ? Colors.green : Colors.red,
                        width: 2)),
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            Image.network(data['logo'], fit: BoxFit.cover))))),
            DataCell(Align(
                alignment: Alignment.centerLeft,
                child: Text(data['name'], softWrap: true))),
            DataCell(Text(data['mobile'], softWrap: true)),
            DataCell(Text(data['email'], softWrap: true)),
            DataCell(Text(data['address'], softWrap: true)),
            DataCell(Text(data['address'], softWrap: true))
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
              DataColumn(label: Text('ACTION'))
              // DataColumn(
              //     label: Center(
              //         child: Text('STATUS', textAlign: TextAlign.center)))
            ],
            rows: rows);
      });
}
