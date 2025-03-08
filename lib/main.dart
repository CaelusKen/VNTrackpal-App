import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vn_trackpal/data/data_holder.dart';
import 'package:vn_trackpal/screens/prelogon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(),
      child: const VNTrackpalApp(),
    ),
  );
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
