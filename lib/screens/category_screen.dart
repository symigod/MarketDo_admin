// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:marketdo_admin/firebase_services.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = 'Category';
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

final FirebaseStorage storage = FirebaseStorage.instance;

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _catName = TextEditingController();
  dynamic image;
  String? fileName;
  // String? _url;

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      setState(() {
        image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    } else {
      print('Cancelled or Failed');
    }
  }

  saveImageToDb() async {
    EasyLoading.show();
    var ref = storage.ref('categoryImage/$fileName');
    try {
      String? mimiType = mime(basename(fileName!));
      var metaData = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot =
          await ref.putData(image, metaData);
      String downloadUrRL = await ref.getDownloadURL().then((value) {
        if (value.isNotEmpty) {
          _service.saveCategories(
              data: {
                'catName': _catName.text,
                'image': '$value.png',
                'active': true
              },
              docName: _catName.text,
              reference: _service.categories).then((value) {
            clear();
            EasyLoading.dismiss();
          });
        }
        return value;
      });
    } on FirebaseException catch (e) {
      clear();
      EasyLoading.dismiss();
      print(e.toString());
    }
  }

  clear() {
    setState(() {
      _catName.clear();
      image = null;
    });
  }

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
                  onPressed: () {}, child: const Text('Add category'))
            ]),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('categories')
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
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5, childAspectRatio: 0.75),
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
                                        fit: BoxFit.cover, height: 150)),
                                const SizedBox(height: 10),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(categories['category'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16))),
                                const Divider(height: 20, thickness: 1),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: subcategories
                                            .map((subcategory) => Chip(
                                                label: Text(subcategory),
                                                backgroundColor:
                                                    Colors.greenAccent))
                                            .toList()))
                              ]));
                        });
                  }
                  return emptyWidget('NO CATEGORIES FOUND');
                })
          ]));

  addCategoryForm(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              scrollable: true,
              title: Text('ADD CATEGORY'),
              content: Column(
                children: [
                  TextField(
                    
                  ),
                ],
              ),
            ));
  }
}
