import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured =
      true; //jika true, maka password akan terprivasi lebih dahulu sebelum dipencet  matanya

  final _formKey =
      GlobalKey<FormState>(); // untuk mengelola dan memvalidasi formulir
  String? _usernameError;
  String? _passwordError;

  String? _validateUsername(String? value) {
    // menambah validasi pada bagian username, jika username kosong atau tidak diisi maka akan muncul tulisan username tidak boleh kosng
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    //sama seperti username
    if (value == null || value.trim().isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  Future<void> _login() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userResponse = await Supabase.instance.client
          .from('user')
          .select('id, username, password')
          .eq('username', username)
          .maybeSingle();

      if (userResponse == null) {
        //validasi jika salah memasukkan username
        setState(() {
          _usernameError = 'Username tidak ditemukan';
        });
        return;
      }

      if (userResponse['password'] != password) {
        //validasi jika salah memasukkan password
        setState(() {
          _passwordError = 'Password salah';
        });
        return;
      }

      final userId = userResponse['id'] as int;
      final userName = userResponse['username'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        // untuk menampilkan snackbar saat sudah berhasil login menggunakan username dan password yang benar
        SnackBar(
          content: Text('Login Berhasil. Selamat datang, $userName!'),
          duration: Duration(
              seconds:
                  1), //waktu snackbar menampilkan keterangan login berhasil di bawah
        ),
      );

      await Future.delayed(Duration(
          seconds:
              1)); //waktu saat akan memasuki halaman pertama saat baru dipencet login

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            // untuk navigasi ke halaman lain yaitu halaman home dengan class HomeScreen
            userId: userId,
            username: userName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                    color: Color(0xff000000),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _usernameController,
                  validator: _validateUsername,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Masukkan username",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Color(0xfff2f2f3),
                    prefixIcon: Icon(Icons.person, color: Color(0xff212435)),
                    errorText: _usernameError,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextFormField(
                  controller: _passwordController,
                  validator: _validatePassword, //menampilkan validator
                  obscureText:
                      _isObscured, // menampilkan tanda bulat untuk privasi password, supaya tidak terlihat saat mengetik
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Masukkan password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Color(0xfff2f2f3),
                    prefixIcon: Icon(Icons.lock, color: Color(0xff212435)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xff212435),
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                    errorText: _passwordError,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: MaterialButton(
                  onPressed: _login,
                  color: Color.fromARGB(255, 241, 153, 226),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: Color(0xff808080), width: 1),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  textColor: Color(0xffffffff),
                  height: 40,
                  minWidth: 140,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
