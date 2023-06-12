import 'package:flutter/material.dart';
import 'package:marketdo_admin/screens/products/products.list.dart';

class ProductScreen extends StatefulWidget {
  static const String id = 'product-screen';
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Widget _rowHeader({int? flex, String? text}) => Expanded(
      flex: flex!,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
              color: Colors.grey.shade400),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text!,
                  style: const TextStyle(fontWeight: FontWeight.bold)))));

  bool? selectedButton;

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('REGISTERED PRODUCTS',
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
            SizedBox(height: 10),
            // Row(children: [
            //   _rowHeader(flex: 2, text: 'PRODUCT NAME'),
            //   _rowHeader(flex: 2, text: 'BRAND'),
            //   _rowHeader(flex: 2, text: 'OTHER DETAILS'),
            //   _rowHeader(flex: 2, text: 'DESCRIPTION'),
            //   _rowHeader(flex: 2, text: 'UNIT')
            // ]),
            ProductList(/* isApproved: selectedButton */)
          ]));
}
