import 'package:flutter/material.dart';
import 'package:marketdo_admin/model/vendor_model.dart';

class VendorDetailsCard extends StatelessWidget {
  final Vendor? vendor;

  const VendorDetailsCard({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(vendor!.businessName!),
      content: SizedBox(
        height: 500,
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInImage(
                placeholder: const AssetImage('assets/images/placeholder.png'),
                image: NetworkImage(vendor!.logo!),
              ),
              const Divider(
                color: Colors.black12,
              ),
              FadeInImage(
                placeholder: const AssetImage('assets/images/placeholder.png'),
                image: NetworkImage(vendor!.shopImage!),
              ),
              const Divider(
                color: Colors.black12,
              ),
              Text('City: ${vendor!.city}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('State: ${vendor!.state}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('Country: ${vendor!.country}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('email: ${vendor!.email}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('landMark: ${vendor!.landMark}'),
              const Divider(
                color: Colors.black12,
              ),
              
              Text('mobile: ${vendor!.mobile}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('pinCode: ${vendor!.pinCode}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('taxRegistered: ${vendor!.taxRegistered}'),
              const Divider(
                color: Colors.black12,
              ),
              Text('tinNumber: ${vendor!.tinNumber}'),
              
              // Add any other details you want to display here
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
