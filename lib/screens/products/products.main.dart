import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marketdo_admin/screens/products/by.category/clothing.dart';
import 'package:marketdo_admin/screens/products/by.category/food.dart';
import 'package:marketdo_admin/screens/products/by.category/household.dart';
import 'package:marketdo_admin/screens/products/by.category/others.dart';
import 'package:marketdo_admin/screens/products/by.category/personalcare.dart';
import 'package:marketdo_admin/screens/products/by.category/school.office.dart';

class ProductScreen extends StatefulWidget {
  static const String id = 'product-screen';
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
  }

  bool? selectedButton;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 6,
        child: SizedBox(
            height: MediaQuery.of(context).size.height - 56,
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Container(
                  color: Colors.green.shade900,
                  child: TabBar(
                      controller: tabController,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.yellow,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(
                            text: 'Clothing & Accessories',
                            icon: FaIcon(FontAwesomeIcons.shirt)),
                        Tab(
                            text: 'Food & Beverages',
                            icon: FaIcon(FontAwesomeIcons.utensils)),
                        Tab(
                            text: 'Household Items',
                            icon: FaIcon(FontAwesomeIcons.couch)),
                        Tab(
                            text: 'Personal Care',
                            icon: FaIcon(FontAwesomeIcons.handSparkles)),
                        Tab(
                            text: 'School & Office Supplies',
                            icon: FaIcon(FontAwesomeIcons.folderOpen)),
                        Tab(
                            text: 'Others',
                            icon: FaIcon(FontAwesomeIcons.ellipsis))
                      ])),
              Expanded(
                  child: TabBarView(controller: tabController, children: const [
                ClothingAndAccessories(),
                FoodAndBeverages(),
                HouseholdItems(),
                PersonalCare(),
                SchoolAndOfficeSupplies(),
                Others()
              ]))
            ])));
  }
}
