import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:marketdo_admin/firebase.services.dart';

// ignore: must_be_immutable
class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final CategoryFormData _formData = CategoryFormData();
  final TextEditingController _subcategoryController = TextEditingController();

  void _addSubcategory() {
    final subcategory = _subcategoryController.text.trim();
    if (subcategory.isNotEmpty) {
      setState(() {
        _formData.subcategories.add(subcategory);
        _subcategoryController.clear();
      });
    }
  }

  void removeSubcategory(int index) {
    setState(() {
      _formData.subcategories.removeAt(index);
    });
  }

  void _submitForm() {
    final docID = categoriesCollection.doc().id;
    if (_formKey.currentState!.validate()) {
      if (_formData.subcategories.isEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
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
      categoriesCollection.doc(docID).set({
        'category': _formData.category,
        'categoryID': docID,
        'subcategories': _formData.subcategories,
        'imageURL': _formData.imageURL
      });
      Navigator.pop(context);
    }
  }

  Uint8List? _pickedImageBytes;

  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedImageBytes = result.files.first.bytes;
      });

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('categories')
          .child(result.files.first.name);

      firebase_storage.UploadTask uploadTask = ref.putData(_pickedImageBytes!);

      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      setState(() => _formData.imageURL = downloadURL);
    }
  }

  @override
  Widget build(BuildContext context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: const Text('Add Category'),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Form(
                      key: _formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        if (_pickedImageBytes == null)
                          ElevatedButton(
                              onPressed: _pickAndUploadImage,
                              child: const Text('Pick Image'))
                        else
                          Flexible(
                              child: Column(children: [
                            SizedBox(
                                width: 500,
                                child: Image.memory(_pickedImageBytes!)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: _pickAndUploadImage,
                                child: const Text('Change Image'))
                          ])),
                        const SizedBox(height: 10),
                        TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Category Name'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a category'
                                : null,
                            onSaved: (value) => _formData.category = value!),
                        const SizedBox(height: 5),
                        Column(
                            children: _formData.subcategories
                                .asMap()
                                .entries
                                .map((entry) => ListTile(
                                    dense: true,
                                    title: Text(entry.value,
                                        style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold)),
                                    trailing: IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.red.shade900),
                                        onPressed: () {
                                          setState(() {
                                            _formData.subcategories
                                                .removeAt(entry.key);
                                          });
                                        })))
                                .toList()),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _subcategoryController,
                          decoration: InputDecoration(
                              suffix: ElevatedButton(
                                  onPressed: _addSubcategory,
                                  child: const Text('Add')),
                              border: const OutlineInputBorder(),
                              labelText: 'Subcategory'),
                          validator: (value) {
                            if (_formData.subcategories.isEmpty) {
                              return 'Please enter at least 1 subcategory';
                            }
                            return null;
                          },
                        )
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _pickedImageBytes == null
                            ? Colors.grey
                            : Colors.green.shade900),
                    onPressed: _pickedImageBytes == null ? null : _submitForm,
                    child: const Text('Submit'))
              ]));
}

class CategoryFormData {
  late String category;
  List<String> subcategories = [];
  late String imageURL;
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
