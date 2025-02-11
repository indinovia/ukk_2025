import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  final VoidCallback? onCustomerUpdated; // Ubah menjadi nullable (opsional)

  const PelangganPage({Key? key, this.onCustomerUpdated}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client; // Inisialisasi Supabase client
  List<Map<String, dynamic>> customers = []; // List untuk menyimpan data pelanggan
  List<Map<String, dynamic>> filteredCustomers = []; // List untuk menyimpan data pelanggan yang difilter
  bool isLoading = true; // Status untuk menampilkan loading
  String searchQuery = ''; // Variabel untuk menyimpan query pencarian

  @override
  void initState() {
    super.initState();
    _fetchCustomers(); // Ambil data pelanggan saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil data pelanggan dari database
  Future<void> _fetchCustomers() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        customers = List<Map<String, dynamic>>.from(response);
        filteredCustomers = customers; // Inisialisasi filteredCustomers
        isLoading = false;
      });
    } catch (e) {
      _showError('Failed to fetch customers: $e');
    }
  }

  
 Future<String?> _isDuplicateCustomer(String nama, String nomorTelepon, [int? id]) async {
  final response = await supabase
      .from('pelanggan')
      .select()
      .or('nama_pelanggan.eq.$nama,nomor_telepon.eq.$nomorTelepon');

  for (var customer in response) {
    if (id == null || customer['pelanggan_id'] != id) {
      if (customer['nama_pelanggan'] == nama) {
        return 'Nama sudah terdaftar!';  //eror jika nama sudah digunakan
      }
      if (customer['nomor_telepon'] == nomorTelepon) {
        return 'Nomor telepon sudah terdaftar!'; //eorr jika nbomor telepon sudah digunakan
      }
    }
  }
  return null; // Tidak ada duplikasi
}


  // Fungsi untuk menambahkan pelanggan baru ke database
 Future<void> _addCustomer(String nama, String alamat, String nomorTelepon) async {
  String? errorMessage = await _isDuplicateCustomer(nama, nomorTelepon);
  if (errorMessage != null) {
    _showError(errorMessage);
    return;
  }
  try {
    await supabase.from('pelanggan').insert({
      'nama_pelanggan': nama,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
    });
    _fetchCustomers();
  } catch (e) {
    _showError('Gagal menambahkan pelanggan: $e');
  }
}


  // Fungsi untuk memperbarui data pelanggan
 Future<void> _updateCustomer(int id, String nama, String alamat, String nomorTelepon) async {
  String? errorMessage = await _isDuplicateCustomer(nama, nomorTelepon, id);
  if (errorMessage != null) {
    _showError(errorMessage);
    return;
  }
  try {
    await supabase.from('pelanggan').update({
      'nama_pelanggan': nama,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
    }).eq('pelanggan_id', id);
    _fetchCustomers();
  } catch (e) {
    _showError('Gagal memperbarui pelanggan: $e');
  }
}
 Future<void> _confirmDeleteCustomer(int id) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Tidak jadi hapus
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Lanjutkan hapus
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );

  if (result == true) {
    try {
      await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
      _fetchCustomers(); // Refresh daftar setelah penghapusan

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil dihapus')),
      );
    } catch (e) {
      _showError('Gagal menghapus pelanggan: $e');
    }
  }
}

  // Menampilkan error dalam snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Fungsi untuk memfilter pelanggan berdasarkan pencarian
  void _filterCustomers(String query) {
    setState(() {
      searchQuery = query;
      filteredCustomers = customers.where((customer) {
        return customer['nama_pelanggan']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            customer['alamat'].toLowerCase().contains(query.toLowerCase()) ||
            customer['nomor_telepon']
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  // Widget untuk menampilkan tabel pelanggan
  Widget _buildCustomerTable() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : filteredCustomers.isEmpty
            ? const Center(child: Text('No customers found'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('No.')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Alamat')),
                    DataColumn(label: Text('Nomor Telepon')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredCustomers.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final customer = entry.value;
                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(customer['nama_pelanggan'])),
                      DataCell(Text(customer['alamat'])),
                      DataCell(Text(customer['nomor_telepon'])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editCustomerDialog(customer),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDeleteCustomer(
                                customer['pelanggan_id']),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regristrasi Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterCustomers,
            ),
            const SizedBox(height: 8.0),
            Expanded(child: _buildCustomerTable()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCustomerDialog();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addCustomerDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController nomorTeleponController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: alamatController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nomorTeleponController,
                    decoration:
                        const InputDecoration(labelText: 'Nomor Telepon'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Nomor telepon harus berupa angka';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Validasi berhasil
                  _addCustomer(
                    namaController.text,
                    alamatController.text,
                    nomorTeleponController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _editCustomerDialog(Map<String, dynamic> customer) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController namaController =
        TextEditingController(text: customer['nama_pelanggan']);
    final TextEditingController alamatController =
        TextEditingController(text: customer['alamat']);
    final TextEditingController nomorTeleponController =
        TextEditingController(text: customer['nomor_telepon']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: nomorTeleponController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Nomor telepon harus berupa angka';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateCustomer(
                    customer['pelanggan_id'],
                    namaController.text,
                    alamatController.text,
                    nomorTeleponController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}