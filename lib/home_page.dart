///File download from FlutterViz- Drag and drop a tools. For more details visit https://flutterviz.io/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

 class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;


  const HomeScreen(
      {super.key,
      required this.userId,
      required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase =
      Supabase.instance.client;
  List<Map<String, dynamic>> products = []; 
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true; 
  int _currentIndex = 0;
  String searchQuery = '';

  @override
  // ignore: override_on_non_overriding_member
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 130, 242),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "Kasir",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Color(0xff000000),
          ),
        ),
        leading: Icon(
          Icons.menu,
          color: Color(0xff212435),
          size: 24,
        ),
        actions: [
          Icon(Icons.logout, color: Color(0xff212435), size: 24),
        ],
      ),
      body: GridView(
        padding: EdgeInsets.zero,
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        children: [],
      ),
    );
  }
}

