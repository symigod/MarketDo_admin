import 'package:flutter/material.dart';
import 'package:marketdo_admin/screens/vendors/table.vendors.dart';

class VendorScreen extends StatefulWidget {
  static const String id = 'vendors-screen';
  const VendorScreen({Key? key}) : super(key: key);

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  bool? selectedButton;

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('REGISTERED VENDORS',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                //APPROVED BUTTON
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == true
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () => setState(() => selectedButton = true),
                    child: const Text('Approved')),
                //REJECTED BUTTON
                const SizedBox(width: 10),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == false
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () => setState(() => selectedButton = false),
                    child: const Text('Not Approved')),
                //All BUTTON
                const SizedBox(width: 10),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedButton == null
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade500)),
                    onPressed: () => setState(() => selectedButton = null),
                    child: const Text('All'
                        ''))
              ])
            ]),
            const SizedBox(height: 10),
            VendorsTable(isApproved: selectedButton)
          ]));
}
