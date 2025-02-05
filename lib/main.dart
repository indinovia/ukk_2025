import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_form.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://toqcjollwvblqfadaszc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvcWNqb2xsd3ZibHFmYWRhc3pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM2MTMsImV4cCI6MjA1NDI4OTYxM30.-VzQuHhiCZdcAHr8cAEsyyzYEYBchCeCTroE5pAWmJ0',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter crud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: login(),
    );
  }
}
        