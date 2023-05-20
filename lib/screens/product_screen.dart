import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/vendor_list.dart';

import '../widgets/customer_list.dart';
import '../widgets/product_list.dart';

class ProductScreen extends StatefulWidget {
  static const String id = 'product-screen';
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Registered Products',
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
              _rowHeader(flex: 2, text: 'PRODUCT NAME'),
              _rowHeader(flex: 2, text: 'BRAND'),
              _rowHeader(flex: 2, text: 'OTHER DETAILS'),
              _rowHeader(flex: 2, text: 'DESCRIPTION'),
              _rowHeader(flex: 2, text: 'UNIT'),
           
            ],
          ),
          ProductList(
            ApproveStatus: selectedButton,
          )
        ],
      ),
    );
  }
}
