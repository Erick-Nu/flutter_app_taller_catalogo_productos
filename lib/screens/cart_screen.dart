import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../provider/cart_provider.dart';
import '../widgets/top_snackbar.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onGoHome;

  const CartScreen({super.key, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        // 1. Loading
        if (cart.isLoading && cart.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Empty State
        if (cart.items.isEmpty) {
          return _buildEmptyState(context);
        }

        // 3. Layout Responsivo
        return LayoutBuilder(
          builder: (context, constraints) {
            // Si el ancho es mayor a 800px (Tablet/Desktop)
            if (constraints.maxWidth >= 800) {
              return _buildDesktopLayout(context, cart);
            }
            // Si es Móvil
            return _buildMobileLayout(context, cart);
          },
        );
      },
    );
  }

  // --- LAYOUT MÓVIL (Vertical) ---
  Widget _buildMobileLayout(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              return _buildCartItem(context, cart.items[index], cart);
            },
          ),
        ),
        // En móvil, el resumen va pegado abajo
        _buildOrderSummary(context, cart, isDesktop: false),
      ],
    );
  }

  // --- LAYOUT ESCRITORIO (Dos Columnas) ---
  Widget _buildDesktopLayout(BuildContext context, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(32.0), // Más margen en desktop
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUMNA IZQUIERDA: Lista de productos (Ocupa más espacio)
          Expanded(
            flex: 7, // 70% del espacio
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCartItem(context, cart.items[index], cart);
              },
            ),
          ),
          
          const SizedBox(width: 32), // Separación entre columnas

          // COLUMNA DERECHA: Resumen de Compra (Fijo como tarjeta)
          Expanded(
            flex: 4, // 40% del espacio
            child: SingleChildScrollView(
              child: _buildOrderSummary(context, cart, isDesktop: true),
            ),
          ),
        ],
      ),
    );
  }

  // --- ESTADO VACÍO ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: 80, color: Colors.blue[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '¡Descubre productos increíbles y agrégalos aquí!',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onGoHome,
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Tienda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- ITEM DE CARRITO ---
  Widget _buildCartItem(
      BuildContext context, CartItem item, CartProvider cart) {
    return Dismissible(
      key: Key(item.producto.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 0), // El margen lo maneja el layout
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Eliminar",
                style: TextStyle(
                    color: Colors.red[700], fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.red[700]),
          ],
        ),
      ),
      onDismissed: (_) async {
        await cart.removeItem(item.producto.id);

        if (context.mounted) {
          if (cart.errorMessage != null) {
            showTopSnackBar(context, cart.errorMessage!, isError: true);
            cart.clearError();
          } else {
            showTopSnackBar(context, "${item.producto.nombre} eliminado");
          }
        }
      },
      child: Container(
        // En desktop usamos separatorBuilder, en mobile margin. 
        // Para simplificar, usamos un container con decoración simple.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[50],
                  child: Image.network(
                    item.producto.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.producto.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('\$${item.producto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    // Controles de cantidad
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildQuantityControls(context, cart, item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CONTROLES DE CANTIDAD ---
  Widget _buildQuantityControls(
      BuildContext context, CartProvider cart, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleButton(
            icon: Icons.remove,
            onTap: cart.isLoading || item.cantidad <= 1
                ? null
                : () async {
                    await cart.decrementItem(item.producto.id);
                    if (cart.errorMessage != null && context.mounted) {
                      showTopSnackBar(context, cart.errorMessage!, isError: true);
                      cart.clearError();
                    }
                  },
            isEnabled: item.cantidad > 1,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.cantidad}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildCircleButton(
            icon: Icons.add,
            isAdd: true,
            onTap: cart.isLoading
                ? null
                : () async {
                    bool ok = await cart.addItem(item.producto);
                    if (!ok && context.mounted) {
                      showTopSnackBar(context, cart.errorMessage ?? "Error", isError: true);
                      cart.clearError();
                    }
                  },
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool isAdd = false,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAdd ? Colors.black : Colors.transparent,
            border: isAdd ? null : Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isAdd
                ? Colors.white
                : (isEnabled ? Colors.black : Colors.grey[300]),
          ),
        ),
      ),
    );
  }

  // --- RESUMEN DE COMPRA (Adaptable) ---
  Widget _buildOrderSummary(BuildContext context, CartProvider cart, {required bool isDesktop}) {
    // Si es desktop, parece una tarjeta flotante. Si es móvil, parece un BottomSheet.
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        // Bordes: En Desktop todos redondeados, en Móvil solo los de arriba
        borderRadius: isDesktop 
            ? BorderRadius.circular(24) 
            : const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // En desktop no necesitamos safe area arriba
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
               const Text("Resumen del Pedido", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               const SizedBox(height: 20),
            ],
            
            _buildSummaryRow('Subtotal', cart.subtotal),
            if (cart.descuento > 0)
              _buildSummaryRow('Descuento', -cart.descuento, isDiscount: true),
            _buildSummaryRow('Impuestos (12%)', cart.impuestos),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                InkWell(
                  onTap: cart.isLoading
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('¿Vaciar carrito?'),
                              content: const Text('Se eliminarán todos los ítems.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Vaciar',
                                        style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) await cart.clearCart();
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: cart.isLoading ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Pagar Ahora',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            '${isDiscount ? "-" : ""}\$${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
                color: isDiscount ? Colors.green[700] : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}