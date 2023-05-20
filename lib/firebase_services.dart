import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  CollectionReference mainCategories =
      FirebaseFirestore.instance.collection('mainCategories');
  CollectionReference subCategories =
      FirebaseFirestore.instance.collection('subCategories');
  CollectionReference vendor = FirebaseFirestore.instance.collection('vendor');
  CollectionReference customer =
      FirebaseFirestore.instance.collection('customer');
  CollectionReference product =
      FirebaseFirestore.instance.collection('product');

  var users;

  Future<void> saveCategories(
      {CollectionReference? reference,
      Map<String, dynamic>? data,
      String? docName}) async {
    return reference!.doc(docName).set(data);
  }

  Future<void> updateData(
      {CollectionReference? reference,
      Map<String, dynamic>? data,
      String? docName}) async {
    return reference!.doc(docName).update(data!);
  }
}
