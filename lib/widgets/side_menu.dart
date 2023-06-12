import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marketdo_admin/main.dart';
import 'package:marketdo_admin/screens/categories/categories.screen.dart';
import 'package:marketdo_admin/screens/customers/customers.screen.dart';
import 'package:marketdo_admin/screens/dashboard_screen.dart';
import 'package:marketdo_admin/screens/products/products.screen.dart';
import 'package:marketdo_admin/screens/vendors/vendors.screen.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';

class SideMenu extends StatefulWidget {
  static const String id = 'SideMenu';
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final session = const FlutterSecureStorage();
  Widget _selectedScreen = const DashboardScreen();

  screenSelector(item) {
    switch (item.route) {
      case DashboardScreen.id:
        setState(() => _selectedScreen = const DashboardScreen());
        break;
      case CategoryScreen.id:
        setState(() => _selectedScreen = const CategoryScreen());
        break;
      // case MainCategoryScreen.id:
      //   setState(() => _selectedScreen = const MainCategoryScreen());
      //   break;
      // case SubCategoryScreen.id:
      //   setState(() => _selectedScreen = const SubCategoryScreen());
      //   break;
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
          title:
              const Text('MarketDo Admin', style: TextStyle(letterSpacing: 1)),
          actions: [
            IconButton(
                onPressed: () => logout(), icon: const Icon(Icons.exit_to_app))
          ]),
      sideBar: SideBar(
          items: const [
            AdminMenuItem(
                title: 'Dashboard',
                route: DashboardScreen.id,
                icon: Icons.dashboard),
            AdminMenuItem(
                title: 'Categories',
                route: CategoryScreen.id,
                icon: Icons.category),
            // AdminMenuItem(title: 'Categories', icon: Icons.category, children: [
            //   AdminMenuItem(title: 'Category', route: CategoryScreen.id),
            //   AdminMenuItem(
            //       title: 'Main Category', route: MainCategoryScreen.id),
            //   AdminMenuItem(title: 'Sub Category', route: SubCategoryScreen.id)
            // ]),
            AdminMenuItem(
                title: 'Vendors', route: VendorScreen.id, icon: Icons.store),
            AdminMenuItem(
                title: 'Customers',
                route: CustomerScreen.id,
                icon: Icons.people),
            AdminMenuItem(
                title: 'Products',
                route: ProductScreen.id,
                icon: Icons.shopping_cart)
          ],
          selectedRoute: SideMenu.id,
          onSelected: (item) => screenSelector(item),
          // if (item.route != null) {
          //   Navigator.of(context).pushNamed(item.route!);
          // }
          header: Container(
              height: 100,
              width: double.infinity,
              color: Colors.green.shade900,
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/marketdoLogo.png')),
          footer: Container(
              height: 50,
              width: double.infinity,
              color: Colors.green.shade900,
              child: Center(
                  child: Text(
                      DateTimeFormat.format(DateTime.now(),
                          format: AmericanDateFormats.dayOfWeek),
                      style: const TextStyle(color: Colors.white))))),
      body: SingleChildScrollView(child: _selectedScreen));

  logout() => showDialog(
      context: context,
      builder: (_) => confirmDialog(
          context,
          'LOGOUT',
          'Do you want to continue?',
          () async => await session.delete(key: 'session').then((value) =>
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PasswordScreen()),
                  (route) => false))));
}
