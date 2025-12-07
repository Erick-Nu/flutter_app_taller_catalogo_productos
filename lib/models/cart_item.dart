import 'producto.dart';

class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({
    required this.producto, 
    this.cantidad = 1
  });

  // Métodos
  double get total => producto.precio * cantidad;
}