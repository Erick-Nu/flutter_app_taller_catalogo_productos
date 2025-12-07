import 'dart:math';
import '../models/producto.dart';
import '../models/cart_item.dart';

// Respuesta genérica del servidor
class ServiceResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ServiceResponse({required this.success, this.data, this.message});
}

class MockCartService {
  // Base de datos "en memoria" del servidor simulado
  final List<CartItem> _serverCart = [];
  final Random _rng = Random();

  // Simula latencia de red (1 a 2 segundos)
  Future<void> _simulateDelay() async {
    int ms = 1000 + _rng.nextInt(1000); // 1000ms a 2000ms
    await Future.delayed(Duration(milliseconds: ms));
  }

  // Simula fallos aleatorios (20%)
  void _checkRandomErrors() {
    if (_rng.nextDouble() < 0.2) {
      List<String> errores = [
        "Stock insuficiente",
        "Error de conexión 503",
        "Producto no disponible",
        "Sesión expirada"
      ];
      throw Exception(errores[_rng.nextInt(errores.length)]);
    }
  }

  // FUNCIONALIDAD 1: AGREGAR
  Future<ServiceResponse<List<CartItem>>> addToCart(Producto producto, int qty) async {
    await _simulateDelay();
    
    try {
      _checkRandomErrors();

      // Buscar si ya existe
      int index = _serverCart.indexWhere((item) => item.producto.id == producto.id);
      
      if (index != -1) {
        // Validar stock ficticio (max 10)
        if (_serverCart[index].cantidad + qty > 10) {
          return ServiceResponse(success: false, message: "No hay suficiente stock (Max 10)");
        }
        _serverCart[index].cantidad += qty;
      } else {
        _serverCart.add(CartItem(producto: producto, cantidad: qty));
      }

      return ServiceResponse(success: true, data: List.from(_serverCart)); // Retorna copia
    } catch (e) {
      return ServiceResponse(success: false, message: e.toString().replaceAll("Exception: ", ""));
    }
  }

  // FUNCIONALIDAD 2: ELIMINAR
  Future<ServiceResponse<List<CartItem>>> removeFromCart(String productId) async {
    await _simulateDelay();
    try {
      _checkRandomErrors();
      _serverCart.removeWhere((item) => item.producto.id == productId);
      return ServiceResponse(success: true, data: List.from(_serverCart));
    } catch (e) {
      return ServiceResponse(success: false, message: e.toString());
    }
  }
  
  // FUNCIONALIDAD 3: OBTENER (GET)
  Future<ServiceResponse<List<CartItem>>> getCart() async {
    await _simulateDelay(); // Simula carga inicial
    return ServiceResponse(success: true, data: List.from(_serverCart));
  }
  
  // FUNCIONALIDAD 4: VACIAR
  Future<ServiceResponse<bool>> clearCart() async {
    await _simulateDelay();
    _serverCart.clear();
    return ServiceResponse(success: true, data: true);
  }
}