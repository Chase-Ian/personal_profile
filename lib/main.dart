import 'package:flutter/material.dart';

void main() => runApp( SpacePortfolioApp());
bool isAdminLoggedIn = false;
var textbio = "Full-stack explorer" ;
var name = "Chase Ian Famisaran";
class SpacePortfolioApp extends StatelessWidget {
   SpacePortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0D17), // Deep Space Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FF), // Neon Cyan
          secondary: Color(0xFFFF007F), // Retro Pink
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0D17),
          elevation: 0,
        ),
      ),
      home:  MainLandingPage(),
    );
  }
}
class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage> {
  // GlobalKeys to identify sections
  final homeKey = GlobalKey();
  final projectsKey = GlobalKey();
  final eduKey = GlobalKey();
  final galleryKey = GlobalKey();
  final socialKey = GlobalKey();
  
  void scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Profile", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
        actions: [
          
          // Nav Bar Items
          _navButton("HOME", homeKey),
          _navButton("PROJECTS", projectsKey),
          _navButton("EDUCATION", eduKey),
          _navButton("GALLERY", galleryKey),
          _navButton("SOCIAL", socialKey),
          const VerticalDivider(width: 20, color: Colors.white24),
  
          // CONDITIONAL BUTTON
          isAdminLoggedIn 
            ? IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF00F2FF)),
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const EditProfileScreen())
                  ).then((_) => setState(() {})), // <--- Add this to refresh the Home UI
              )
            : IconButton(
                icon: const Icon(Icons.lock_outline, color: Colors.white38),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                ).then((_) => setState(() {})), // Refresh state when coming back
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _section(homeKey, "HOME", Colors.blueGrey, height: 600, child: _buildHomeContent()),
            _section(projectsKey, "PROJECTS", Colors.deepPurple, height: 800),
            _section(eduKey, "EDUCATION", Colors.indigo, height: 600),
            _section(galleryKey, "GALLERY", Colors.black, height: 800),
            _section(socialKey, "SOCIAL", Colors.blueAccent, height: 400),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String text, GlobalKey key) {
    return TextButton(
      onPressed: () => scrollToSection(key),
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _section(GlobalKey key, String title, Color color, {double height = 500, Widget? child}) {
    return Container(
      key: key,
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: child ?? Center(child: Text(title, style: const TextStyle(fontSize: 40, color: Colors.white24))),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(radius: 80, backgroundColor: Color(0xFF00F2FF), child: Icon(Icons.person, size: 80)),
        const SizedBox(height: 20),
        Text(name, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF00F2FF))),
        Text(textbio, style: TextStyle(fontSize: 18, color: Colors.white70)),
      ],
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text:name);
  final _bioController = TextEditingController(text: textbio);

  void _showSaveDialog() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1D29),
          title: const Text("Sync to Mainframe?"),
          content: const Text("Do you want to save these profile updates?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FF)),
              onPressed: () {
                // 1. Update the global variables with the controller values
                setState(() {
                  name = _nameController.text;
                  textbio = _bioController.text;
                });

                // 2. Close the Dialog
                Navigator.pop(context); 
                
                // 3. Go back to Home
                Navigator.pop(context); 

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated Successfully!")),
                );
              },
              child: const Text("CONFIRM", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EDIT_PROFILE.BAT")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Command Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Bio / Mission Log", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Bio is required" : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _showSaveDialog,
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
                child: const Text("SAVE CHANGES"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      // Hardcoded Admin Check
      if (_passController.text == "admin123") {
        setState(() => isAdminLoggedIn = true);
        Navigator.pop(context); // Go back to profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ADMIN ACCESS GRANTED"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("INVALID CLEARANCE CODE"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RESTRICTED ACCESS")),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person, size: 80, color: Color(0xFFFF007F)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Enter Admin Keycode",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                  validator: (val) => val!.isEmpty ? "Input required" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("AUTHORIZE"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}