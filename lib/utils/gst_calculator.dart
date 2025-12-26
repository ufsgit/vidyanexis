class GSTCalculator {
  // GST Rates
  static const double GST_5 = 5.0;
  static const double GST_12 = 12.0;
  static const double GST_18 = 18.0;
  static const double GST_28 = 28.0;

  /// Calculate GST for Exclusive pricing (GST added to base amount)
  static Map<String, double> calculateExclusiveGST({
    required double baseAmount,
    required double gstRate,
    required bool isInterState, // true for IGST, false for CGST+SGST
  }) {
    double gstAmount = (baseAmount * gstRate) / 100;
    double totalAmount = baseAmount + gstAmount;

    if (isInterState) {
      // Inter-state transaction - IGST
      return {
        'baseAmount': baseAmount,
        'igst': gstAmount,
        'cgst': 0.0,
        'sgst': 0.0,
        'totalGST': gstAmount,
        'totalAmount': totalAmount,
      };
    } else {
      // Intra-state transaction - CGST + SGST
      double cgst = gstAmount / 2;
      double sgst = gstAmount / 2;

      return {
        'baseAmount': baseAmount,
        'igst': 0.0,
        'cgst': cgst,
        'sgst': sgst,
        'totalGST': gstAmount,
        'totalAmount': totalAmount,
      };
    }
  }

  /// Calculate GST for Inclusive pricing (GST included in the total amount)
  static Map<String, double> calculateInclusiveGST({
    required double totalAmount,
    required double gstRate,
    required bool isInterState, // true for IGST, false for CGST+SGST
  }) {
    double baseAmount = totalAmount / (1 + (gstRate / 100));
    double gstAmount = totalAmount - baseAmount;

    if (isInterState) {
      // Inter-state transaction - IGST
      return {
        'baseAmount': baseAmount,
        'igst': gstAmount,
        'cgst': 0.0,
        'sgst': 0.0,
        'totalGST': gstAmount,
        'totalAmount': totalAmount,
      };
    } else {
      // Intra-state transaction - CGST + SGST
      double cgst = gstAmount / 2;
      double sgst = gstAmount / 2;

      return {
        'baseAmount': baseAmount,
        'igst': 0.0,
        'cgst': cgst,
        'sgst': sgst,
        'totalGST': gstAmount,
        'totalAmount': totalAmount,
      };
    }
  }

  /// Calculate GST with quantity
  static Map<String, double> calculateGSTWithQuantity({
    required double unitPrice,
    required int quantity,
    required double gstRate,
    required bool isInterState,
    required bool isInclusive, // true for inclusive, false for exclusive
  }) {
    double totalUnitAmount = unitPrice * quantity;

    if (isInclusive) {
      return calculateInclusiveGST(
        totalAmount: totalUnitAmount,
        gstRate: gstRate,
        isInterState: isInterState,
      );
    } else {
      return calculateExclusiveGST(
        baseAmount: totalUnitAmount,
        gstRate: gstRate,
        isInterState: isInterState,
      );
    }
  }

  /// Format amount to 2 decimal places
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Get GST breakdown as formatted string
  static String getGSTBreakdown(Map<String, double> gstData) {
    StringBuffer breakdown = StringBuffer();

    breakdown.writeln('Base Amount: ₹${formatAmount(gstData['baseAmount']!)}');

    if (gstData['igst']! > 0) {
      breakdown.writeln('IGST: ₹${formatAmount(gstData['igst']!)}');
    } else {
      breakdown.writeln('CGST: ₹${formatAmount(gstData['cgst']!)}');
      breakdown.writeln('SGST: ₹${formatAmount(gstData['sgst']!)}');
    }

    breakdown.writeln('Total GST: ₹${formatAmount(gstData['totalGST']!)}');
    breakdown
        .writeln('Total Amount: ₹${formatAmount(gstData['totalAmount']!)}');

    return breakdown.toString();
  }
}

// Example usage and testing
void main() {
  print('=== GST Calculator Examples ===\n');

  // Example 1: Exclusive GST calculation (Inter-state)
  print('1. Exclusive GST - Inter-state (IGST)');
  var result1 = GSTCalculator.calculateExclusiveGST(
    baseAmount: 1000.0,
    gstRate: 18.0,
    isInterState: true,
  );
  print(GSTCalculator.getGSTBreakdown(result1));

  // Example 2: Exclusive GST calculation (Intra-state)
  print('2. Exclusive GST - Intra-state (CGST + SGST)');
  var result2 = GSTCalculator.calculateExclusiveGST(
    baseAmount: 1000.0,
    gstRate: 18.0,
    isInterState: false,
  );
  print(GSTCalculator.getGSTBreakdown(result2));

  // Example 3: Inclusive GST calculation
  print('3. Inclusive GST - Inter-state (IGST)');
  var result3 = GSTCalculator.calculateInclusiveGST(
    totalAmount: 1180.0,
    gstRate: 18.0,
    isInterState: true,
  );
  print(GSTCalculator.getGSTBreakdown(result3));

  // Example 4: GST calculation with quantity
  print('4. GST with Quantity - Intra-state');
  var result4 = GSTCalculator.calculateGSTWithQuantity(
    unitPrice: 100.0,
    quantity: 5,
    gstRate: 12.0,
    isInterState: false,
    isInclusive: false,
  );
  print(GSTCalculator.getGSTBreakdown(result4));
}
