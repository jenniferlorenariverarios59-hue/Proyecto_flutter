import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/product_repository.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pruebas de Glam Studio - Tienda de Maquillaje y Belleza', () {
    test('1. Modelo Product: categorías oficiales de maquillaje, tonos y serialización', () {
      expect(Product.officialCategories.length, 6);
      expect(Product.officialCategories.contains('Labiales'), true);
      expect(Product.officialCategories.contains('Bases y correctores'), true);
      expect(Product.officialCategories.contains('Sombras'), true);
      expect(Product.officialCategories.contains('Máscaras de pestañas'), true);
      expect(
        Product.officialCategories.contains('Productos para el cuidado facial'),
        true,
      );
      expect(Product.officialCategories.contains('Accesorios de belleza'), true);

      final p1 = Product(
        id: 'test-lip-1',
        name: 'Labial Velvet Rouge',
        brand: 'Maison Lumière',
        description: 'Labial mate aterciopelado con ácido hialurónico',
        price: 68000.0,
        stock: 15,
        category: 'Labiales',
        sku: 'GLM-LIP-TEST',
        shadeName: 'Rouge Paris',
        shadeHex: '#8B1E2F',
      );

      expect(p1.status, 'in-stock');
      expect(p1.statusText, '15 disponibles');

      final p2 = p1.copyWith(stock: 5);
      expect(p2.status, 'low-stock');

      final p3 = p1.copyWith(stock: 0);
      expect(p3.status, 'out-of-stock');

      // Serialización JSON
      final json = p1.toJson();
      final fromJson = Product.fromJson(json);
      expect(fromJson.name, 'Labial Velvet Rouge');
      expect(fromJson.brand, 'Maison Lumière');
      expect(fromJson.shadeName, 'Rouge Paris');
      expect(fromJson.price, 68000.0);
    });

    test('2. Repositorio: adición, edición y cálculo de inventario de belleza', () async {
      final repo = ProductRepository();
      repo.setOfflineMode(true);
      final initialProducts = await repo.getProducts();
      final initialCount = initialProducts.length;
      final initialValue = repo.totalInventoryValue;

      final newProd = Product(
        id: 'test-serum-new',
        name: 'Sérum Iluminador Vitamina C',
        brand: 'Pure Derm',
        description: 'Sérum antioxidante facial',
        price: 90000.0,
        stock: 10,
        category: 'Productos para el cuidado facial',
        sku: 'GLM-SKN-TEST',
      );

      final result = await repo.addProduct(newProd);
      expect(result.success, true);
      expect(result.product.name, 'Sérum Iluminador Vitamina C');

      final updatedProducts = await repo.getProducts();
      expect(updatedProducts.length, initialCount + 1);
      expect(repo.totalInventoryValue, initialValue + (90000.0 * 10));
    });

    test('3. Carrito de Compras: tonos seleccionados, cupón GLAM10 y total', () {
      final cart = CartService();
      cart.clear();

      final p = Product(
        id: 'test-cart-prod',
        name: 'Paleta de Sombras Rose Quartz',
        brand: 'Éclat Paris',
        description: '12 tonos pigmentados',
        price: 160000.0,
        stock: 5,
        category: 'Sombras',
        sku: 'GLM-EYE-099',
      );

      cart.addToCart(
        p,
        shadeName: 'Rose Gold',
        shadeHex: '#C88A82',
      );
      expect(cart.totalItemsCount, 1);
      expect(cart.subtotal, 160000.0);
      expect(cart.shipping, 0.0); // Envío gratis para >= $150.000 COP

      final applied = cart.applyCoupon('GLAM10');
      expect(applied, true);
      expect(cart.discountAmount, 16000.0);
      expect(cart.total, 144000.0);

      cart.clear();
      expect(cart.totalItemsCount, 0);
    });

    test('4. Autenticación: registro de usuario, inicio y cierre de sesión', () async {
      final auth = AuthService();
      await auth.logout();
      expect(auth.isAuthenticated, false);

      final reg = await auth.register(
        name: 'Camila Gómez',
        email: 'camila.test@glamstudio.co',
        password: 'password123',
        phone: '3105551234',
        city: 'Medellín',
        skinType: 'Mixta',
      );

      expect(reg.success, true);
      expect(auth.isAuthenticated, true);
      expect(auth.currentUser?.name, 'Camila Gómez');

      await auth.logout();
      expect(auth.isAuthenticated, false);

      final login = await auth.login(
        email: 'camila.test@glamstudio.co',
        password: 'password123',
      );
      expect(login.success, true);
      expect(auth.isAuthenticated, true);
    });

    testWidgets(
      '5. UI Responsive sin desbordamientos (RenderFlex) ni errores de ListTile en móvil, tablet y escritorio',
      (WidgetTester tester) async {
        final repo = ProductRepository();
        repo.setOfflineMode(true);
        await repo.getProducts();

        final auth = AuthService();
        await auth.login(
          email: 'admin@glamstudio.com',
          password: 'admin123',
        );

        final cart = CartService();
        if (repo.products.isNotEmpty) {
          cart.addToCart(repo.products.first, quantity: 2);
        }

        final sizes = <Size>[
          const Size(360, 640), // Teléfono Android compacto
          const Size(390, 520), // Vista móvil baja
          const Size(768, 1024), // Tablet
          const Size(1024, 540), // Portátil compacto
          const Size(1440, 900), // Escritorio Web
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(const TechStoreApp());
          await tester.pump(const Duration(milliseconds: 250));
          expect(tester.takeException(), isNull);
        }

        await tester.binding.setSurfaceSize(null);
      },
    );
  });
}
