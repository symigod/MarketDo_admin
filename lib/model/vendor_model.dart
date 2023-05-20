import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  final approved;
  final businessName;
  final city;
  final country;
  final email;
  final isActive;
  final landMark;
  final logo;
  final mobile;
  final pinCode;
  final shopImage;
  final state;
  final taxRegistered;
  final time;
  final tinNumber;
  final uid;

  Vendor({
    required this.approved,
    required this.businessName,
    required this.city,
    required this.country,
    required this.email,
    required this.isActive,
    required this.landMark,
    required this.logo,
    required this.mobile,
    required this.pinCode,
    required this.shopImage,
    required this.state,
    required this.taxRegistered,
    required this.time,
    required this.tinNumber,
    required this.uid,
  });

  factory Vendor.fromJson(Map<String, dynamic> map) {
    return Vendor(
      approved: map['approved'],
      businessName: map['businessName'],
      city: map['city'],
      country: map['country'],
      email: map['email'],
      isActive: map['isActive'],
      landMark: map['landMark'],
      logo: map['logo'],
      mobile: map['mobile'],
      pinCode: map['pinCode'],
      shopImage: map['shopImage'],
      state: map['state'],
      taxRegistered: map['taxRegistered'],
      time: map['time'],
      tinNumber: map['tinNumber'],
      uid: map['uid'],
    );
  }
}

Stream<List<Vendor>> getAllVendors() {
  return FirebaseFirestore.instance
      .collection('vendors')
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => Vendor.fromJson(doc.data())).toList());
}

Stream<List<Vendor>> getApprovedVendors() {
  return FirebaseFirestore.instance
      .collection('vendors')
      .where('approved', isEqualTo: true)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => Vendor.fromJson(doc.data())).toList());
}

Stream<List<Vendor>> getNotApprovedVendors() {
  return FirebaseFirestore.instance
      .collection('vendors')
      .where('approved', isEqualTo: false)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => Vendor.fromJson(doc.data())).toList());
}
