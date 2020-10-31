import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feminine_plaza_app/constants.dart';
import 'package:feminine_plaza_app/models/item.dart';
import 'package:feminine_plaza_app/service/item_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  static const route = 'add-item';
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String _displayName;
  String _description;
  double _price;
  PickedFile _photo;
  final FocusNode node1 = FocusNode();
  final FocusNode node2 = FocusNode();
  final _picker = ImagePicker();
  StorageTaskSnapshot snapshot;
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _submit(ctx),
              );
            },
          )
        ],
      ),
      body: Card(
        child: Form(
          key: _form,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(hintText: "Item Name"),
                  onSaved: (value) {
                    _displayName = value;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(node1);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter item name";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                child: TextFormField(
                  focusNode: node1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _price = double.tryParse(value);
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(node2);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter item price";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                child: TextFormField(
                  focusNode: node2,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.name,
                  maxLines: 5,
                  decoration: InputDecoration(hintText: "Description"),
                  onSaved: (value) {
                    _description = value;
                  },
                  onFieldSubmitted: (value) {
                    _bottomSheet();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Photo',
                      style: TextStyle(fontSize: 15),
                    ),
                    IconButton(
                      icon:
                          _picker == null ? Icon(Icons.add) : Icon(Icons.edit),
                      onPressed: _bottomSheet,
                    )
                  ],
                ),
              ),
              if (_photo != null) Image.file(File(_photo.path))
            ],
          ),
        ),
      ),
    );
  }

  void uploadImage(final ImageSource src) async {
    final picked = await _picker.getImage(
      source: src,
      preferredCameraDevice: CameraDevice.rear,
      maxHeight: 1200,
      maxWidth: 1200,
      imageQuality: 50,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _photo = picked;
    });
  }

  void _bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: 130,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  onTap: () {
                    uploadImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  title: const Text("Gallary"),
                ),
                ListTile(
                  leading: const Icon(Icons.camera),
                  onTap: () {
                    uploadImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  title: const Text("Camara"),
                )
              ],
            ),
          );
        });
  }

  void _submit(final BuildContext ctx) async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (!_form.currentState.validate()) {
      return;
    }
    if (_photo == null) {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Please provide an image'),
        ),
      );
    }
    _form.currentState.save();
    String photoURL = '';
    final Item item = Item(
      ref: FirebaseFirestore.instance.collection(ITEMS).doc(),
      displayName: _displayName,
      description: _description,
      price: _price,
      photoURL: photoURL,
      createdOn: Timestamp.now(),
    );
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(ITEMS).child(item.ref.id);
    final StorageUploadTask task = ref.putFile(File(_photo.path));
    task.events.listen((event) {
      setState(() {
        snapshot = event.snapshot;
      });
    });
    await task.onComplete;
    photoURL = await ref.getDownloadURL() as String;
    item.photoURL = photoURL;
    ItemService.instance.add(item);
    Navigator.of(context).pop();
    return;
  }
}
