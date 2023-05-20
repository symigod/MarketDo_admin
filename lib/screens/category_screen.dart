import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:marketdo_admin/firebase_services.dart';
import 'package:marketdo_admin/widgets/categories_list_widget.dart';
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
  final _formKey = GlobalKey<FormState>();
  dynamic image;
  String? fileName;
  String? _url;

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false
    );
    if (result!=null){
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
    var ref = storage.ref('categoryImage/$fileName');
    try {

      String? mimiType = mime(basename(fileName!),);
      var metaData = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot = await ref.putData(image,metaData);
      String downloadUrRL = await ref.getDownloadURL().then((value) {
        if(value.isNotEmpty){

          //save data to firestore
          _service.saveCategories(
            data: {
              'catName': _catName.text,
              'image':'$value.png',
              'active':true
            },
            docName: _catName.text,
            reference: _service.categories
          ).then((value) {
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

  clear(){
    setState(() {
      _catName.clear();
      image=null;
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
              'Categories',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Row(
            children: [
              const SizedBox(width: 10,),
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
                    child: Center(child: image == null ? const Text('Category Image') : Image.memory(image),),

                  ),
                  const SizedBox (height: 10,),
                  ElevatedButton(
                    child: const Text('Upload Image'),
                    onPressed: pickImage,
                  )
                ],
              ),
              const SizedBox(width: 20,
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Enter Category Name';
                    }
                  },
                  controller: _catName,
                  decoration: const InputDecoration(
                      label: Text('Enter Category Name'),
                      contentPadding: EdgeInsets.zero
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              TextButton(
                onPressed: clear,
                child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor),),
                ),
              ),
              const SizedBox(width: 10,),
              image == null ? Container():ElevatedButton(
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    saveImageToDb();
                  }
                },
                child: const Text('  Save  '),),


            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Category List',
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
            reference: _service.categories,
          )
        ],
      ),
    );
  }
}
