import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/stream_widgets.dart';
import 'package:marketdo_admin/widgets/vendor_details.dart';

class VendorsList extends StatelessWidget {
  final bool? ApproveStatus;
  const VendorsList({this.ApproveStatus, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _vendorData({int? flex, String? text, Widget? widget}) => Expanded(
        flex: flex!,
        child: Container(
            height: 66,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget ?? Text(text!))));

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('vendor')
            .where('isApproved', isEqualTo: ApproveStatus)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return streamErrorWidget(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return streamLoadingWidget();
          }
          if (snapshot.data!.docs.isNotEmpty) {
            final List<DocumentSnapshot> vendor = snapshot.data!.docs;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: vendor.length,
                itemBuilder: (context, index) {
                  return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _vendorData(
                            flex: 1,
                            widget: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(vendor[index]['logo']))),
                        _vendorData(
                            flex: 3, text: vendor[index]['businessName']),
                        _vendorData(flex: 2, text: vendor[index]['city']),
                        _vendorData(flex: 2, text: vendor[index]['state']),
                        _vendorData(
                            flex: 1,
                            widget: vendor[index]['isApproved'] == true
                                ? ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: const FittedBox(
                                        child: Text('Reject',
                                            style: TextStyle(
                                                color: Colors.white))),
                                    onPressed: () {
                                      EasyLoading.show();
                                      FirebaseFirestore.instance
                                          .collection('vendor')
                                          .doc(vendor[index]['vendorID'])
                                          .update({'isApproved': false})
                                          .then((_) => EasyLoading.dismiss())
                                          .catchError((error) => EasyLoading
                                                  .dismiss()
                                              .then((value) => showDialog(
                                                  context: context,
                                                  builder: (_) => successDialog(
                                                      context,
                                                      error.toString()))));
                                    })
                                : ElevatedButton(
                                    child: const FittedBox(
                                        child: Text('Approve',
                                            style: TextStyle(
                                                color: Colors.white))),
                                    onPressed: () {
                                      EasyLoading.show();
                                      FirebaseFirestore.instance
                                          .collection('vendor')
                                          .doc(vendor[index]['vendorID'])
                                          .update({'isApproved': true})
                                          .then((_) => EasyLoading.dismiss())
                                          .catchError((error) => EasyLoading
                                                  .dismiss()
                                              .then((value) => showDialog(
                                                  context: context,
                                                  builder: (_) => successDialog(
                                                      context,
                                                      error.toString()))));
                                    })),
                        _vendorData(
                            flex: 1,
                            widget: ElevatedButton(
                                child: const Text('View More',
                                    textAlign: TextAlign.center),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return VendorDetailsCard(
                                          vendorID: vendor[index]['vendorID']);
                                    })))
                      ]);
                });
          }
          return streamEmptyWidget('NO RECORD FOUND');
        });
  }
}
