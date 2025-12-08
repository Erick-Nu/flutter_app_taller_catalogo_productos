import 'package:flutter_test/flutter_test.dart';
import 'package:catalogo_productos/main.dart';

void main() {
  testWidgets('HomeScreen muestra el título y destacados', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    await tester.pump();

    expect(find.text('Mi Tienda'), findsOneWidget);
    expect(find.text('Productos Destacados'), findsOneWidget);
  });
}
