import 'package:flutter/material.dart';
import 'package:marketdo_admin/screens/products/product.details.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class ProductList extends StatefulWidget {
  // final bool? isApproved;
  const ProductList({/* this.isApproved, */ Key? key}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: productsCollection
          .orderBy('productName')
          // .where('isApproved', isEqualTo: widget.isApproved)
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
              // DataCell(Text(data['brand'], softWrap: true)),
              DataCell(Text(data['category'], softWrap: true)),
              DataCell(Text(data['description'], softWrap: true)),
              DataCell(Text(
                  'P ${data['regularPrice'].toStringAsFixed(2)} per ${data['unit']}',
                  softWrap: true)),
              DataCell(FutureBuilder(
                  future: vendorsCollection
                      .where('vendorID', isEqualTo: data['vendorID'])
                      .get(),
                  builder: (context, vs) {
                    if (vs.hasError) {
                      return errorWidget(vs.error.toString());
                    }
                    if (vs.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (vs.hasData) {
                      return Text(vs.data!.docs[0]['businessName'],
                          softWrap: true);
                    }
                    return emptyWidget('VENDOR NOT FOUND');
                  })),
              DataCell(ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal)),
                  onPressed: () => showDialog(
                      context: context,
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
                DataColumn(label: Text('IMAGES')),
                DataColumn(label: Text('PRODUCT NAME')),
                // DataColumn(label: Text('BRAND')),
                DataColumn(label: Text('CATEGORY')),
                DataColumn(label: Text('DESCRIPTION')),
                DataColumn(label: Text('PRICE')),
                DataColumn(label: Text('VENDOR')),
                DataColumn(label: Text('ACTION'))
                // DataColumn(label: Text('STATUS'))
              ],
              rows: rows);
        }
        return emptyWidget('NO RECORD FOUND');
      });

  Widget _productData({int? flex, String? text, Widget? widget}) => Expanded(
      flex: flex!,
      child: Container(
          height: 66,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget ?? Text(text!))));
}
