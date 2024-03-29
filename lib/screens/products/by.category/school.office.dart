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
              DataCell(Container(
                  alignment: Alignment.center,
                  child: Wrap(children: [
                    SizedBox(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(data['imageURL'],
                                fit: BoxFit.cover)))
                  ]))),
              DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data['productName'], softWrap: true))),
              DataCell(Text(data['subcategory'], softWrap: true)),
              DataCell(Text(
                  'P ${numberToString(data['regularPrice'].toDouble())} per ${data['unit']}',
                  softWrap: true)),
              DataCell(Center(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.teal)),
                      onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              ProductDetails(productID: data['productID'])),
                      child:
                          const Icon(Icons.visibility, color: Colors.white))))
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
              rows: rows,
              columns: [
                dataColumn('IMAGE'),
                dataColumn('PRODUCT'),
                dataColumn('SUBCATEGORY'),
                dataColumn('PRICE'),
                dataColumn('ACTION')
              ]);
        }
        return emptyWidget('NO RECORD FOUND');
      });
}
