import 'package:cloud_firestore/cloud_firestore.dart';

final cartsCollection = FirebaseFirestore.instance.collection('carts');
final categoriesCollection =
    FirebaseFirestore.instance.collection('categories');
final customersCollection = FirebaseFirestore.instance.collection('customers');
final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
final homeBannerCollection =
    FirebaseFirestore.instance.collection('homeBanner');
final ordersCollection = FirebaseFirestore.instance.collection('orders');
final productsCollection = FirebaseFirestore.instance.collection('products');
final vendorsCollection = FirebaseFirestore.instance.collection('vendors');
