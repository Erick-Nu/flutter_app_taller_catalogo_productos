class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
  });
}

// Datos de ejemplo con IMÁGENES REALES (Unsplash)
List<Producto> productosEjemplo = [
  Producto(
    id: '1',
    nombre: 'Laptop Pro',
    descripcion: 'Laptop de alto rendimiento para profesionales creativos.',
    precio: 1299.99,
    imagenUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '2',
    nombre: 'Auriculares Noise-C',
    descripcion: 'Auriculares inalámbricos con cancelación de ruido activa.',
    precio: 89.99,
    imagenUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '3',
    nombre: 'Smartwatch Sport',
    descripcion: 'Reloj inteligente con monitor cardíaco y GPS integrado.',
    precio: 249.99,
    imagenUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '4',
    nombre: 'Cámara Mirrorless',
    descripcion: 'Cámara digital profesional 4K con lentes intercambiables.',
    precio: 599.99,
    imagenUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80',
    categoria: 'Fotografía',
  ),
  Producto(
    id: '5',
    nombre: 'Teclado Mecánico',
    descripcion: 'Teclado gaming RGB con switches azules táctiles.',
    precio: 129.98,
    imagenUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80',
    categoria: 'Accesorios',
  ),
  Producto(
    id: '6',
    nombre: 'Mouse Ergonómico',
    descripcion: 'Mouse inalámbrico vertical para reducir la fatiga.',
    precio: 49.99,
    imagenUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&q=80',
    categoria: 'Accesorios',
  ),
];