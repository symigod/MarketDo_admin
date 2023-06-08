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
}
