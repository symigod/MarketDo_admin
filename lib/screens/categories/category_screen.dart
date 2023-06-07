// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/screens/categories/add_category.dart';
import 'package:marketdo_admin/screens/categories/edit_category.dart';
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
                        padding: const EdgeInsets.all(20),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 350, childAspectRatio: 0.7),
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          var categories = category[index];
                          List<String> subcategories =
                              List<String>.from(categories['subcategories']);
                          return Card(
                              elevation: 10,
                              shadowColor: Colors.green.shade900,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 2, color: Colors.green.shade900),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(children: [
                                ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5)),
                                    child: Image.network(categories['imageURL'],
                                        fit: BoxFit.cover, height: 200)),
                                const SizedBox(height: 10),
                                ListTile(
                                    dense: true,
                                    title: Text(categories['category'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  color: Colors.blue.shade900,
                                                  child: GestureDetector(
                                                      onTap: () => showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (_) =>
                                                              EditCategoryDialog(
                                                                  categoryID:
                                                                      categories[
                                                                          'categoryID'])),
                                                      child: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              Colors.white)))),
                                          const SizedBox(width: 5),
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  color: Colors.red.shade900,
                                                  child: GestureDetector(
                                                      onTap: () =>
                                                          deleteCategory(
                                                              categories[
                                                                  'categoryID']),
                                                      child: const Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.white))))
                                        ])),
                                const Divider(height: 20, thickness: 1),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: subcategories
                                                .map((subcategory) => Chip(
                                                    label: Text(subcategory),
                                                    backgroundColor:
                                                        Colors.greenAccent))
                                                .toList())))
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
