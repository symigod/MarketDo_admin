import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/models/product.model.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';

class VendorProducts extends StatefulWidget {
  final String vendorID;
  const VendorProducts({super.key, required this.vendorID});

  @override
  State<VendorProducts> createState() => _VendorProductsState();
}

class _VendorProductsState extends State<VendorProducts> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('vendorID', isEqualTo: widget.vendorID)
          .snapshots(),
      builder: (context, vps) {
        if (vps.hasError) {
          return errorWidget(vps.error.toString());
        }
        if (vps.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (vps.hasData) {
          return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('vendors')
                      .where('vendorID', isEqualTo: widget.vendorID)
                      .get(),
                  builder: (context, vs) {
                    if (vs.hasError) {
                      return errorWidget(vs.error.toString());
                    }
                    if (vs.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (vs.data!.docs.isNotEmpty) {
                      return Card(
                          color: Colors.green,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      'Products of\n${vs.data!.docs[0]['businessName']}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center))));
                    } else {
                      return emptyWidget('VENDOR NOT FOUND');
                    }
                  }),
              content: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7),
                  itemCount: vps.data!.docs.length,
                  itemBuilder: (context, index) {
                    List<ProductModel> productModel = vps.data!.docs
                        .map((doc) => ProductModel.fromFirestore(doc))
                        .toList();
                    var product = productModel[index];
                    return InkWell(
                        // onTap: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ProductDetailScreen(
                        //             productID: product.productID))),
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            height: 80,
                            width: 80,
                            child: Column(children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                      height: 90,
                                      width: 90,
                                      child: CachedNetworkImage(
                                          imageUrl: product.imageURL,
                                          fit: BoxFit.cover))),
                              const SizedBox(height: 10),
                              Text(product.productName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 2)
                            ])));
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Padding(
                        padding: EdgeInsets.all(10), child: Text('Close')))
              ]);
        }
        return emptyWidget('NO PRODUCTS FOUND');
      });
}
