// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:visprofiler/visprofiler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SDK initialization test', (WidgetTester tester) async {
    // Test SDK initialization instead of using non-existent constructor
    final plugin = Visprofiler.instance;
    final success = plugin.init('test-app-id', {'userId': 'test-user'});
    expect(success, true);
  });
}
