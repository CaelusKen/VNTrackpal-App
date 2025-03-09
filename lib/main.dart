import 'package:flutter/material.dart';
import 'package:vn_trackpal/screens/prelogon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VNTrackpalApp());
}

class VNTrackpalApp extends StatelessWidget {
  const VNTrackpalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VNTrackpalWaitPreLogin(),
    );
  }
}
