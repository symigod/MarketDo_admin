import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/models/product.model.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';

class ProductDetails extends StatefulWidget {
  final String productID;
  const ProductDetails({super.key, required this.productID});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('productID', isEqualTo: widget.productID)
          .snapshots(),
      builder: (context, ps) {
        if (ps.hasError) {
          return errorWidget(ps.error.toString());
        }
        if (ps.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (ps.hasData) {
          List<ProductModel> productModel = ps.data!.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
          var product = productModel[0];
          return AlertDialog(
              scrollable: true,
              title: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.height / 2,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: CachedNetworkImage(imageUrl: product.imageURL))),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(children: [
                    ListTile(
                        leading: const Icon(Icons.info),
                        title: Text(product.productName),
                        subtitle: Text(product.description)),
                    const Divider(height: 0, thickness: 1),
                    ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(product.category),
                        subtitle: Text(product.subcategory),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 5),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('favorites')
                                  .where('productID',
                                      isEqualTo: product.productID)
                                  .snapshots(),
                              builder: (context, fs) {
                                const count = Text('0',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold));
                                if (fs.hasError) {
                                  errorWidget(fs.error.toString());
                                }
                                if (fs.connectionState ==
                                    ConnectionState.waiting) {
                                  return count;
                                }
                                if (fs.hasData) {
                                  return Text(fs.data!.docs.length.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold));
                                }
                                return count;
                              })
                        ])),
                    const Divider(height: 0, thickness: 1),
                    ListTile(
                        leading: const Icon(Icons.payments),
                        title: Text('Regular Price (per ${product.unit})'),
                        trailing: Text(
                            'P ${product.regularPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold))),
                    const Divider(height: 0, thickness: 1),
                    ListTile(
                        leading: const Icon(Icons.delivery_dining),
                        title: const Text('Delivery Fee'),
                        trailing: Text(
                            'P ${product.shippingCharge.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 100)
                  ])),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                        padding: EdgeInsets.all(10), child: Text('Close')))
              ]);
        }
        return emptyWidget('PRODUCT NOT FOUND');
      });
}
