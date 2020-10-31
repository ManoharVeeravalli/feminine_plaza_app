import 'package:cached_network_image/cached_network_image.dart';
import 'package:feminine_plaza_app/models/item.dart';
import 'package:feminine_plaza_app/screens/item_details_screen.dart';
import 'package:feminine_plaza_app/service/item_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'add_item_screen.dart';
import 'log_in_screen.dart';

class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feminiine Plaza'),
      ),
      body: Consumer<ItemService>(
        builder: (context, service, child) {
          final List<Item> items = service.items;
          if (items == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('No Results'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => service.fetch(),
            child: Container(
              margin: EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  final Item item = items[index];
                  return Stack(
                    children: [
                      GridTile(
                        key: ValueKey(item.ref.id),
                        footer: GridTileBar(
                          backgroundColor: Colors.black45,
                          title: Text(item.displayName),
                          subtitle: Text(
                              '${DateFormat.yMMMMd().format(item.createdOn.toDate())}'),
                        ),
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: item.photoURL,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ItemDetailScreen.route,
                                arguments: item);
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 80,
                                  child: ListView(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          ItemService.instance.delete(item);
                                          Navigator.of(context).pop();
                                        },
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (FirebaseAuth.instance.currentUser == null) {
            Navigator.of(context).pushNamed(LogInScreen.route);
          } else {
            Navigator.of(context).pushNamed(AddItemScreen.route);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
