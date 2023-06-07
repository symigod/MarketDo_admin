import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  CollectionReference vendor = FirebaseFirestore.instance.collection('vendor');
  CollectionReference customer =
      FirebaseFirestore.instance.collection('customers');
  CollectionReference product =
      FirebaseFirestore.instance.collection('products');

  var users;

  Future<void> saveCategories(
          {CollectionReference? reference,
          Map<String, dynamic>? data,
          String? docName}) async =>
      reference!.doc(docName).set(data);

  Future<void> updateData(
          {CollectionReference? reference,
          Map<String, dynamic>? data,
          String? docName}) async =>
      reference!.doc(docName).update(data!);
}
