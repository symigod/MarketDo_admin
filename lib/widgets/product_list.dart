import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/firebase_services.dart';
import '../model/product_model.dart';

class ProductList extends StatelessWidget {
final bool? ApproveStatus;
  const ProductList({this.ApproveStatus, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseService _service = FirebaseService();

    Widget _productData({int? flex,String? text, Widget? widget}){
      return Expanded(
        flex: flex!,
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget ?? Text(text!),
          ),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
        stream: _service.product.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
    {
      if (snapshot.hasError) {
        return const Center(child: Text('Something went wrong'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LinearProgressIndicator();
      }

      if(snapshot.data!.size==0){
        return const Center(
          child: Text('No Products to show', style: TextStyle(fontSize: 22),),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index){
            Product product = Product.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
            return  Row(
              crossAxisAlignment:CrossAxisAlignment.end,
              children: [
                _productData(
                  flex: 2,
                  text: product.productName
                ),
                _productData(
                    flex: 2,
                    text: product.brand
                ),
                 _productData(
                    flex: 2,
                    text: product.otherDetails
                ),
                _productData(
                    flex: 2,
                    text: product.description
                ),
                _productData(
                    flex: 2,
                    text: product.unit
                ),
              ],
            );
          });
    });
  }
}
