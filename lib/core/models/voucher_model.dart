class VoucherModel {
  final String id;
  final String name;
  final String description;
  final VoucherType type;
  final double value;
  final double? minOrderAmount;
  final bool requiresThanhHoa;

  VoucherModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.requiresThanhHoa = false,
  });

  // Check if voucher can be applied
  bool canBeApplied(double subtotal, {String? userAddress}) {
    // 36% discount for Thanh Hoa customers - anyone can apply
    if (requiresThanhHoa) {
      return true;
    }
    
    // Check minimum order amount requirement
    if (minOrderAmount != null) {
      return subtotal >= minOrderAmount!;
    }
    
    // Other vouchers without conditions can be applied
    return true;
  }

  // Calculate discount amount
  double calculateDiscount(double subtotal) {
    switch (type) {
      case VoucherType.percentage:
        return subtotal * (value / 100);
      case VoucherType.fixed:
        return value;
      case VoucherType.freeShipping:
        return 0; // Free shipping means $0 delivery fee
    }
  }
}

enum VoucherType {
  percentage,    // 36%
  fixed,         // $2 off
  freeShipping,  // Free shipping
}

