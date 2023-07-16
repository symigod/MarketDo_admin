import 'package:flutter/material.dart';
import 'package:marketdo_admin/screens/products/product.details.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class SchoolAndOfficeSupplies extends StatefulWidget {
  const SchoolAndOfficeSupplies({Key? key}) : super(key: key);

  @override
  State<SchoolAndOfficeSupplies> createState() =>
      _SchoolAndOfficeSuppliesState();
}

class _SchoolAndOfficeSuppliesState extends State<SchoolAndOfficeSupplies> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: productsCollection
          .orderBy('productName')
          .where('category', isEqualTo: 'School and Office Supplies')
          .snapshots(),
      builder: (context, ps) {
        if (ps.hasError) {
          return errorWidget(ps.error.toString());
        }
        if (ps.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (ps.data!.docs.isNotEmpty) {
          final List<DataRow> rows = ps.data!.docs.map((document) {
            final Map<String, dynamic> data = document.data();
            return DataRow(cells: [
              DataCell(Wrap(children: [
                SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            Image.network(data['imageURL'], fit: BoxFit.cover)))
              ])),
              DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data['productName'], softWrap: true))),
              DataCell(Text(data['category'], softWrap: true)),
              // DataCell(Text(data['description'], softWrap: true)),
              DataCell(Text(
                  'P ${numberToString(data['regularPrice'].toDouble())} per ${data['unit']}',
                  softWrap: true)),
              // DataCell(FutureBuilder(
              //     future: vendorsCollection
              //         .where('vendorID', isEqualTo: data['vendorID'])
              //         .get(),
              //     builder: (context, vs) {
              //       if (vs.hasError) {
              //         return errorWidget(vs.error.toString());
              //       }
              //       if (vs.connectionState == ConnectionState.waiting) {
              //         return loadingWidget();
              //       }
              //       if (vs.hasData) {
              //         return Text(vs.data!.docs[0]['businessName'],
              //             softWrap: true);
              //       }
              //       return emptyWidget('VENDOR NOT FOUND');
              //     })),
              DataCell(ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal)),
                  onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          ProductDetails(productID: data['productID'])),
                  child: const Icon(Icons.visibility, color: Colors.white)))
              // DataCell(data['isApproved'] == true
              //     ? ElevatedButton(
              //         style: ButtonStyle(
              //             backgroundColor:
              //                 MaterialStateProperty.all(Colors.green.shade900)),
              //         child: const FittedBox(
              //             child: Text('APPROVED',
              //                 style: TextStyle(color: Colors.white))),
              //         onPressed: () {
              // productsCollection
              //               .doc(data['productID'])
              //               .update({
              //             'isApproved': false
              //           }).then((_) => Fluttertoast.showToast(
              //                   msg:
              //                       'Product ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}',
              //                   timeInSecForIosWeb: 3,
              //                   webBgColor:
              //                       '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ',
              //                   webPosition: 'center'));
              //         })
              //     : ElevatedButton(
              //         style: ButtonStyle(
              //             backgroundColor:
              //                 MaterialStateProperty.all(Colors.red.shade900)),
              //         child: const FittedBox(
              //             child: Text('UNAPPROVED',
              //                 style: TextStyle(color: Colors.white))),
              //         onPressed: () {
              //  productsCollection
              //               .doc(data['productID'])
              //               .update({
              //             'isApproved': true
              //           }).then((_) => Fluttertoast.showToast(
              //                   msg:
              //                       'Product ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}',
              //                   timeInSecForIosWeb: 3,
              //                   webBgColor:
              //                       '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ',
              //                   webPosition: 'center'));
              //         })),
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
                DataColumn(label: Text('IMAGE')),
                DataColumn(label: Text('PRODUCT')),
                DataColumn(label: Text('CATEGORY')),
                // DataColumn(label: Text('DESCRIPTION')),
                DataColumn(label: Text('PRICE')),
                // DataColumn(label: Text('VENDOR')),
                DataColumn(label: Text('ACTION'))
              ],
              rows: rows);
        }
        return emptyWidget('NO RECORD FOUND');
      });
}
