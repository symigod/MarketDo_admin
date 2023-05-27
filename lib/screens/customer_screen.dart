import 'package:flutter/material.dart';
import '../widgets/customer_list.dart';

class CustomerScreen extends StatefulWidget {
  static const String id = 'customer-screen';
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  

  Widget _rowHeader({int? flex,String? text}){
      return Expanded(flex: flex!,child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
          color: Colors.grey.shade400
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text!, style: const TextStyle(fontWeight: FontWeight.bold),),
        ),
      ));
    }

    bool? selectedButton;

  @override
  Widget build(BuildContext context) {
    
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered Customers',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10,),
          Row(
            children: [
              _rowHeader(flex: 1, text: 'IMAGE'),
              _rowHeader(flex: 3, text: 'FULL NAME'),
              _rowHeader(flex: 2, text: 'MOBILE'),
              _rowHeader(flex: 2, text: 'EMAIL'),
              _rowHeader(flex: 2, text: 'ADDRESS'),
              _rowHeader(flex: 2, text: 'LANDMARK'),
              _rowHeader(flex: 2, text: 'STATUS'),
              
            ],
          ),
          CustomerList(
            ApproveStatus: selectedButton,
          )
        ],
      ),
    );
  }
}
