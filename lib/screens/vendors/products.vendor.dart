import 'package:flutter/material.dart';
import 'package:marketdo_admin/models/product.model.dart';
import 'package:marketdo_admin/screens/products/product.details.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class VendorProducts extends StatefulWidget {
  final String vendorID;
  const VendorProducts({super.key, required this.vendorID});

  @override
  State<VendorProducts> createState() => _VendorProductsState();
}

class _VendorProductsState extends State<VendorProducts> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: productsCollection
          .where('vendorID', isEqualTo: widget.vendorID)
          .orderBy('productName')
          .snapshots(),
      builder: (context, vps) {
        if (vps.hasError) {
          print(vps.error.toString());
          return errorWidget(vps.error.toString());
        }
        if (vps.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (vps.hasData) {
          return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: FutureBuilder(
                  future: vendorsCollection
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7),
                      itemCount: vps.data!.docs.length,
                      itemBuilder: (context, index) {
                        List<ProductModel> productModel = vps.data!.docs
                            .map((doc) => ProductModel.fromFirestore(doc))
                            .toList();
                        var product = productModel[index];
                        return Card(
                            child: InkWell(
                                onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => ProductDetails(
                                        productID: product.productID)),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        // gradient: LinearGradient(
                                        //     begin: Alignment.topCenter,
                                        //     end: Alignment.bottomCenter,
                                        //     colors: [
                                        //       Colors.transparent,
                                        //       Colors.black.withOpacity(0.7)
                                        //     ]),
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(product.imageURL),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.3),
                                                BlendMode.darken))),
                                    child: Center(
                                        child: Text(product.productName,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center)))));
                      })),
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
