import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/cart_item.dart';
import '../services/mock_cart_service.dart';

class CartProvider extends ChangeNotifier {
  final MockCartService _service = MockCartService();
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get descuento => subtotal > 100 ? subtotal * 0.10 : 0;
  double get impuestos => (subtotal - descuento) * 0.12;
  double get total => subtotal - descuento + impuestos;

  // Cargar estado inicial del carrito
  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getCart();

    if (response.success && response.data != null) {
      _items = response.data!;
    } else {
      _errorMessage = response.message ?? "No se pudo cargar el carrito";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Acción: Agregar
  Future<bool> addItem(Producto producto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Actualiza UI para mostrar spinner

    final response = await _service.addToCart(producto, 1);

    _isLoading = false;
    if (response.success) {
      _items = response.data!;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Acción: Eliminar
  Future<void> removeItem(String productId) async {
    _isLoading = true;
    notifyListeners();
    final response = await _service.removeFromCart(productId);
    if (response.success) {
      _items = response.data!;
    } else {
      _errorMessage = response.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    final response = await _service.clearCart();
    if (response.success) {
      _items = [];
    } else {
      _errorMessage = response.message ?? "No se pudo vaciar el carrito";
    }

    _isLoading = false;
    notifyListeners();
  }
  
  // Limpiar error para snackbars
  void clearError() {
    _errorMessage = null;
    // No notificamos para evitar rebuilds innecesarios
  }
}