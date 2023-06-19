// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/screens/categories/add.category.dart';
import 'package:marketdo_admin/screens/categories/edit.category.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/firebase.services.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = 'categories-screen';
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
                stream: categoriesCollection.orderBy('category').snapshots(),
                builder: (context, cs) {
                  if (cs.hasError) {
                    return errorWidget(cs.error.toString());
                  }
                  if (cs.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  }
                  if (cs.hasData) {
                    var category = cs.data!.docs;
                    return LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                                children:
                                    List.generate(category.length, (index) {
                              var categories = category[index];
                              List<String> subcategories = List<String>.from(
                                  categories['subcategories']);
                              subcategories.sort((a, b) =>
                                  a.toLowerCase().compareTo(b.toLowerCase()));
                              return SizedBox(
                                  width: constraints.maxWidth / 3,
                                  child: Card(
                                      elevation: 10,
                                      shadowColor: Colors.green.shade900,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.green.shade900,
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: MediaQuery.of(context).size.height /
                                                    4,
                                                width: MediaQuery.of(context).size.width /
                                                    3,
                                                child: ClipRRect(
                                                    borderRadius: const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(5),
                                                        topRight:
                                                            Radius.circular(5)),
                                                    child: categories['category'] == 'Others'
                                                        ? Padding(
                                                            padding: const EdgeInsets.all(
                                                                8.0),
                                                            child: Image.network(categories['imageURL'],
                                                                fit: BoxFit
                                                                    .fitHeight))
                                                        : CachedNetworkImage(
                                                            imageUrl: categories['imageURL'],
                                                            fit: BoxFit.cover))),
                                            ListTile(
                                                dense: true,
                                                title: Text(
                                                    categories['category'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                          onTap: () => showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  EditCategoryDialog(
                                                                      categoryID:
                                                                          categories[
                                                                              'categoryID'])),
                                                          child: Icon(
                                                              Icons.edit,
                                                              color: Colors.blue
                                                                  .shade900)),
                                                      InkWell(
                                                          onTap: () =>
                                                              deleteCategory(
                                                                  categories[
                                                                      'categoryID']),
                                                          child: Icon(
                                                              Icons.delete,
                                                              color: Colors.red
                                                                  .shade900))
                                                    ])),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Wrap(
                                                    alignment:
                                                        WrapAlignment.start,
                                                    spacing: 4,
                                                    runSpacing: 4,
                                                    children: subcategories
                                                        .map((subcategory) => Chip(
                                                            label: Text(
                                                                subcategory,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            backgroundColor:
                                                                Colors
                                                                    .greenAccent))
                                                        .toList())),
                                            const SizedBox(height: 10)
                                          ])));
                            })));
                  }
                  return emptyWidget('NO CATEGORIES FOUND');
                })
          ]));

  deleteCategory(String categoryID) => showDialog(
      context: context,
      builder: (_) => confirmDialog(
              context, 'DELETE CATEGORY', 'Do you want to continue?', () {
            try {
              categoriesCollection.doc(categoryID).delete();
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
