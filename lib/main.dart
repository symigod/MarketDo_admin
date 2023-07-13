import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/side.menu.dart';

int marketDoGreen = 0xFF1B5E20;
MaterialColor _marketDoGreen = MaterialColor(marketDoGreen, {
  50: const Color(0xFFE8F5E9),
  100: const Color(0xFFC8E6C9),
  200: const Color(0xFFA5D6A7),
  300: const Color(0xFF81C784),
  400: const Color(0xFF66BB6A),
  500: Color(marketDoGreen),
  600: const Color(0xFF43A047),
  700: const Color(0xFF388E3C),
  800: const Color(0xFF2E7D32),
  900: const Color(0xFF1B5E20)
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBhdLFSYflUevpsoEssdjh_zcPTA8ynnyc",
          authDomain: "marketdoapp.firebaseapp.com",
          projectId: "marketdoapp",
          storageBucket: "marketdoapp.appspot.com",
          messagingSenderId: "780102967000",
          appId: "1:780102967000:web:355fc279e1b33653e901ad",
          measurementId: "G-T7V8YN5HBN"));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget currentScreen = const SideMenu();
  final session = const FlutterSecureStorage();
  @override
  void initState() {
    checkSession();
    super.initState();
  }

  Future<void> checkSession() async {
    String? token = await session.read(key: 'session');
    token != null
        ? setState(() => currentScreen = currentScreen)
        : setState(() => currentScreen = const PasswordScreen());
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MarketDo Admin',
      theme: ThemeData(primarySwatch: _marketDoGreen, fontFamily: 'Lato'),
      home: currentScreen,
      builder: EasyLoading.init());
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final session = const FlutterSecureStorage();
  TextEditingController password = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.green.shade900,
      body: AlertDialog(
          scrollable: true,
          title: SizedBox(
              height: 100,
              width: 100,
              child: Image.asset('assets/images/marketdoLogo.png')),
          content: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(children: [
                Text('MarketDo Admin',
                    style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: password,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'ENTER PASSWORD',
                      suffixIcon: IconButton(
                          onPressed: () => setState(() => hidePassword == true
                              ? hidePassword = false
                              : hidePassword = true),
                          icon: Icon(hidePassword == true
                              ? Icons.visibility_off
                              : Icons.visibility))),
                  obscureText: hidePassword,
                  onEditingComplete: () => login(context),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () => login(context),
                    child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('LOGIN',
                            style: TextStyle(fontWeight: FontWeight.bold))))
              ]))));

  login(context) async => password.text == 'MarketDo-2023'
      ? await session.write(key: 'session', value: generateToken()).then(
          (value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SideMenu())))
      : showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
                title: Text('ACCESS DENIED',
                    style: TextStyle(color: Colors.red.shade900)),
                content: const Text('Incorrect password!'),
              ));
}
