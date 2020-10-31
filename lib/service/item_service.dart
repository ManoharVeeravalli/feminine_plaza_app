import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feminine_plaza_app/constants.dart';
import 'package:feminine_plaza_app/models/item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class ItemService with ChangeNotifier {
  static final instance = ItemService._singleton();
  ItemService._singleton();
  List<Item> items;

  Future<void> fetch() async {
    try {
      items = await FirebaseFirestore.instance
          .collection(ITEMS)
          .orderBy('createdOn', descending: true)
          .get()
          .then((value) {
        if (value == null || value.docs == null || value.docs.isEmpty) {
          return [];
        }
        return value.docs.map((e) => Item.fromMap(e.data())).toList();
      });
    } catch (e) {
      items = [];
      print(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> add(final Item item) async {
    items.add(item);
    notifyListeners();
    try {
      await item.ref.set(item.toMap());
    } catch (e) {
      items.remove(item);
      notifyListeners();
    }
  }

  Future<void> delete(final Item item) async {
    items.remove(item);
    notifyListeners();
    try {
      await FirebaseStorage.instance
          .ref()
          .child(ITEMS)
          .child(item.ref.id)
          .delete();
      await item.ref.delete();
    } catch (e) {
      items.add(item);
      notifyListeners();
    }
  }
}
