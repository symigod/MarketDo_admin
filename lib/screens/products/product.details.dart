import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/models/product.model.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class ProductDetails extends StatefulWidget {
  final String productID;
  const ProductDetails({super.key, required this.productID});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) => Center(
      child: SingleChildScrollView(
          child: StreamBuilder(
              stream: productsCollection
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
                      titlePadding: EdgeInsets.zero,
                      title: Card(
                          color: Colors.green,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          child: ListTile(
                            title: const Text('Product Details',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            trailing: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(Icons.close,
                                    color: Colors.white)),
                          )),
                      contentPadding: EdgeInsets.zero,
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                    imageUrl: product.imageURL)),
                            ListTile(
                                leading: const Icon(Icons.info),
                                title: Text(product.productName),
                                subtitle: Text(product.description),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.favorite,
                                          color: Colors.red),
                                      const SizedBox(width: 5),
                                      StreamBuilder(
                                          stream: favoritesCollection
                                              .where('productIDs',
                                                  arrayContains:
                                                      product.productID)
                                              .snapshots(),
                                          builder: (context, fs) {
                                            const count = Text('0',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold));
                                            if (fs.hasError) {
                                              errorWidget(fs.error.toString());
                                            }
                                            if (fs.connectionState ==
                                                ConnectionState.waiting) {
                                              return count;
                                            }
                                            if (fs.hasData) {
                                              return Text(
                                                  fs.data!.docs.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                            }
                                            return count;
                                          })
                                    ])),
                            const Divider(height: 0, thickness: 1),
                            ListTile(
                                leading: const Icon(Icons.category),
                                title: Text(product.category),
                                subtitle: Text(product.subcategory),
                                trailing: categoryIcon(product.category)),
                            const Divider(height: 0, thickness: 1),
                            ListTile(
                                leading: const Icon(Icons.payments),
                                title:
                                    Text('Regular Price (per ${product.unit})'),
                                trailing: Text(
                                    'P ${numberToString(product.regularPrice.toDouble())}',
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
                            const Divider(height: 0, thickness: 1),
                            StreamBuilder(
                                stream: vendorsCollection
                                    .where('vendorID',
                                        isEqualTo: product.vendorID)
                                    .snapshots(),
                                builder: (context, vs) {
                                  if (vs.hasError) {
                                    return errorWidget(vs.error.toString());
                                  }
                                  if (vs.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }
                                  if (vs.hasData) {
                                    return ListTile(
                                        leading: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: vs.data!.docs[0]['isOnline']
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    width: 2)),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2)),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: CachedNetworkImage(
                                                        imageUrl: vs.data!.docs[0]
                                                            ['logo'],
                                                        fit: BoxFit.cover)))),
                                        title: Text(vs.data!.docs[0]['businessName']),
                                        trailing: TextButton(onPressed: () => viewVendorDetails(context, product.vendorID), child: const Text('View Details')));
                                  }
                                  return emptyWidget('VENDOR NOT FOUND');
                                })
                          ])));
                }
                return emptyWidget('PRODUCT NOT FOUND');
              })));

  viewVendorDetails(context, String vendorID) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StreamBuilder(
          stream: vendorsCollection
              .where('vendorID', isEqualTo: vendorID)
              .snapshots(),
          builder: (context, vs) {
            if (vs.hasError) {
              return errorWidget(vs.error.toString());
            }
            if (vs.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            }
            if (vs.data!.docs.isNotEmpty) {
              var vendor = vs.data!.docs[0];
              return AlertDialog(
                  scrollable: true,
                  titlePadding: EdgeInsets.zero,
                  title: Card(
                      color: Colors.green,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))),
                      child: ListTile(
                          title: const Text('Vendor Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          trailing: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close,
                                  color: Colors.white)))),
                  contentPadding: EdgeInsets.zero,
                  content: SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Column(children: [
                        SizedBox(
                            height: 150,
                            child: DrawerHeader(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(20),
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(3),
                                                      topRight:
                                                          Radius.circular(3)),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      vendor['shopImage']),
                                                  fit: BoxFit.cover))),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                                height: 120,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: vendor['isOnline']
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        width: 3)),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 3)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(130),
                                                        child:
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    vendor[
                                                                        'logo'],
                                                                fit: BoxFit
                                                                    .cover))))
                                          ])
                                    ]))),
                        ListTile(
                            isThreeLine: true,
                            leading: const Icon(Icons.store),
                            title: Text(vendor['businessName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                Text('Vendor ID:\n${vendor['vendorID']}')),
                        ListTile(
                            leading: const Icon(Icons.perm_phone_msg),
                            title: Text(vendor['mobile']),
                            subtitle: Text(vendor['email'])),
                        ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(vendor['address']),
                            subtitle: Text(vendor['landMark'])),
                        ListTile(
                            leading: const Icon(Icons.date_range),
                            title: const Text('REGISTERED ON:'),
                            subtitle:
                                Text(dateTimeToString(vendor['registeredOn'])))
                      ])));
            }
            return emptyWidget('CUSTOMER NOT FOUND');
          }));
}
