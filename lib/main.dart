import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ShelfFinderApp());
}

// -----------------------------------------------------------------------------
// GESTOR DE DATOS CON PERSISTENCIA REAL (SharedPreferences)
// -----------------------------------------------------------------------------
class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  List<Map<String, dynamic>> globalProducts = [
    {
      'name': 'Filtro de Aceite Gonher GP-42',
      'code': '750123456789',
      'anaquel': 'A1',
      'piso': 'P2',
      'stock': 15,
      'precio': '\$180.00',
    },
    {
      'name': 'Balata Delantera Brembo B-102',
      'code': '750987654321',
      'anaquel': 'A3',
      'piso': 'P4',
      'stock': 8,
      'precio': '\$650.00',
    },
    {
      'name': 'Bujía Iridium Ngk Lzkr6b',
      'code': '750111222333',
      'anaquel': 'B2',
      'piso': 'P1',
      'stock': 30,
      'precio': '\$220.00',
    },
  ];

  // Cargar productos guardados del navegador
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsString = prefs.getString('saved_products');
    if (productsString != null) {
      final List<dynamic> decodedList = jsonDecode(productsString);
      globalProducts = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  // Guardar productos en la memoria local de Edge
  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(globalProducts);
    await prefs.setString('saved_products', encodedList);
  }
}

class ShelfFinderApp extends StatelessWidget {
  const ShelfFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShelfFinder Gto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B365D),
          primary: const Color(0xFF1B365D),
          secondary: const Color(0xFF4A5568),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Pantalla de carga para leer memoria local
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE CARGA INICIAL (Carga los datos guardados)
// -----------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await AppData().loadProducts();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1B365D),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 1: INICIO / SELECCIÓN DE ROL + CONTRASEÑA DE ADMIN
// -----------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'Surtidor de Almacén';
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _selectedRole == 'Administrador';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: Color(0xFF1B365D),
              ),
              const SizedBox(height: 16),
              const Text(
                'ShelfFinder Gto',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
              ),
              const Text(
                'Localizador de Productos en Anaquel y Piso',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona tu Rol:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Surtidor de Almacén',
                            child: Text('Surtidor de Almacén'),
                          ),
                          DropdownMenuItem(
                            value: 'Empleado de Mostrador',
                            child: Text('Empleado de Mostrador (Vendedor)'),
                          ),
                          DropdownMenuItem(
                            value: 'Administrador',
                            child: Text('Administrador de Inventario'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRole = val);
                          }
                        },
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña de Administrador',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B365D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (isAdmin && _passwordController.text != 'admin123') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contraseña incorrecta (Usa: admin123)'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainNavigationScreen(
                                  userRole: _selectedRole,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CONTENEDOR PRINCIPAL CON BARRA DE NAVEGACIÓN INFERIOR
// -----------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  final String userRole;
  const MainNavigationScreen({super.key, required this.userRole});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(userRole: widget.userRole),
      const MapScreen(),
      ProfileScreen(userRole: widget.userRole),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B365D),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Plano Almacén',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 2: BUSCADOR PRINCIPAL (HOME)
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final String userRole;
  const HomeScreen({super.key, required this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userRole == 'Administrador';
    final products = AppData().globalProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador (${widget.userRole})'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto o código...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365D),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Escanear código de barras')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catálogo de Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isAdmin)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo Producto'),
                    onPressed: () async {
                      final newProd = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                      if (newProd != null) {
                        setState(() {
                          AppData().globalProducts.add(newProd);
                          AppData().saveProducts(); // <--- Guarda en Edge
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto agregado y guardado con éxito'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final prod = products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEDF2F7),
                        child: Icon(Icons.view_in_ar, color: Color(0xFF1B365D)),
                      ),
                      title: Text(
                        prod['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Código: ${prod['code']} | Precio: ${prod['precio']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B365D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${prod['anaquel']}, ${prod['piso']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productData: prod,
                              userRole: widget.userRole,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 3: FICHA DE UBICACIÓN Y PERMISOS POR ROL
// -----------------------------------------------------------------------------
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String userRole;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.userRole,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int stock;

  @override
  void initState() {
    super.initState();
    stock = widget.productData['stock'] is int
        ? widget.productData['stock']
        : int.tryParse(widget.productData['stock'].toString().split(' ')[0]) ?? 10;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSurtidor = widget.userRole == 'Surtidor de Almacén';
    final bool isAdmin = widget.userRole == 'Administrador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del Producto'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1B365D),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      'UBICACIÓN EXACTA',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ANAQUEL ${widget.productData['anaquel']}, PISO ${widget.productData['piso']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productData['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Código de Barras:'),
                        Text(
                          widget.productData['code'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio:'),
                        Text(
                          widget.productData['precio'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Existencias Disponibles:'),
                        Row(
                          children: [
                            Text(
                              '$stock unidades',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (isSurtidor || isAdmin) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    stock++;
                                    widget.productData['stock'] = stock;
                                    AppData().saveProducts(); // <--- Guarda cambios de stock en Edge
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Stock actualizado y guardado'),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF4A5568),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.map),
              label: const Text('Ver Ubicación en Croquis del Almacén'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      highlightAnaquel: widget.productData['anaquel'],
                    ),
                  ),
                );
              },
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Reubicar Producto (Cambiar Coordenada)'),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RelocateScreen(
                        productData: widget.productData,
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.blue.shade800,
                ),
                icon: const Icon(Icons.attach_money),
                label: const Text('Cambiar Precio del Producto'),
                onPressed: () async {
                  final nuevoPrecio = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPriceScreen(
                        currentPrice: widget.productData['precio'],
                      ),
                    ),
                  );
                  if (nuevoPrecio != null) {
                    setState(() {
                      widget.productData['precio'] = nuevoPrecio;
                      AppData().saveProducts(); // <--- Guarda precio en Edge
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Precio actualizado y guardado'),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 4: CROQUIS / MAPA DE ANAQUELES
// -----------------------------------------------------------------------------
class MapScreen extends StatelessWidget {
  final String? highlightAnaquel;

  const MapScreen({super.key, this.highlightAnaquel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plano General del Almacén'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (highlightAnaquel != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Resaltando posición del Anaquel $highlightAnaquel',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFEDF2F7),
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: List.generate(9, (index) {
                    final label =
                        'Anaquel ${String.fromCharCode(65 + (index ~/ 3))}${index % 3 + 1}';
                    final isSelected = highlightAnaquel != null &&
                        label.contains(highlightAnaquel!);

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.redAccent : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1B365D),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 5: MÓDULO DE REUBICACIÓN DE MERCANCÍA (SOLO ADMIN)
// -----------------------------------------------------------------------------
class RelocateScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const RelocateScreen({super.key, required this.productData});

  @override
  State<RelocateScreen> createState() => _RelocateScreenState();
}

class _RelocateScreenState extends State<RelocateScreen> {
  late TextEditingController _anaquelController;
  late TextEditingController _pisoController;

  @override
  void initState() {
    super.initState();
    _anaquelController =
        TextEditingController(text: widget.productData['anaquel']);
    _pisoController = TextEditingController(text: widget.productData['piso']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reubicar Producto'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto: ${widget.productData['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _anaquelController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Anaquel (Ejemplo: A1, B3)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pisoController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Piso / Nivel (Ejemplo: P1, P2)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    widget.productData['anaquel'] =
                        _anaquelController.text.toUpperCase();
                    widget.productData['piso'] =
                        _pisoController.text.toUpperCase();
                    AppData().saveProducts(); // <--- Guarda nueva ubicación en Edge
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ubicación actualizada y guardada'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Guardar Nueva Coordenada'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA EXTRA: AGREGAR NUEVO PRODUCTO (SOLO ADMIN)
// -----------------------------------------------------------------------------
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _anaquelController = TextEditingController();
  final TextEditingController _pisoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Producto'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                  labelText: 'Código / SKU', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                  labelText: 'Precio (Ej. \$350.00)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Stock Inicial (Unidades)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _anaquelController,
                    decoration: const InputDecoration(
                        labelText: 'Anaquel (Ej. A1)',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pisoController,
                    decoration: const InputDecoration(
                        labelText: 'Piso (Ej. P2)',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_nameController.text.isEmpty ||
                      _codeController.text.isEmpty) {
                    return;
                  }
                  final newProduct = {
                    'name': _nameController.text,
                    'code': _codeController.text,
                    'precio': _priceController.text.startsWith('\$')
                        ? _priceController.text
                        : '\$${_priceController.text}',
                    'stock': int.tryParse(_stockController.text) ?? 10,
                    'anaquel': _anaquelController.text.toUpperCase(),
                    'piso': _pisoController.text.toUpperCase(),
                  };
                  Navigator.pop(context, newProduct);
                },
                child: const Text('Guardar Producto en Inventario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA EXTRA: CAMBIAR PRECIO (SOLO ADMIN)
// -----------------------------------------------------------------------------
class EditPriceScreen extends StatefulWidget {
  final String currentPrice;
  const EditPriceScreen({super.key, required this.currentPrice});

  @override
  State<EditPriceScreen> createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends State<EditPriceScreen> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.currentPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Precio'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Precio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  String val = _priceController.text;
                  if (!val.startsWith('\$')) val = '\$$val';
                  Navigator.pop(context, val);
                },
                child: const Text('Actualizar Precio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA AUXILIAR: PERFIL
// -----------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  final String userRole;
  const ProfileScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración y Perfil'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1B365D),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Eduardo Becerra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Rol Actual: $userRole',
                style: const TextStyle(
                  color: Color(0xFF1B365D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar de Rol / Volver a Iniciar'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}