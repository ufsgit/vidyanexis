import 'package:flutter_test/flutter_test.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quotation Conditional Fields Tests', () {
    late CustomerDetailsProvider provider;

    setUp(() {
      provider = CustomerDetailsProvider();
    });

    test('isResidential returns true when selectedQuotationType == 1', () {
      provider.selectedQuotationType = 1;
      provider.quotationTypeController.text = 'Residential';

      expect(provider.isResidential, isTrue);
      expect(provider.isCommercial, isFalse);
    });

    test('isCommercial returns true when selectedQuotationType == 2', () {
      provider.selectedQuotationType = 2;
      provider.quotationTypeController.text = 'Commercial';

      expect(provider.isCommercial, isTrue);
      expect(provider.isResidential, isFalse);
    });

    test('Switching Residential -> Commercial -> Residential updates state correctly', () {
      // Step 1: Select Residential
      provider.selectedQuotationType = 1;
      provider.quotationTypeController.text = 'Residential';
      expect(provider.isResidential, isTrue);
      expect(provider.isCommercial, isFalse);

      // Step 2: Switch to Commercial
      provider.selectedQuotationType = 2;
      provider.quotationTypeController.text = 'Commercial';
      expect(provider.isCommercial, isTrue);
      expect(provider.isResidential, isFalse);

      // Step 3: Switch back to Residential
      provider.selectedQuotationType = 1;
      provider.quotationTypeController.text = 'Residential';
      expect(provider.isResidential, isTrue);
      expect(provider.isCommercial, isFalse);
    });

    test('Fallback by name check when quotation type id is 0 but text contains Residential/Commercial', () {
      provider.selectedQuotationType = 0;
      provider.quotationTypeController.text = 'Residential Solar';
      expect(provider.isResidential, isTrue);
      expect(provider.isCommercial, isFalse);

      provider.quotationTypeController.text = 'Commercial Rooftop';
      expect(provider.isCommercial, isTrue);
      expect(provider.isResidential, isFalse);
    });

    test('PV Solar Specification controllers retain values on provider', () {
      provider.plantCapacityController.text = '5 kW';
      provider.moduleTechnologiesController.text = 'Mono PERC';
      provider.mountingStructureTechnologiesController.text = 'GI structure';
      provider.projectSchemeController.text = 'On-Grid';
      provider.powerEvacuationController.text = 'LT 415V';
      provider.areaApproximateController.text = '500 sq.ft';
      provider.solarPlantOutputConnectionController.text = 'Main DB';
      provider.schemeController.text = 'Subsidy';

      expect(provider.plantCapacityController.text, '5 kW');
      expect(provider.moduleTechnologiesController.text, 'Mono PERC');
      expect(provider.mountingStructureTechnologiesController.text, 'GI structure');
      expect(provider.projectSchemeController.text, 'On-Grid');
      expect(provider.powerEvacuationController.text, 'LT 415V');
      expect(provider.areaApproximateController.text, '500 sq.ft');
      expect(provider.solarPlantOutputConnectionController.text, 'Main DB');
      expect(provider.schemeController.text, 'Subsidy');
    });
  });
}
