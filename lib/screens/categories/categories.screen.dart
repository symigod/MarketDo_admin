// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/screens/categories/add.category.dart';
import 'package:marketdo_admin/screens/categories/edit.category.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = 'Category';
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

final FirebaseStorage storage = FirebaseStorage.instance;

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('PRODUCT CATEGORIES',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                  onPressed: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const AddCategoryDialog()),
                  child: const Text('Add category'))
            ]),
            const SizedBox(height: 10),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy('category')
                    .snapshots(),
                builder: (context, cs) {
                  if (cs.hasError) {
                    return errorWidget(cs.error.toString());
                  }
                  if (cs.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  }
                  if (cs.hasData) {
                    var category = cs.data!.docs;
                    return GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10),
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          var categories = category[index];
                          List<String> subcategories =
                              List<String>.from(categories['subcategories']);
                          subcategories.sort((a, b) =>
                              a.toLowerCase().compareTo(b.toLowerCase()));
                          return Card(
                              elevation: 10,
                              shadowColor: Colors.green.shade900,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.green.shade900, width: 2),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width: MediaQuery.of(context).size.width /
                                            3,
                                        child: ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5)),
                                            child: categories['category'] ==
                                                    'Others'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.network(
                                                        categories['imageURL'],
                                                        fit: BoxFit.fitHeight))
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        categories['imageURL'],
                                                    fit: BoxFit.cover))),
                                    ListTile(
                                        dense: true,
                                        title: Text(categories['category'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color:
                                                          Colors.blue.shade900),
                                                  onPressed: () => showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          EditCategoryDialog(
                                                              categoryID:
                                                                  categories[
                                                                      'categoryID']))),
                                              IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color:
                                                          Colors.red.shade900),
                                                  onPressed: () =>
                                                      deleteCategory(categories[
                                                          'categoryID']))
                                            ])),
                                    Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Wrap(
                                                alignment: WrapAlignment.start,
                                                spacing: 4,
                                                runSpacing: 4,
                                                children: subcategories
                                                    .map((subcategory) => Chip(
                                                        label: Text(subcategory,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        backgroundColor:
                                                            Colors.greenAccent))
                                                    .toList()))),
                                    const SizedBox(height: 10)
                                  ]));
                        });
                  }
                  return emptyWidget('NO CATEGORIES FOUND');
                })
          ]));

  deleteCategory(String categoryID) => showDialog(
      context: context,
      builder: (_) => confirmDialog(
              context, 'DELETE CATEGORY', 'Do you want to continue?', () {
            try {
              FirebaseFirestore.instance
                  .collection('categories')
                  .doc(categoryID)
                  .delete();
              Fluttertoast.showToast(
                  msg: 'Product Category deleted!',
                  timeInSecForIosWeb: 3,
                  webBgColor: 'rgb(183, 28, 28)',
                  webPosition: 'center');
              Navigator.pop(context);
            } catch (e) {
              showDialog(
                  context: context,
                  builder: (_) => errorDialog(context, e.toString()));
            }
          }));
}