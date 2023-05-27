import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:marketdo_admin/screens/category_screen.dart';
import 'package:marketdo_admin/screens/customer_screen.dart';
import 'package:marketdo_admin/screens/dashboard_screen.dart';
import 'package:date_time_format/date_time_format.dart';
import 'dart:core';
import 'package:marketdo_admin/screens/main_category_screen.dart';
import 'package:marketdo_admin/screens/product_screen.dart';
import 'package:marketdo_admin/screens/sub_category_screen.dart';
import 'package:marketdo_admin/screens/vendor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBhdLFSYflUevpsoEssdjh_zcPTA8ynnyc",
          authDomain: "marketdoapp.firebaseapp.com",
          projectId: "marketdoapp",
          storageBucket: "marketdoapp.appspot.com",
          messagingSenderId: "780102967000",
          appId: "1:780102967000:web:355fc279e1b33653e901ad",
          measurementId: "G-T7V8YN5HBN"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MarketDo Admin',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SideMenu(),
      builder: EasyLoading.init());
}

class SideMenu extends StatefulWidget {
  static const String id = 'SideMenu';
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Widget _selectedScreen = const DashboardScreen();

  screenSelector(item) {
    switch (item.route) {
      case DashboardScreen.id:
        setState(() => _selectedScreen = const DashboardScreen());
        break;
      case CategoryScreen.id:
        setState(() => _selectedScreen = const CategoryScreen());
        break;
      case MainCategoryScreen.id:
        setState(() => _selectedScreen = const MainCategoryScreen());
        break;
      case SubCategoryScreen.id:
        setState(() => _selectedScreen = const SubCategoryScreen());
        break;
      case VendorScreen.id:
        setState(() => _selectedScreen = const VendorScreen());
        break;
      case CustomerScreen.id:
        setState(() => _selectedScreen = const CustomerScreen());
        break;
      case ProductScreen.id:
        setState(() => _selectedScreen = const ProductScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) => AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('MarketDo', style: TextStyle(letterSpacing: 1))),
      sideBar: SideBar(
          items: const [
            AdminMenuItem(
                title: 'Dashboard',
                route: DashboardScreen.id,
                icon: Icons.dashboard),
            AdminMenuItem(
                title: 'Categories',
                icon: IconlyLight.category,
                children: [
                  AdminMenuItem(title: 'Category', route: CategoryScreen.id),
                  AdminMenuItem(
                      title: 'Main Category', route: MainCategoryScreen.id),
                  AdminMenuItem(
                      title: 'Sub Category', route: SubCategoryScreen.id)
                ]),
            AdminMenuItem(
                title: 'Vendors',
                route: VendorScreen.id,
                icon: Icons.group_outlined),
            AdminMenuItem(
                title: 'Customers',
                route: CustomerScreen.id,
                icon: Icons.groups_3_outlined),
            AdminMenuItem(
                title: 'Products',
                route: ProductScreen.id,
                icon: Icons.shopping_bag_outlined)
          ],
          selectedRoute: SideMenu.id,
          onSelected: (item) => screenSelector(item),
          // if (item.route != null) {
          //   Navigator.of(context).pushNamed(item.route!);
          // }
          header: Container(
              height: 50,
              width: double.infinity,
              color: const Color(0xff444444),
              child: const Center(
                  child: Text('Menu', style: TextStyle(color: Colors.white)))),
          footer: Container(
              height: 50,
              width: double.infinity,
              color: const Color(0xff444444),
              child: Center(
                  child: Text(
                      DateTimeFormat.format(DateTime.now(),
                          format: AmericanDateFormats.dayOfWeek),
                      style: const TextStyle(color: Colors.white))))),
      body: SingleChildScrollView(child: _selectedScreen));
}
