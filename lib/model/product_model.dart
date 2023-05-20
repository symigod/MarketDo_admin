class Product {
  Product ({
      this.productName,
    this.description,
    this.brand,
    this.otherDetails,
    this.unit,
     this.approved}
  );

  Product.fromJson(Map<String, Object?> json)
    : this(
        
        productName: json['productName']! as String,     
        description: json['description']==null ? null : json['description']! as String,
        brand: json['brand']==null ? null : json['brand']! as String,
        otherDetails: json['otherDetails']==null? null : json['otherDetails']! as String,
        unit: json['unit'] == null ? null : json['unit']! as String,
        approved: json['approved']! as bool,

      );
   
    final String? productName; 
    final String? description;
    final String? brand;
    final String? otherDetails;
    final String? unit;
    final bool? approved;

  Map<String, Object?> toJson() {
    return {
      
    'productName': productName, 
     'description': description,
     'brand': brand,
     'otherDetails': otherDetails,
     'unit': unit,
     'approved': approved,
    };
  }

}