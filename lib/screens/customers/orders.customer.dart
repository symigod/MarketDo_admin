import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/models/product.model.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class CustomerOrders extends StatefulWidget {
  final String customerID;
  const CustomerOrders({super.key, required this.customerID});

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  @override
  Widget build(BuildContext context) => Center(
      child: SingleChildScrollView(
          child: StreamBuilder(
              stream: ordersCollection
                  .where('customerID', isEqualTo: widget.customerID)
                  .where('isDelivered', isEqualTo: true)
                  .orderBy('orderedOn', descending: true)
                  .snapshots(),
              builder: (context, os) {
                if (os.hasError) {
                  print(os.error.toString());
                  return errorWidget(os.error.toString());
                }
                if (os.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                }
                if (os.data!.docs.isNotEmpty) {
                  var order = os.data!.docs;
                  return AlertDialog(
                      titlePadding: EdgeInsets.zero,
                      title: StreamBuilder(
                          stream: customersCollection
                              .where('customerID', isEqualTo: widget.customerID)
                              .snapshots(),
                          builder: (context, cs) {
                            if (cs.hasError) {
                              return errorWidget(cs.error.toString());
                            }
                            if (cs.connectionState == ConnectionState.waiting) {
                              return loadingWidget();
                            }
                            if (cs.data!.docs.isNotEmpty) {
                              return Card(
                                  color: Colors.green,
                                  margin: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5))),
                                  child: ListTile(
                                      title: Text(
                                          'Orders of: ${cs.data!.docs[0]['name']}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      trailing: InkWell(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(Icons.close,
                                                  color: Colors.white)))));
                            } else {
                              return emptyWidget('CUSTOMER NOT FOUND');
                            }
                          }),
                      contentPadding: EdgeInsets.zero,
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: order.length,
                              itemBuilder: (context, index) {
                                var tileColor = index % 2 == 0
                                    ? Colors.grey.shade100
                                    : Colors.white;
                                var orders = order[index];
                                int quantity = orders['productIDs'].length;
                                return StreamBuilder(
                                    stream: vendorsCollection
                                        .where('vendorID',
                                            isEqualTo: orders['vendorID'])
                                        .snapshots(),
                                    builder: (context, vs) {
                                      if (vs.hasError) {
                                        return errorWidget(vs.error.toString());
                                      }
                                      if (vs.connectionState ==
                                          ConnectionState.waiting) {
                                        return loadingWidget();
                                      }
                                      if (vs.data!.docs.isNotEmpty) {
                                        var vendor = vs.data!.docs[0];
                                        return ListTile(
                                            onTap: () => viewOrderDetails(
                                                orders['orderID'],
                                                vendor['vendorID']),
                                            tileColor: tileColor,
                                            leading: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color:
                                                            vendor['isOnline']
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
                                                            BorderRadius
                                                                .circular(50),
                                                        child: CachedNetworkImage(
                                                            imageUrl:
                                                                vendor['logo'],
                                                            fit: BoxFit.cover)))),
                                            title: Text(vendor['businessName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: RichText(
                                                text: TextSpan(style: const TextStyle(fontSize: 12, fontFamily: 'Lato'), children: [
                                              TextSpan(
                                                  text: quantity > 1
                                                      ? '$quantity items'
                                                      : '$quantity item',
                                                  style: const TextStyle(
                                                      color: Colors.grey)),
                                              TextSpan(
                                                  text:
                                                      '\n${dateTimeToString(orders['orderedOn'])}',
                                                  style: const TextStyle(
                                                      color: Colors.blue))
                                            ])),
                                            trailing: Text('P ${numberToString(orders['totalPayment'].toDouble())}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
                                      }
                                      return emptyWidget('VENDOR NOT FOUND');
                                    });
                              })));
                }
                return AlertDialog(
                    scrollable: true,
                    titlePadding: EdgeInsets.zero,
                    title: StreamBuilder(
                        stream: customersCollection
                            .where('customerID', isEqualTo: widget.customerID)
                            .snapshots(),
                        builder: (context, cs) {
                          if (cs.hasError) {
                            return errorWidget(cs.error.toString());
                          }
                          if (cs.connectionState == ConnectionState.waiting) {
                            return loadingWidget();
                          }
                          if (cs.data!.docs.isNotEmpty) {
                            return Card(
                                color: Colors.green,
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5))),
                                child: ListTile(
                                    title: Text(
                                        'Orders of: ${cs.data!.docs[0]['name']}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    trailing: InkWell(
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                        child: const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(Icons.close,
                                                color: Colors.white)))));
                          } else {
                            return emptyWidget('CUSTOMER NOT FOUND');
                          }
                        }),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    content: SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('NO ORDERS YET',
                                textAlign: TextAlign.center))));
              })));

  viewOrderDetails(String orderID, String vendorID) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: ordersCollection
                      .where('orderID', isEqualTo: orderID)
                      .where('vendorID', isEqualTo: vendorID)
                      .snapshots(),
                  builder: (context, os) {
                    if (os.hasError) {
                      return errorWidget(os.error.toString());
                    }
                    if (os.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (os.hasData) {
                      var order = os.data!.docs[0];
                      List<dynamic> products = order['productIDs'];
                      return AlertDialog(
                          titlePadding: EdgeInsets.zero,
                          title: StreamBuilder(
                              stream: vendorsCollection
                                  .where('vendorID', isEqualTo: vendorID)
                                  .snapshots(),
                              builder: (context, vs) {
                                if (vs.hasError) {
                                  return errorWidget(vs.error.toString());
                                }
                                if (vs.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingWidget();
                                }
                                if (vs.data!.docs.isNotEmpty) {
                                  var vendor = vs.data!.docs[0];
                                  return Card(
                                      color: Colors.green,
                                      margin: EdgeInsets.zero,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(3),
                                              topRight: Radius.circular(3))),
                                      child: ListTile(
                                          onTap: () => viewVendorDetails(
                                              context, vendor['vendorID']),
                                          leading: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: vendor['isOnline']
                                                          ? Colors
                                                              .green.shade900
                                                          : Colors.grey,
                                                      width: 2)),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: ClipRRect(borderRadius: BorderRadius.circular(50), child: CachedNetworkImage(imageUrl: vendor['logo'], fit: BoxFit.cover)))),
                                          title: Text(vendor['businessName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          trailing: InkWell(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close, color: Colors.white)))));
                                }
                                return emptyWidget('VENDOR NOT FOUND');
                              }),
                          contentPadding: EdgeInsets.zero,
                          content: SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                        leading: const Icon(
                                            Icons.confirmation_number),
                                        title: const Text('Order Code:'),
                                        subtitle: Text(order['orderID'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    ListTile(
                                        leading: const Icon(Icons.date_range),
                                        title: const Text('Ordered on:'),
                                        trailing: Text(
                                            dateTimeToString(
                                                order['orderedOn']),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold))),
                                    StreamBuilder(
                                        stream: Stream.fromFuture(Future.wait(
                                            products.map((productId) =>
                                                productsCollection
                                                    .doc(productId)
                                                    .get()))),
                                        builder: (context, ps) {
                                          if (ps.connectionState ==
                                              ConnectionState.waiting) {
                                            return loadingWidget();
                                          }
                                          if (ps.hasError) {
                                            return errorWidget(
                                                ps.error.toString());
                                          }
                                          if (!ps.hasData || ps.data!.isEmpty) {
                                            return emptyWidget(
                                                'PRODUCT NOT FOUND');
                                          }
                                          List<DocumentSnapshot>
                                              productSnapshots = ps.data!;
                                          List<ProductModel> productList =
                                              productSnapshots
                                                  .map((doc) => ProductModel
                                                      .fromFirestore(doc))
                                                  .toList();
                                          return ExpansionTile(
                                              initiallyExpanded: true,
                                              leading: const Icon(
                                                  Icons.shopping_bag),
                                              title: const Text('Products:'),
                                              trailing: const Icon(
                                                  Icons.arrow_drop_down),
                                              children: [
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        productList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      ProductModel product =
                                                          productList[index];
                                                      int pIndex = productList
                                                          .indexOf(productList[
                                                              index]);
                                                      double payments =
                                                          order['payments']
                                                              [pIndex];
                                                      double unitsBought =
                                                          order['unitsBought']
                                                              [pIndex];
                                                      return ListTile(
                                                          leading: SizedBox(
                                                              width: 50,
                                                              child: CachedNetworkImage(
                                                                  imageUrl: product
                                                                      .imageURL,
                                                                  fit: BoxFit
                                                                      .cover)),
                                                          title: RichText(
                                                              text: TextSpan(
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Lato'),
                                                                  children: [
                                                                TextSpan(
                                                                    text: product
                                                                        .productName,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text:
                                                                        ' [$unitsBought ${product.unit}/s]',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                              ])),
                                                          subtitle: Text(product
                                                              .description),
                                                          trailing: Text(
                                                              'P ${numberToString(payments)}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)));
                                                    })
                                              ]);
                                        }),
                                    ListTile(
                                        leading:
                                            const Icon(Icons.delivery_dining),
                                        title: const Text('Delivery:'),
                                        subtitle: Text(
                                            order['deliveryMethod'] ==
                                                    'DELIVERY'
                                                ? 'Home Delivery'
                                                : 'Pick-up'),
                                        trailing: Text(
                                            'P ${numberToString(order['deliveryFee'].toDouble())}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))),
                                    ListTile(
                                        leading: const Icon(Icons.payments),
                                        title: const Text('Payment:'),
                                        subtitle: Text(
                                            '${order['paymentMethod'] == 'COD' ? 'Cash on Delivery' : order['paymentMethod']}'),
                                        trailing: Text(
                                            'P ${numberToString(order['totalPayment'].toDouble())}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)))
                                  ])));
                    }
                    return emptyWidget('ORDER NOT FOUND');
                  }))));

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
                              child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.close,
                                      color: Colors.white))))),
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
