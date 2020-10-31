import 'package:feminine_plaza_app/screens/add_item_screen.dart';
import 'package:feminine_plaza_app/screens/item_details_screen.dart';
import 'package:feminine_plaza_app/screens/items_screen.dart';
import 'package:feminine_plaza_app/screens/log_in_screen.dart';
import 'package:feminine_plaza_app/service/item_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemService>(
          create: (context) {
            return ItemService.instance..fetch();
          },
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ItemsScreen(),
        routes: {
          AddItemScreen.route: (_) => AddItemScreen(),
          ItemDetailScreen.route: (_) => ItemDetailScreen(),
          LogInScreen.route: (_) => LogInScreen()
        },
      ),
    );
  }
}
