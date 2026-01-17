import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Categoria {
  final String nombre;

  Categoria({required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(nombre: json["nombre"] ?? "default");
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // el item de búsqueda resaltado
  final _storage = const FlutterSecureStorage();
  final ApiService api = ApiService();
  bool _isLoggedIn = false;
  bool _isStaff = false;
  String _ordenSeleccionado = "";
  String _categoriaSeleccionada = "Todas las categorías";
  dynamic _idCategoriaSeleccionada = 0;
  bool _estaBuscando = false; // Controla si se muestra el icono o la barra
  String _textoBusqueda = ""; // Guarda lo que el usuario escribe
  final TextEditingController _searchController = TextEditingController();

  Widget _obtenerCuerpo() {
    switch (_selectedIndex) {
      case 0: // Icono de Reloj (Ver todos los productos)
        return _buildCatalogoCompleto();
      case 1: // Icono de Búsqueda (Tu Home actual con carruseles)
        return _buildHomePrincipal();
      default:
        return _buildHomePrincipal();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLogin(); // ✅ se ejecuta cada vez que regresas a Home
  }

  Future<void> _checkLogin() async {
    final token = await _storage.read(key: "token");
    final staffValue = await _storage.read(key: "is_staff");

    setState(() {
      _isLoggedIn = token != null;
      _isStaff = staffValue == "true";
    });
  }

  Future<void> _logout() async {
    await _storage.delete(key: "token");
    await _storage.delete(key: "is_staff"); // 👈 ¡Faltaba esto!

    setState(() {
      _isLoggedIn = false;
      _isStaff = false; // 👈 Reinicia el estado local también
    });
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/home");
  }

  Future<void> _refreshProductos() async {
    setState(() {
      // Al llamar a setState, el FutureBuilder se ejecutará de nuevo
      // y pedirá los productos actualizados al API.
    });
  }

  // --- PEGAR ESTO ARRIBA DEL BUILD ---
  List<Map<String, dynamic>> _obtenerTopCategorias(
    List<dynamic> categorias,
    List<dynamic> productos,
  ) {
    List<Map<String, dynamic>> resultado = [];

    for (var cat in categorias) {
      // Obtenemos el ID de la categoría actual (ej: 1)
      final String idCat = cat["id"].toString();
      final String nombreCat = cat["nombre"].toString();

      final productosDeCat = productos.where((p) {
        // Comparamos el campo categoria del producto con el ID de la categoría
        // Esto funciona si p["categoria"] es un número o un String del ID
        return p["categoria"].toString() == idCat;
      }).toList();

      if (productosDeCat.isNotEmpty) {
        resultado.add({
          "nombre": nombreCat,
          "productos": productosDeCat,
          "cantidad": productosDeCat.length,
        });
      }
    }

    // Ordenar por las categorías que más productos tengan
    resultado.sort((a, b) => b["cantidad"].compareTo(a["cantidad"]));

    return resultado.take(3).toList();
  }

  final Map<int, String> imagenesCategorias = {
    2: "assets/lifestyle.jpg",
    3: "assets/descargas.jpg",
    4: "assets/descarga.jpg",
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Catalogo",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),

            if (_isLoggedIn) ...[
              if (_isStaff)
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.pushNamed(context, "/homel"); // 👈 nueva pantalla
                  },
                ),

              // Botón de logout siempre que esté logeado
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: _logout,
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black),
                onPressed: () async {
                  await Navigator.pushNamed(context, "/login");
                  _checkLogin();
                },
              ),
            ],
          ],
        ),
        body: _obtenerCuerpo(),

        // 📌 BottomNavigationBar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Text(
                "clubSV",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ), // 👈 línea negra abajo
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _tarjetaEstilo(String titulo, String rutaImagen) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12, left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(rutaImagen), // <--- Ahora es dinámica
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black38, // Un poco más oscuro para que el texto resalte
        ),
        child: Center(
          child: Text(
            "COLECCIÓN\n${titulo.toUpperCase()}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaProductoCatalogo(dynamic producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Contenedor de Imagen con Icono de Corazón
        Stack(
          children: [
            Container(
              height: 220, // Altura similar a la de la foto
              width: double.infinity,
              color: const Color(0xFFF0F0F0), // Fondo gris claro de la imagen
              child: Padding(
                padding: const EdgeInsets.all(
                  20.0,
                ), // Ajusta este número: más alto = imagen más pequeña
                child:
                    producto["imagen"] != null &&
                        producto["imagen"].toString().isNotEmpty
                    ? Image.network(
                        producto["imagen"],
                        fit: BoxFit
                            .contain, // Importante: 'contain' para que no se estire
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              "assets/placeholder.png",
                              fit: BoxFit.contain,
                            ),
                      )
                    : Image.asset(
                        "assets/placeholder.png",
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            // Icono de favoritos (Corazón)
            const Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.favorite_border, color: Colors.black, size: 22),
            ),
            // Etiqueta de precio en el fondo (Opcional, si tu diseño lo requiere)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "\$${producto["precio"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    backgroundColor: Colors.white,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. Nombre del Producto (Dos líneas máximo)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            producto["nombre"] ?? "Nombre del producto",
            style: const TextStyle(
              fontSize: 14,
              height: 1.2,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaProducto(dynamic producto) {
    // Verificamos si la imagen existe en el JSON
    final String? urlImagen = producto["imagen"];

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              child: (urlImagen != null && urlImagen.isNotEmpty)
                  ? Image.network(
                      urlImagen,
                      fit: BoxFit.contain,
                      // Si la URL falla (error 404, etc.), pone el placeholder
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Image.asset(
                          "assets/placeholder.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Center(
                      child: Image.asset(
                        "assets/placeholder.png",
                        fit: BoxFit.contain,
                      ),
                    ), // Si es nulo
            ),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.favorite_border, color: Colors.black),
          ),
          Positioned(
            bottom: 40,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white,
              child: Text(
                "\$${producto["precio"]}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: SizedBox(
              width: 150,
              child: Text(
                producto["nombre"] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogoCompleto() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBarraFiltros(4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProductos,
              color: Colors.black,
              backgroundColor: Colors.white,
              child: FutureBuilder<List<dynamic>>(
                future: api.getProductos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // 1. Obtenemos la lista base
                  List<dynamic> productosRaw = List.from(snapshot.data ?? []);

                  // 2. FILTRADO COMBINADO (Categoría + Buscador)
                  List<dynamic> productos = productosRaw.where((p) {
                    // Filtro A: Categoría (si es 0, pasan todos)
                    bool coincideCategoria =
                        _idCategoriaSeleccionada == 0 ||
                        p['categoria'].toString() ==
                            _idCategoriaSeleccionada.toString();

                    // Filtro B: Buscador (si el texto es vacío, pasan todos)
                    // .contains hace que busque partes del nombre (ej: "zap" encuentra "zapato")
                    bool coincideBusqueda = p['nombre']
                        .toString()
                        .toLowerCase()
                        .contains(_textoBusqueda.toLowerCase());

                    return coincideCategoria && coincideBusqueda;
                  }).toList();

                  // 3. ORDENAMIENTO
                  if (_ordenSeleccionado == "Precio (Menor a mayor)") {
                    productos.sort((a, b) {
                      double precioA =
                          double.tryParse(a['precio'].toString()) ?? 0.0;
                      double precioB =
                          double.tryParse(b['precio'].toString()) ?? 0.0;
                      return precioA.compareTo(precioB);
                    });
                  } else if (_ordenSeleccionado == "Precio (Mayor a menor)") {
                    productos.sort((a, b) {
                      double precioA =
                          double.tryParse(a['precio'].toString()) ?? 0.0;
                      double precioB =
                          double.tryParse(b['precio'].toString()) ?? 0.0;
                      return precioB.compareTo(precioA);
                    });
                  } else if (_ordenSeleccionado == "Nombre (A-Z)") {
                    productos.sort(
                      (a, b) => (a['nombre'] ?? "")
                          .toString()
                          .toLowerCase()
                          .compareTo(
                            (b['nombre'] ?? "").toString().toLowerCase(),
                          ),
                    );
                  } else if (_ordenSeleccionado == "Nombre (Z-A)") {
                    productos.sort(
                      (a, b) => (b['nombre'] ?? "")
                          .toString()
                          .toLowerCase()
                          .compareTo(
                            (a['nombre'] ?? "").toString().toLowerCase(),
                          ),
                    );
                  } else {
                    productos.sort((a, b) {
                      int idA = int.tryParse(a['id'].toString()) ?? 0;
                      int idB = int.tryParse(b['id'].toString()) ?? 0;
                      return idB.compareTo(idA);
                    });
                  }

                  // 4. VALIDACIÓN DE LISTA VACÍA
                  if (productos.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _textoBusqueda.isEmpty
                              ? "No hay productos en esta categoría"
                              : "No se encontraron resultados para '$_textoBusqueda'",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: productos.length,
                    itemBuilder: (context, index) =>
                        _tarjetaProductoCatalogo(productos[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraFiltros(int cantidadResultados) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          // --- LADO IZQUIERDO: Filtros (Solo visibles si NO está buscando) ---
          if (!_estaBuscando) ...[
            GestureDetector(
              onTap: () => _mostrarModalFiltros(context),
              child: const Icon(Icons.tune, size: 26, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_categoriaSeleccionada != "Todas las categorías")
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildChipFiltro(_categoriaSeleccionada),
                      ),
                    if (_ordenSeleccionado != "")
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildChipFiltro(_ordenSeleccionado),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // --- LADO DERECHO: Buscador ---
          // Si está buscando, usamos Expanded para que el AnimatedContainer tome todo el ancho
          _estaBuscando
              ? Expanded(child: _buildCajaBusqueda())
              : _buildCajaBusqueda(),
        ],
      ),
    );
  }

  Widget _buildCajaBusqueda() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // Si busca, el ancho es irrelevante porque el Expanded lo controla,
      // pero ponemos un valor alto por seguridad.
      width: _estaBuscando ? MediaQuery.of(context).size.width : 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.zero,
      ),
      child: _estaBuscando
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "BUSCAR...",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _estaBuscando = false;
                      _textoBusqueda = "";
                      _searchController.clear();
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) => setState(() => _textoBusqueda = value),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.search, size: 20, color: Colors.black),
              onPressed: () => setState(() => _estaBuscando = true),
            ),
    );
  }

  void _mostrarModalFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        // El StatefulBuilder permite que los Radio funcionen dentro del modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Cabecera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _idCategoriaSeleccionada = 0;
                            _ordenSeleccionado = "";
                            _categoriaSeleccionada = "Todas las categorías";
                          });
                        },
                        child: const Text(
                          "BORRAR TODO",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(
                        "FILTRAR RESULTADOS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        // SECCIÓN ORDENAR
                        _seccionFiltroDinamica(
                          "ORDENAR POR",
                          [
                            "Precio (Mayor a menor)",
                            "Precio (Menor a mayor)",
                            "Nombre (A-Z)",
                            "Nombre (Z-A)",
                          ],
                          _ordenSeleccionado, // Si es "", ningún RadioListTile coincidirá
                          (val) =>
                              setModalState(() => _ordenSeleccionado = val!),
                        ),
                        const SizedBox(height: 20),

                        // SECCIÓN CATEGORÍAS DESDE BACKEND
                        // SECCIÓN CATEGORÍAS DESDE BACKEND
                        FutureBuilder<List<dynamic>>(
                          future: api.getCategorias(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              );
                            }

                            // Lista de objetos para manejar ID y Nombre
                            List<dynamic> categorias = [
                              {"id": 0, "nombre": "Todas las categorías"},
                            ];

                            if (snapshot.hasData) {
                              categorias.addAll(snapshot.data!);
                            }

                            return _seccionCategoriasMejorada(
                              "CATEGORÍA",
                              categorias,
                              (id, nombre) {
                                setModalState(() {
                                  _idCategoriaSeleccionada = id;
                                  _categoriaSeleccionada = nombre;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Botón Aplicar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        // Aquí llamarías a tu función de filtrar en el backend
                        Navigator.pop(context);
                        setState(() {}); // Refresca la pantalla principal
                      },
                      child: const Text(
                        "APLICAR FILTROS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _seccionCategoriasMejorada(
    String titulo,
    List<dynamic> opciones,
    Function(dynamic, String) onSeleccion,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Esto asegura que el borde sea visible (negro) cuando NO está seleccionado
        unselectedWidgetColor: Colors.black,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black; // Color cuando está marcado
            }
            return Colors.black; // Color del borde cuando está vacío
          }),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...opciones.map((cat) {
            return RadioListTile<dynamic>(
              title: Text(
                cat['nombre'].toString().toUpperCase(),
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
              value: cat['id'],
              groupValue: _idCategoriaSeleccionada,
              activeColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                onSeleccion(val, cat['nombre'].toString());
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _seccionFiltroDinamica(
    String titulo,
    List<String> opciones,
    String valorActual,
    Function(String?) alCambiar,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Text(
            titulo.toUpperCase(), // Estilo Adidas: Mayúsculas
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
        ),
        ...opciones.map(
          (opcion) => Theme(
            data: Theme.of(context).copyWith(
              // Esto obliga a que el borde del círculo sea negro siempre
              unselectedWidgetColor: Colors.black,
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => Colors.black, // Negro tanto seleccionado como no
                ),
              ),
            ),
            child: RadioListTile<String>(
              value: opcion,
              groupValue: valorActual,
              title: Text(
                opcion,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              activeColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: alCambiar,
            ),
          ),
        ),
        const Divider(color: Color(0xFFEEEEEE)), // Línea divisora sutil
      ],
    );
  }

  Widget _buildChipFiltro(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.black, // Fondo negro
      ),
      child: Row(
        children: [
          Text(
            texto.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildHomePrincipal() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 🔍 SearchBar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Encontrar productos...",
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white, // Fondo blanco adentro
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                // BORDE CUANDO NO ESTÁ SELECCIONADO (Negro)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                // BORDE CUANDO SE ENFOCA/HACES CLIC (Rojo)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.red, width: 2.0),
                ),
                // BORDE POR DEFECTO
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // 📌 TabBar
          // TabBar(
          //   controller: _tabController,
          //   indicatorColor: Colors.black,
          //   labelColor: Colors.black,
          //   unselectedLabelColor: Colors.grey,
          //   tabs: const [
          //     Tab(text: "HOMBRE"),
          //     Tab(text: "MUJER"),
          //     Tab(text: "NIÑOS"),
          //   ],
          // ),

          // 📌 Contenido scrollable
          Expanded(
            child: RefreshIndicator(
              onRefresh:
                  _refreshProductos, // 👈 Esta función se activa al bajar el scroll
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 🎯 Banner promocional
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage("assets/banner.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 30,
                          child: const Text(
                            "HASTA 40% OFF",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color: Colors.white,
                            child: const Text(
                              "+ 20% OFF EXTRA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 30,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 📋 Lista de categorías mejorada
                    FutureBuilder<List<dynamic>>(
                      future: api.getCategorias(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasData) {
                          final categorias = snapshot.data!;
                          return ListView.builder(
                            // 🛠️ ESTAS DOS LÍNEAS SON CLAVE:
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categorias.length,
                            itemBuilder: (context, index) {
                              final categoria = categorias[index];
                              return _buildCategoryTile(
                                categoria["nombre"].toString().toUpperCase(),
                              );
                            },
                          );
                        }
                        return const SizedBox(); // Si hay error o no hay data, no ocupa espacio
                      },
                    ),

                    const SizedBox(height: 24),

                    // 🛋 Sección EN MODO RELAX
                    Text(
                      "EN MODO RELAX",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      "Descubre nuestra colección pensada para tus momentos de descanso. "
                      "Comodidad y estilo en cada paso.",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        // Acción al presionar
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "VER TODO",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Carrusel de productos
                    // --- SUSTITUIR EL BLOQUE ANTERIOR POR ESTE ---
                    FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        api.getCategorias(),
                        api.getProductos(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Si hay error en la petición, lo imprimimos para saber qué pasa
                        if (snapshot.hasError) {
                          print("ERROR EN API: ${snapshot.error}");
                          return const Center(
                            child: Text("Error al cargar datos"),
                          );
                        }

                        if (snapshot.hasData && snapshot.data![0] != null) {
                          final listaCategorias =
                              snapshot.data![0] as List<dynamic>;
                          final listaProductos =
                              snapshot.data![1] as List<dynamic>;

                          final categoriasTop = _obtenerTopCategorias(
                            listaCategorias,
                            listaProductos,
                          );

                          if (categoriasTop.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No se encontraron productos por categoría",
                              ),
                            );
                          }

                          return Column(
                            children: categoriasTop.map((catMap) {
                              final String nombreParaMostrar = catMap["nombre"];
                              final List<dynamic> productosDeEstaCat =
                                  catMap["productos"];

                              // BUSQUEDA SEGURA DEL ID:
                              int idCategoria = 0;
                              try {
                                final catDoc = listaCategorias.firstWhere(
                                  (c) =>
                                      c["nombre"].toString().toLowerCase() ==
                                      nombreParaMostrar.toLowerCase(),
                                  orElse: () => null,
                                );
                                if (catDoc != null) {
                                  idCategoria = int.parse(
                                    catDoc["id"].toString(),
                                  );
                                }
                              } catch (e) {
                                idCategoria =
                                    0; // ID por defecto si falla el parseo
                              }

                              final String rutaImagen =
                                  imagenesCategorias[idCategoria] ??
                                  "assets/lifestyle.jpg";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 25,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      "TOP EN ${nombreParaMostrar.toUpperCase()}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 280,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          productosDeEstaCat.take(5).length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return _tarjetaEstilo(
                                            nombreParaMostrar,
                                            rutaImagen,
                                          );
                                        }
                                        return _tarjetaProducto(
                                          productosDeEstaCat[index - 1],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
