import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/customer_list.dart';

class CustomerScreen extends StatefulWidget {
  static const String id = 'customer-screen';
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
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
            // Row(children: [
            //   _rowHeader(flex: 1, text: 'IMAGE'),
            //   _rowHeader(flex: 2, text: 'FULL NAME'),
            //   _rowHeader(flex: 2, text: 'MOBILE'),
            //   _rowHeader(flex: 3, text: 'EMAIL'),
            //   _rowHeader(flex: 2, text: 'ADDRESS'),
            //   _rowHeader(flex: 2, text: 'LANDMARK'),
            //   _rowHeader(flex: 2, text: 'STATUS')
            // ]),
            CustomerList(isApproved: selectedButton)
          ]));
}
