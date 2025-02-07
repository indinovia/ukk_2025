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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffffbcf8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "Kasir",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Color(0xff000000),
          ),
        ),
       actions:const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 11, 0),
            child: Icon(Icons.login, color: Color(0xff212435), size: 24),
          ),
        ],
      ),
      body: GridView(
        padding: EdgeInsets.zero,
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,                                       
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        children: [
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0x1f000000),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: Color(0x4d9e9e9e), width: 1),
            ),
            child:const Padding(
              padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.edit,
                    color: Color(0xff212435),
                    size: 24,
                  ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Icon(
                      Icons.delete,
                      color: Color(0xff212435),
                      size: 24,
                    ),
                ),
                
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem> [BottomNavigationBarItem(icon: Icon.person)]
    );
  }
}
