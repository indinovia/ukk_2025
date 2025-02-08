import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pelanggan_page.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;

  const HomeScreen({super.key, required this.userId, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  int _currentIndex = 0;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
  }

   @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  Future<void> _fetchProducts() async {
    try {
      final response = await supabase.from('produk').select();
      setState(() {
        products = response.map((product) => product as Map<String, dynamic>).toList();
        filteredProducts = List.from(products);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products.where((product) {
        return product['nama_produk']?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

 Future<bool> _isDuplicateProduct(String namaProduk, {int? excludeId}) async {
    final existingProduct = await supabase
        .from('produk')
        .select('produk_id, nama_produk')
        .eq('nama_produk', namaProduk)
        .maybeSingle();

    if (existingProduct == null) return false;
    if (excludeId != null && existingProduct['produk_id'] == excludeId) return false;
    return true;
  }


Future<void> _addProduct(String namaProduk, double harga, int stok) async {
    if (await _isDuplicateProduct(namaProduk)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk dengan nama yang sama sudah ada!")),
      );
      return;
    }

    try {
      await supabase.from('produk').insert({
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      });
      _fetchProducts();
    } catch (e) {
      print('Error menambahkan produk: $e');
    }
  }



  Future<void> _deleteProduct(int productId) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', productId);
      _fetchProducts();
    } catch (e) {
      print('Error menghapus produk: $e');
    }
  }

  Future<void> _editProduct(int productId, String namaProduk, double harga, int stok) async {
    if (await _isDuplicateProduct(namaProduk, excludeId: productId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk dengan nama yang sama sudah ada!")),
      );
      return;
    }

    try {
      await supabase.from('produk').update({
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', productId);
      _fetchProducts();
    } catch (e) {
      print('Error mengedit produk: $e');
    }
  }
  void _showEditProductDialog(Map<String, dynamic> product) {
    final TextEditingController namaController =
          TextEditingController(text: product['nama_produk']);
    final TextEditingController hargaController =
          TextEditingController(text: product['harga'].toString());
    final TextEditingController stokController =
          TextEditingController(text: product['stok'].toString());
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Produk"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(labelText: "Nama Produk"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Nama produk tidak boleh kosong"
                      : null,
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: InputDecoration(labelText: "Harga"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || double.tryParse(value) == null
                          ? "Masukkan harga yang valid"
                          : null,
                ),
                TextFormField(
                  controller: stokController,
                  decoration: InputDecoration(labelText: "Stok"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                          ? "Masukkan stok yang valid"
                          : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Batal")),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _editProduct(
                    product['produk_id'],
                    namaController.text,
                    double.parse(hargaController.text),
                    int.parse(stokController.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog() {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();
    TextEditingController searchController = TextEditingController();
List<Map<String, dynamic>> filteredProducts = [];
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Produk"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(labelText: "Nama Produk"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Nama produk tidak boleh kosong"
                      : null,
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: InputDecoration(labelText: "Harga"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || double.tryParse(value) == null
                          ? "Masukkan harga yang valid"
                          : null,
                ),
                TextFormField(
                  controller: stokController,
                  decoration: InputDecoration(labelText: "Stok"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                          ? "Masukkan stok yang valid"
                          : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Batal")),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addProduct(
                      namaController.text,
                      double.parse(hargaController.text),
                      int.parse(stokController.text));
                  Navigator.pop(context);
                }
              },
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (filteredProducts.isEmpty) {
      return Center(child: Text('Tidak ada produk tersedia'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.purple),
            title: Text(product['nama_produk'] ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Harga: Rp${product['harga']} | Stok: ${product['stok']}'),
          ),
        );
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 1:
        return PelangganPage();
      case 0:
      default:
        return _buildProductList();
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 4,
      backgroundColor: Color(0xffffbcf8),
      title: const Text("Kasir", style: TextStyle(fontSize: 14, color: Color(0xff000000))),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    ),
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Data Pelanggan'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: _showAddProductDialog,
      backgroundColor: Colors.purple,
      child: Icon(Icons.add, color: Colors.white),
    )
  );
  }
}
