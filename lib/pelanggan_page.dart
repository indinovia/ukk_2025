import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelangganList = [];

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      pelangganList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addPelanggan(
      String nama, String alamat, String nomorTelepon) async {
    await supabase.from('pelanggan').insert({
      'nama_pelanggan': nama,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
    });
    fetchPelanggan();
  }

  Future<void> deletePelanggan(int id) async {
    await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
    fetchPelanggan();
  }

  void showAddPelangganDialog() {
    TextEditingController namaController = TextEditingController();
    TextEditingController alamatController = TextEditingController();
    TextEditingController nomorTeleponController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: nomorTeleponController,
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isNotEmpty &&
                    alamatController.text.isNotEmpty &&
                    nomorTeleponController.text.isNotEmpty) {
                  addPelanggan(
                    namaController.text,
                    alamatController.text,
                    nomorTeleponController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Pelanggan')),
      body: pelangganList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pelangganList.length,
              itemBuilder: (context, index) {
                final pelanggan = pelangganList[index];
                return ListTile(
                  title: Text(pelanggan['nama_pelanggan'] ?? 'Tidak ada nama'),
                  subtitle: Text(
                      '${pelanggan['alamat'] ?? 'Tidak ada alamat'}\n${pelanggan['nomor_telepon'] ?? 'Tidak ada nomor'}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deletePelanggan(pelanggan['pelanggan_id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: showAddPelangganDialog,
      ),
    );
  }
}
