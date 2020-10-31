import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final DocumentReference ref;
  final String displayName;
  final String description;
  String photoURL;
  final double price;
  final Timestamp createdOn;

  Item(
      {this.displayName,
      this.ref,
      this.description,
      this.photoURL,
      this.price,
      this.createdOn});

  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'displayName': displayName,
      'description': description,
      'photoURL': photoURL,
      'createdOn': createdOn,
      'price': price
    };
  }

  Item.fromMap(Map<String, dynamic> map)
      : this(
          ref: map['ref'],
          displayName: map['displayName'],
          description: map['description'],
          photoURL: map['photoURL'],
          createdOn: map['createdOn'],
          price: double.tryParse(map['price'].toString()),
        );

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Batch(ref: $ref, displayName: $displayName, description: $description, photoURL: $photoURL, createdOn: $createdOn, price: $price)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Item && o.ref.id == ref.id;
  }

  @override
  int get hashCode {
    return ref.id.hashCode;
  }
}
