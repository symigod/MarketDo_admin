import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';
import 'package:marketdo_admin/widgets/vendor_details.dart';

class VendorsList extends StatefulWidget {
  final bool? isApproved;
  const VendorsList({this.isApproved, Key? key}) : super(key: key);

  @override
  State<VendorsList> createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('vendor')
          .where('isApproved', isEqualTo: widget.isApproved)
          .snapshots(),
      builder: (context, vs) {
        if (vs.hasError) {
          return errorWidget(vs.error.toString());
        }
        if (vs.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (vs.data!.docs.isNotEmpty) {
          final List<DataRow> rows = vs.data!.docs.map((document) {
            final Map<String, dynamic> data = document.data();
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
                  child: Text(data['businessName'], softWrap: true))),
              DataCell(Text(data['mobile'], softWrap: true)),
              DataCell(Text(data['email'], softWrap: true)),
              DataCell(Text(data['address'], softWrap: true)),
              DataCell(Row(children: [
                data['isApproved'] == true
                    ? ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.green.shade900)),
                        child: const Icon(Icons.check, color: Colors.white),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('vendor')
                            .doc(data['vendorID'])
                            .update({'isApproved': false}).then((_) =>
                                Fluttertoast.showToast(
                                    msg:
                                        'Customer ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}',
                                    timeInSecForIosWeb: 3,
                                    webBgColor:
                                        '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ',
                                    webPosition: 'center')))
                    : ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red.shade900)),
                        child: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => FirebaseFirestore.instance.collection('vendor').doc(data['vendorID']).update({'isApproved': true}).then((_) => Fluttertoast.showToast(msg: 'Vendor ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}', webBgColor: '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ', webPosition: 'center'))),
                const SizedBox(width: 10),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.teal)),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) =>
                            VendorDetailsCard(vendorID: data['vendorID'])),
                    child: const Icon(Icons.visibility, color: Colors.white))
              ]))
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
                DataColumn(label: Text('LOGO')),
                DataColumn(label: Text('NAME')),
                DataColumn(label: Text('MOBILE')),
                DataColumn(label: Text('EMAIL')),
                DataColumn(label: Text('ADDRESS')),
                DataColumn(label: Text('ACTIONS'))
              ],
              rows: rows);
        }
        return emptyWidget('NO RECORD FOUND');
      });
}
