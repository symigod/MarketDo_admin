import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import '../firebase_services.dart';
import '../widgets/categories_list_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SubCategoryScreen extends StatefulWidget {
  static const String id = 'SubCategory';
  const SubCategoryScreen({Key? key}) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseService _service = FirebaseService();
  final TextEditingController _subCatName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  dynamic image;
  String? fileName;
  Object? _selectedValue;
  bool _noCategorySelected = false;
  QuerySnapshot? snapshot;

  Widget _dropDownButton() {
    return DropdownButton(
        value: _selectedValue,
        hint: const Text('Select Main Category'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
            value: e['mainCategory'],
            child: Text(e['mainCategory']),
          );
        }).toList(),
        onChanged: (selectedCat) {
          setState(() {
            _selectedValue = selectedCat;
            _noCategorySelected = false;
          });
        });
  }

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      setState(() {
        image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    } else {
      //failed to pick image or user cancelled
      print('Cancelled or Failed');
    }
  }

  saveImageToDb() async {
    EasyLoading.show();
    var ref = storage.ref('subCategoryImage/$fileName');
    try {
      String? mimiType = mime(
        basename(fileName!),
      );
      var metaData = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot =
          await ref.putData(image, metaData);
      String downloadUrRL = await ref.getDownloadURL().then((value) {
        if (value.isNotEmpty) {
          //save data to firestore
          _service.saveCategories(data: {
            'subCatName': _subCatName.text,
            'mainCategory': _selectedValue,
            'image': '$value.png',
            'active': true
          }, docName: _subCatName.text, reference: _service.subCategories).then(
              (value) {
            //after saving, clear all the datas from screen
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
      _subCatName.clear();
      image = null;
    });
  }

  @override
  void initState() {
    getMainCatList();
    super.initState();
  }

  getMainCatList() {
    return _service.mainCategories.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Sub Categories',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Center(
                      child: image == null
                          ? const Text('Sub Category Image')
                          : Image.memory(image),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: const Text('Upload Image'),
                    onPressed: pickImage,
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  snapshot == null
                      ? const Text('Loading...')
                      : _dropDownButton(),
                  const SizedBox(
                    height: 8,
                  ),
                  if (_noCategorySelected == true)
                    const Text(
                      'No Main Category Selected',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Sub Category Name';
                        }
                      },
                      controller: _subCatName,
                      decoration: const InputDecoration(
                          label: Text('Enter Sub Category Name'),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: clear,
                        child: Text(
                          'Cancel',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          side: MaterialStateProperty.all(
                            BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      //save buttod should show only if image no equal to null, only after image selected
                      if (image != null)
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedValue == null) {
                              setState(() {
                                _noCategorySelected = true;
                              });
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              saveImageToDb();
                            }
                          },
                          child: const Text('  Save  '),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Sub Category List',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CategoryListWidget(
            reference: _service.subCategories,
          )
        ],
      ),
    );
  }
}
