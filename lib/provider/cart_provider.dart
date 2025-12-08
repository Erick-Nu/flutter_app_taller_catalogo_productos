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
    notifyListeners(); 

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

  // Acción: Disminuir cantidad
  Future<void> decrementItem(String productId) async {
    final index = _items.indexWhere((item) => item.producto.id == productId);
    if (index == -1) return;

    // VALIDACIÓN: No permitir cantidad menor a 1
    if (_items[index].cantidad <= 1) {
      return; // Opcional: Podrías llamar a removeItem aquí si quisieras que bajar de 1 elimine.
    }

    // 1. Optimistic Update (Restamos localmente)
    _items[index].cantidad--;
    notifyListeners();

    // 2. Llamada al servicio (qty = -1 para restar)
    try {
      final response = await _service.addToCart(_items[index].producto, -1);
      
      if (!response.success) {
        // Rollback si falla
        _items[index].cantidad++; 
        _errorMessage = response.message;
        notifyListeners();
      }
    } catch (e) {
      // Rollback por error de red
      _items[index].cantidad++;
      _errorMessage = "Error de conexión";
      notifyListeners();
    }
  }

  // --- CORRECCIÓN AQUÍ ---
  // Acción: Eliminar (Con Optimistic Update)
  Future<void> removeItem(String productId) async {
    // 1. Buscamos el ítem y lo guardamos por si hay que restaurarlo (Rollback)
    final index = _items.indexWhere((item) => item.producto.id == productId);
    if (index == -1) return;
    
    final itemBackup = _items[index];

    // 2. Lo eliminamos LOCALMENTE de inmediato
    _items.removeAt(index);
    
    // 3. Notificamos. Esto actualiza el TOTAL y elimina el Dismissible del árbol al instante.
    notifyListeners(); 

    // 4. Llamamos al servicio en segundo plano (sin poner isLoading global para no bloquear)
    try {
      final response = await _service.removeFromCart(productId);
      
      if (!response.success) {
        // Si falla, REVERTIMOS el cambio (volvemos a poner el ítem)
        _items.insert(index, itemBackup);
        _errorMessage = response.message;
        notifyListeners();
      } else {
        // Si tiene éxito, sincronizamos con la verdad del servidor (opcional, pero recomendado)
        _items = response.data!;
        // No es necesario notificar de nuevo si los datos son iguales, 
        // pero asegura consistencia si el servidor hizo otros cambios.
        notifyListeners(); 
      }
    } catch (e) {
      // Error de red no controlado: Revertir
      _items.insert(index, itemBackup);
      _errorMessage = "Error de conexión";
      notifyListeners();
    }
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
  
  void clearError() {
    _errorMessage = null;
  }
}