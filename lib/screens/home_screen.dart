import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../widgets/barra_navegacion.dart';

// HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceNavegacion = 0;
  int _indiceCategoriaSeleccionada = 0;

  final List<String> categorias = ['Todos', 'Electrónica', 'Fotografía', 'Accesorios'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _buildContenidoPrincipal(),
          ),
          BarraNavegacion(
            indiceActual: _indiceNavegacion,
            onTap: (indice) {
              setState(() {
                _indiceNavegacion = indice;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoPrincipal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool esDesktop = constraints.maxWidth >= 900;

        if (esDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: _buildSidebar(),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: _buildScrollableBody(mostrarCategoriasHorizontales: false),
              ),
            ],
          );
        } else {
          return _buildScrollableBody(mostrarCategoriasHorizontales: true);
        }
      },
    );
  }

  Widget _buildScrollableBody({required bool mostrarCategoriasHorizontales}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEncabezado(),
          const SizedBox(height: 20),
          if (mostrarCategoriasHorizontales) ...[
            _buildCategoriasHorizontal(),
            const SizedBox(height: 20),
          ],

          const Text(
            'Productos Destacados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGridProductos(),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Categorías",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final esSeleccionado = index == _indiceCategoriaSeleccionada;
                return ListTile(
                  leading: Icon(
                    index == 0 ? Icons.grid_view : Icons.label_outline,
                    color: esSeleccionado ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    categorias[index],
                    style: TextStyle(
                      color: esSeleccionado ? Colors.blue : Colors.black87,
                      fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: esSeleccionado,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  onTap: () {
                    setState(() {
                      _indiceCategoriaSeleccionada = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.store, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Mi Tienda', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Text('${screenWidth.toInt()}px', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {}),
      ],
    );
  }

  Widget _buildEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(child: _buildBannerPrincipal()),
              const SizedBox(width: 16),
              Expanded(child: _buildBannerSecundario()),
            ],
          );
        }
        return _buildBannerPrincipal();
      },
    );
  }

  Widget _buildBannerPrincipal() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[400]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¡Ofertas de Temporada!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Hasta 50% de descuento', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text('Ver ofertas'),
                ),
              ],
            ),
          ),
          Positioned(right: 20, bottom: 20, child: Icon(Icons.local_offer, size: 80, color: Colors.white.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildBannerSecundario() {
    return Container(
      height: 150,
      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 40, color: Colors.orange[700]),
            const SizedBox(height: 8),
            Text('Envío Gratis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
            Text('En compras +\$50', style: TextStyle(color: Colors.orange[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriasHorizontal() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final esSeleccionado = index == _indiceCategoriaSeleccionada;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _indiceCategoriaSeleccionada = index;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: esSeleccionado ? Colors.blue : Colors.white,
                foregroundColor: esSeleccionado ? Colors.white : Colors.black,
                elevation: esSeleccionado ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: esSeleccionado ? Colors.blue : Colors.grey[300]!),
                ),
              ),
              child: Text(categorias[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridProductos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columnas;
        double childAspectRatio;

        if (constraints.maxWidth >= 1100) {
          columnas = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 800) {
          columnas = 3;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 550) {
          columnas = 3;
          childAspectRatio = 0.7;
        } else {
          columnas = 2;
          childAspectRatio = 0.65;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: productosEjemplo.length,
          itemBuilder: (context, index) {
            return ProductoCard(producto: productosEjemplo[index]);
          },
        );
      },
    );
  }
}