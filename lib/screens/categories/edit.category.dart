import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:marketdo_admin/widgets/api_widgets.dart';

class EditCategoryDialog extends StatefulWidget {
  final String categoryID;

  const EditCategoryDialog({Key? key, required this.categoryID})
      : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final CategoryFormData _formData = CategoryFormData();
  final TextEditingController _subcategoryController = TextEditingController();


  void _submitForm() {
    final collection = FirebaseFirestore.instance.collection('categories');
    final docID = widget.categoryID;
    if (_formKey.currentState!.validate()) {
      if (_formData.subcategories.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Please add at least one subcategory.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'))
                    ]));
        return;
      }
      _formKey.currentState!.save();
      collection.doc(docID).update({
        'category': _formData.category,
        'subcategories': _formData.subcategories,
        'imageURL': _formData.imageURL
      });
      Navigator.pop(context);
    }
  }

  Uint8List? _pickedImageBytes;

  void _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (mounted) setState(() => _pickedImageBytes = result.files.first.bytes);

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('category_images')
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      firebase_storage.UploadTask uploadTask = ref.putData(_pickedImageBytes!);

      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      if (mounted) setState(() => _formData.imageURL = downloadURL);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('categories')
          .where('categoryID', isEqualTo: widget.categoryID)
          .get(),
      builder: (context, cs) {
        if (cs.hasError) {
          return errorWidget(cs.error.toString());
        }
        if (cs.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (cs.hasData) {
          var category = cs.data!.docs[0];
          _formData.category = category['category'];
          List<dynamic> subcategories = [];
          subcategories.addAll(category['subcategories']);
          _formData.subcategories =
              subcategories.map((e) => e.toString()).toList().cast<String>();
          _formData.imageURL = category['imageURL'];
          Widget imageWidget;
          if (_pickedImageBytes != null) {
            imageWidget =
                SizedBox(width: 500, child: Image.memory(_pickedImageBytes!));
          } else if (_formData.imageURL!.isNotEmpty) {
            imageWidget = SizedBox(
                width: 500,
                child: Image.network(_formData.imageURL.toString()));
          } else {
            imageWidget = const SizedBox();
          }
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                      scrollable: true,
                      title: const Text('Edit Category'),
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _formData.imageURL!.isEmpty &&
                                            _pickedImageBytes == null
                                        ? ElevatedButton(
                                            onPressed: () {
                                              if (mounted) {
                                                setState(() =>
                                                    _formData.imageURL = '');
                                                _pickAndUploadImage();
                                              }
                                            },
                                            child: const Text('Pick Image'))
                                        : Flexible(
                                            child: Column(children: [
                                            imageWidget,
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                                onPressed: () {
                                                  if (mounted) {
                                                    setState(() => _formData
                                                        .imageURL = '');
                                                    _pickAndUploadImage();
                                                  }
                                                },
                                                child:
                                                    const Text('Change Image'))
                                          ])),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                        initialValue: _formData.category,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Category Name'),
                                        validator: (value) => value!.isEmpty
                                            ? 'Please enter a category'
                                            : null,
                                        onSaved: (value) =>
                                            _formData.category = value!),
                                    const SizedBox(height: 5),
                                    Column(
                                        children: _formData.subcategories
                                            .asMap()
                                            .entries
                                            .map((entry) => ListTile(
                                                dense: true,
                                                title: Text(entry.value,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .green.shade900,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                trailing: IconButton(
                                                    icon: Icon(Icons.close,
                                                        color: Colors
                                                            .red.shade900),
                                                    onPressed: () => setState(() =>
                                                        _formData.subcategories.removeAt(entry.key)))))
                                            .toList()),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                        controller: _subcategoryController,
                                        decoration: InputDecoration(
                                            suffix: ElevatedButton(
                                                onPressed: (){
                                                  final subcategory =
                                                      _subcategoryController
                                                          .text
                                                          .trim();
                                                  if (subcategory.isNotEmpty) {
                                                    if (mounted) {
                                                      setState(() {
                                                        _formData.subcategories
                                                            .add(subcategory);
                                                        _subcategoryController
                                                            .clear();
                                                      });
                                                    }
                                                  }
                                                },
                                                child: const Text('Add')),
                                            border: const OutlineInputBorder(),
                                            labelText: 'Add subcategory'),
                                        validator: (value) => _formData
                                                .subcategories.isEmpty
                                            ? 'Please enter at least 1 subcategory'
                                            : null)
                                  ]))),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel')),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _pickedImageBytes == null &&
                                        _formData.imageURL == null
                                    ? Colors.grey
                                    : Colors.green.shade900),
                            onPressed: _pickedImageBytes == null &&
                                    _formData.imageURL == null
                                ? null
                                : _submitForm,
                            child: const Text('Update'))
                      ]));
        }
        return emptyWidget('CATEGORY NOT FOUND');
      });
}

class CategoryFormData {
  String? category;
  List<String> subcategories = [];
  String? imageURL;
}

class ChipWithCloseButton extends StatelessWidget {
  final Widget label;
  final VoidCallback onClose;

  const ChipWithCloseButton({
    Key? key,
    required this.label,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Chip(
          label: Row(mainAxisSize: MainAxisSize.min, children: [
        label,
        const SizedBox(width: 4),
        InkWell(onTap: onClose, child: const Icon(Icons.close))
      ]));
}
