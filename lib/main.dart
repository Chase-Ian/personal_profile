import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- MODELS & GLOBAL STATE ---

bool isAdminLoggedIn = false;

class Profile {
  String name;
  String bio;
  String email;
  String phone;
  List<String> skills;
  String profilePic;

  Profile({
    required this.name,
    required this.bio,
    required this.email,
    required this.phone,
    required this.skills,
    required this.profilePic,
  });
}

// This acts as a "placeholder" until Supabase responds
Profile currentUser = Profile(
  name: "Loading...",
  bio: "Connecting to satellite...",
  email: "",
  phone: "",
  skills: [],
  profilePic: "https://via.placeholder.com/150", 
);

class Project {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? link; // Optional field
  Project({required this.id, required this.title, required this.description, required this.imageUrl,this.link});
}

class Friend {
  final String id;
  final String name;
  final String socialLink;
  Friend({required this.id, required this.name, required this.socialLink});
}

// --- MOCK SUPABASE SERVICE ---


class SupabaseService {
  static Future<List<Project>> getProjects() async {
  // Fetch data from the 'projects' table
  final response = await _supabase
      .from('projects')
      .select()
      .order('created_at', ascending: false);
  
  // Convert the list of maps into a list of Project objects
  final List<dynamic> data = response as List<dynamic>;
  return data.map((item) => Project(
    id: item['id'].toString(),
    title: item['title'] ?? 'No Title',
    description: item['description'] ?? '',
    imageUrl: item['image_url'] ?? '',
    link: item['link'],
  )).toList();
}

static Future<void> addProject(String title, String desc, String url,{String? link}) async {
  await _supabase.from('projects').insert({
    'title': title,
    'description': desc,
    'image_url': url,
    'link': link, 
  });
}

static Future<void> removeProject(String id) async {
  await _supabase.from('projects').delete().eq('id', id);
}
  
 static Future<String?> uploadProjectImage(XFile image) async {
  try {
    // 1. Read the file as bytes (REQUIRED for Web)
    final bytes = await image.readAsBytes(); 
    
    // 2. Extract extension from MIME type if path is a blob URL
    // image.mimeType is often more reliable on web than image.path
    final String fileExt = image.name.split('.').last.toLowerCase();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    // 3. Upload using binary data and explicit content type
    await _supabase.storage.from('project_images').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt', // e.g., 'image/png'
            upsert: true,
          ),
        );

    // 4. Return the Public URL
    return _supabase.storage.from('project_images').getPublicUrl(fileName);
  } catch (e) {
    // This will print the specific reason if it fails
    print('Critical Upload Error: $e');
    return null;
  }
}


// 1. Fetch from Supabase
  static Future<List<Friend>> getFriends() async {
    final response = await _supabase
        .from('friends')
        .select()
        .order('name', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((item) => Friend(
      id: item['id'].toString(),
      name: item['name'] ?? 'Unknown',
      socialLink: item['social_link'] ?? '',
    )).toList();
  }

  // 2. Add to Supabase
  static Future<void> addFriend(String name, String link) async {
    await _supabase.from('friends').insert({
      'name': name,
      'social_link': link,
    });
  }

  // 3. Delete from Supabase
  static Future<void> removeFriend(String id) async {
    await _supabase.from('friends').delete().eq('id', id);
  }

  

  static SupabaseClient get _supabase => Supabase.instance.client;

// 1. Fetch the one and only profile row (ID 1)
static Future<Map<String, dynamic>> fetchProfile() async {
  return await _supabase.from('profiles').select().eq('id', 1).single();
}

// 2. Upload Image and update the database row
static Future<String?> uploadProfilePic(XFile imageFile) async {
  final bytes = await imageFile.readAsBytes();
  
  // 1. Create a unique filename using the current timestamp
  // Example: profile_1707212345678.png
  final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png'; 

  // 2. Upload without 'upsert' (since the name is unique)
  await _supabase.storage.from('avatars').uploadBinary(
    fileName,
    bytes,
    fileOptions: const FileOptions(contentType: 'image/png'),
  );

  // 3. Get the new unique URL
  final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
  
  // 4. Update the database
  await _supabase.from('profiles').update({'profile_pic': publicUrl}).eq('id', 1);

  return publicUrl;
}
// 3. Save name and bio changes
static Future<void> saveProfileData(String name, String bio) async {
  await _supabase.from('profiles').update({
    'name': name,
    'bio': bio,
  }).eq('id', 1);
}
}

// --- APP ENTRY ---

void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: 'https://dhtmyeooslbxsshpxoac.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRodG15ZW9vc2xieHNzaHB4b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMTk1MTAsImV4cCI6MjA4NTg5NTUxMH0.DpJK1XAjUHhMBb6rCV4NWAFV-5hsH7kSC4-s_HnTiuY',
  );

  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', 1) // Make sure your ID in Supabase is 1!
        .single();

    // This overwrites the "Loading..." placeholder with real data
    currentUser = Profile(
      name: response['name'],
      bio: response['bio'],
      email: response['email'] ?? "chase.ian@starfleet.dev",
      phone: response['phone'] ?? "+63 000",
      skills: List<String>.from(response['skills'] ?? []),
      profilePic: response['profile_pic'],
    );
  } catch (e) {
    print("Database connection failed, using local fallback: $e");
  }
  // -----------------------

  runApp(const SpacePortfolioApp());
}

class SpacePortfolioApp extends StatelessWidget {
  const SpacePortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Portfolio',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0D17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FF),
          secondary: Color(0xFFFF007F),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainLandingPage(),
    );
  }
}

// --- SCREENS ---

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});
  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage> {
  final homeKey = GlobalKey();
  final projectsKey = GlobalKey();
  final eduKey = GlobalKey();
  final galleryKey = GlobalKey();
  final socialKey = GlobalKey();

  void scrollTo(GlobalKey key) {
    Scrollable.ensureVisible(key.currentContext!, duration: const Duration(seconds: 1), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D17).withOpacity(0.8),
        elevation: 0,
        title: Text("PORTFOLIO.OS", style: GoogleFonts.orbitron(letterSpacing: 2, fontWeight: FontWeight.bold)),
        actions: [
          _navItem("HOME", homeKey),
          _navItem("PROJECTS", projectsKey),
          _navItem("EDUCATION", eduKey),
          _navItem("GALLERY", galleryKey),
          _navItem("SOCIAL", socialKey),
          const VerticalDivider(width: 20, color: Colors.white24, indent: 15, endIndent: 15),
          IconButton(
            icon: Icon(isAdminLoggedIn ? Icons.verified_user : Icons.lock_outline, color: isAdminLoggedIn ? const Color(0xFF00F2FF) : Colors.white38),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())).then((_) => setState(() {})),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _section(homeKey, _buildHome(), height: 700),
            _section(projectsKey, _buildProjects()),
            _section(eduKey, _buildEducation()),
            _section(galleryKey, _buildGallery()),
            _section(socialKey, _buildSocial()),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String label, GlobalKey key) => TextButton(onPressed: () => scrollTo(key), child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)));

  Widget _section(GlobalKey key, Widget child, {double? height}) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: height ?? 600),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: child,
    );
  }

  Widget _buildHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FF), width: 2)),
              child: CircleAvatar(radius: 80, backgroundImage: NetworkImage(currentUser.profilePic)),
            ),
            if (isAdminLoggedIn)
              FloatingActionButton.small(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())).then((_) => setState(() {})),
                backgroundColor: const Color(0xFFFF007F),
                child: const Icon(Icons.edit, size: 16),
              ),
          ],
        ),
        const SizedBox(height: 30),
        Text(currentUser.name.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 42, fontWeight: FontWeight.w900, color: const Color(0xFF00F2FF))),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(currentUser.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: currentUser.skills.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 10)), backgroundColor: Colors.white12)).toList(),
        ),
      ],
    );
  }

void _showAddProjectDialog() {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();
  XFile? selectedImage; // To store the picked image

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // Use StatefulBuilder to update the dialog UI
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF0B0D17),
        title: Text("NEW_MISSION", style: GoogleFonts.orbitron(color: const Color(0xFF00F2FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Mission Title")),
            TextField(controller: descController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: linkController, 
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "MISSION_URL (OPTIONAL)")
              ),
            const SizedBox(height: 20),
            
            // Image Picker Button
            InkWell(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setDialogState(() => selectedImage = image); // Update dialog preview
                }
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00F2FF), width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedImage == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.image, color: Colors.white24), Text("SELECT_IMAGE", style: TextStyle(color: Colors.white24))],
                    )
                  : const Center(child: Icon(Icons.check_circle, color: Colors.green)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT")),
          ElevatedButton(
            onPressed: () async {
              if (selectedImage == null) return; // Basic validation
              
              // 1. Upload the image first
              final imageUrl = await SupabaseService.uploadProjectImage(selectedImage!);
              
              if (imageUrl != null) {
                // 2. Insert the mission with the new URL
                await SupabaseService.addProject(
                  titleController.text,
                  descController.text,
                  imageUrl,
                  link: linkController.text.isEmpty ? null : linkController.text,
                );
                setState(() {});
                Navigator.pop(context);
                setState(() {}); // Refresh main UI
              }
            },
            child: const Text("LAUNCH"),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProjects() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("LATEST_MISSIONS", style: GoogleFonts.orbitron(fontSize: 32, color: const Color(0xFFFF007F))),
            if (isAdminLoggedIn)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF00F2FF), size: 32),
                onPressed: _showAddProjectDialog,
              ),
          ],
        ),
        const SizedBox(height: 40),
        FutureBuilder<List<Project>>(
          future: SupabaseService.getProjects(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final missions = snapshot.data!;
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: missions.length,
              itemBuilder: (context, i) {
                final m = missions[i];
                return Container(
                  height: 130, // Increased slightly to fit the link button
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    color: Colors.white10,
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: double.infinity,
                              child: Image.network(m.imageUrl, fit: BoxFit.cover),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(m.title, style: const TextStyle(color: Color(0xFF00F2FF), fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.description, 
                                      style: const TextStyle(color: Colors.white70, fontSize: 12), 
                                      maxLines: 1, // Reduced to 1 to make room for link
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    // --- OPTIONAL LINK ROW ---
                                    if (m.link != null && m.link!.isNotEmpty) ...[
                                      const Spacer(),
                                     InkWell(
                                      onTap: () async {
                                        // Check if the project has a valid link
                                        if (m.link != null && m.link!.isNotEmpty) {
                                          final Uri url = Uri.parse(m.link!);
                                          
                                          // Launch the URL in an external browser
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Could not launch source link")),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("No source link available")),
                                          );
                                        }
                                      }, 
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.link, size: 14, color: Color(0xFFFF007F)),
                                          const SizedBox(width: 5),
                                          Text(
                                            "VIEW_SOURCE", 
                                            style: GoogleFonts.orbitron(color: const Color(0xFFFF007F), fontSize: 10, letterSpacing: 1)
                                          ),
                                        ],
                                      ),
                                    ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isAdminLoggedIn)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () async {
                                await SupabaseService.removeProject(m.id);
                                setState(() {}); 
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )
      ],
    ),
  );
}

  Widget _buildEducation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text("ACADEMIC_TRACKS", style: GoogleFonts.orbitron(fontSize: 32)),
          const SizedBox(height: 40),
          const _EduTile(title: "College", school: "Asia Pacific College", year: "2025 - ongoing"),
          const _EduTile(title: "Senior High School", school: "Pateros Catholic School", year: "2023 - 2024"),
        ],
      ),
    );
  }

  Widget _buildGallery() {
  // 1. Create a list of your asset paths
  final List<String> galleryImages = [
    'asset/imageGalleryImage1.jpg', // Replace with your actual filenames
    'asset/imageGalleryImage2.jpg',
    'asset/imageGalleryImage3.jpg',
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
    child: Column(
      children: [
        Text("VISUAL_ARCHIVE", 
          style: GoogleFonts.orbitron(fontSize: 32, color: const Color(0xFF00F2FF))),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 10, 
            mainAxisSpacing: 10,
          ),
          itemCount: galleryImages.length,
          itemBuilder: (context, i) => Container(
            clipBehavior: Clip.antiAlias, // Ensures image doesn't bleed over rounded corners
            decoration: BoxDecoration(
              color: Colors.white10, 
              borderRadius: BorderRadius.circular(8), 
              border: Border.all(color: Colors.white12),
            ),
            // 2. Replace the Icon with Image.asset
            child: Image.asset(
              galleryImages[i],
              fit: BoxFit.cover, // This makes the image fill the square nicely
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if the path is wrong
                return const Icon(Icons.broken_image, color: Colors.white10, size: 40);
              },
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSocial() {
    Future<void> _launchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $urlString");
  }
}
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text("COMMS_CHANNEL", style: GoogleFonts.orbitron(fontSize: 32, color: const Color(0xFFFF007F))),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white),
                onPressed: () => _launchURL("https://github.com/Chase-Ian"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2)),
                onPressed: () => _launchURL("https://www.facebook.com/chaseian.famisaran/"),
              ),

            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsListScreen())),
            child: const Text("ACCESS_CREW_MANIFEST"),
          ),
        ],
      ),
    );
  }
}

class _EduTile extends StatelessWidget {
  final String title, school, year;
  const _EduTile({required this.title, required this.school, required this.year});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        title: Text(title, style: GoogleFonts.orbitron(fontSize: 16, color: const Color(0xFF00F2FF))),
        subtitle: Text("$school | $year", style: const TextStyle(color: Colors.white54)),
        leading: const Icon(Icons.school, color: Color(0xFFFF007F)),
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
  final _controller = TextEditingController();
  void _attempt() {
    if (_controller.text == "admin123") {
      isAdminLoggedIn = true;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ADMIN_ACCESS_GRANTED"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("INVALID_CLEARANCE_CODE"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RESTRICTED_ACCESS")),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 80, color: Color(0xFFFF007F)),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Enter Identity Keycode", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _attempt, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text("AUTHORIZE")),
              if (isAdminLoggedIn) ...[
                const SizedBox(height: 20),
                TextButton(onPressed: () { setState(() => isAdminLoggedIn = false); Navigator.pop(context); }, child: const Text("LOGOUT", style: TextStyle(color: Colors.red))),
              ]
            ],
          ),
        ),
      ),
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
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _imageUrl;
  // Logic helpers
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

@override
void initState() {
  super.initState();
  _loadProfile(); // Fetch your real data on boot
   _nameController = TextEditingController(text: currentUser.name);
    _bioController = TextEditingController(text: currentUser.bio);
    _imageUrl = currentUser.profilePic;
}

@override
  void dispose() {
    // Always clean up controllers
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

Future<void> _loadProfile() async {
  try {
    final data = await SupabaseService.fetchProfile();
    setState(() {
      currentUser.name = data['name'];
      currentUser.bio = data['bio'];
      currentUser.profilePic = data['profile_pic'];
    });
  } catch (e) {
    debugPrint("Setup error: $e (This is normal if database is empty)");
  }
}

  // --- NEW: Handle Image Selection & Upload ---
  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimizing for web/mobile speed
    );

    if (image != null) {
      setState(() => _isUploading = true);
      
      try {
        // Upload via your SupabaseService
        final String? newUrl = await SupabaseService.uploadProfilePic(image);
        
        if (newUrl != null) {
          setState(() {
            currentUser.profilePic = newUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("AVATAR_UPLOAD_SUCCESS"), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("SYSTEM_ERROR: $e"), backgroundColor: Colors.red)
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _save() async {
  if (_formKey.currentState!.validate()) {
    // 1. Update the local UI state
    setState(() {
      currentUser.name = _nameController.text;
      currentUser.bio = _bioController.text;
    });

    // 2. IMPORTANT: Push the changes to Supabase
    await SupabaseService.saveProfileData(
      _nameController.text, 
      _bioController.text
    );

    if (mounted) Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EDIT_PROFILE.BAT")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- AVATAR EDIT SECTION ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00F2FF), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white10,
                        backgroundImage: NetworkImage(currentUser.profilePic),
                        child: _isUploading 
                          ? const CircularProgressIndicator(color: Color(0xFFFF007F)) 
                          : null,
                      ),
                    ),
                    IconButton(
                      onPressed: _isUploading ? null : _pickAndUploadImage,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFFF007F), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- TEXT FIELDS ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Command Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Mission Log / Bio", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isUploading ? null : _save, 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xFF00F2FF).withOpacity(0.1),
                  side: const BorderSide(color: Color(0xFF00F2FF)),
                ), 
                child: Text(_isUploading ? "UPLOADING..." : "UPLOAD_CHANGES", style: GoogleFonts.orbitron()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MISSION_ARCHIVE.LOG")),
      body: FutureBuilder<List<Project>>(
        future: SupabaseService.getProjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          // Use the data from the snapshot, not a global variable
          final projectsFromDb = snapshot.data!; 

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projectsFromDb.length,
            itemBuilder: (context, index) {
              final project = projectsFromDb[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.white.withOpacity(0.05), // Subtle transparent dark card
                clipBehavior: Clip.antiAlias, // Ensures image corners follow card shape
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFF00F2FF), width: 0.5), // Cyberpunk border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- THE IMAGE ---
                    SizedBox(
                      height: 200, // Fixed height for consistency
                      width: double.infinity,
                      child: Image.network(
                        project.imageUrl,
                        fit: BoxFit.cover, // Makes image fill the area without stretching
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white24, size: 50),
                        ),
                      ),
                    ),
                    
                    // --- THE CONTENT ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00F2FF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4, // Better readability
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      )
    );
  }
}

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});
  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final _nameCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  // 1. Modified to be ASYNC to wait for Supabase
  Future<void> _add() async {
    if (_nameCtrl.text.isNotEmpty && _linkCtrl.text.isNotEmpty) {
      // Don't pass a manual ID, Supabase handles it
      await SupabaseService.addFriend(_nameCtrl.text, _linkCtrl.text);
      
      _nameCtrl.clear(); 
      _linkCtrl.clear();
      
      if (mounted) {
        setState(() {}); // Now this will refresh with the new data
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching your theme
      appBar: AppBar(
        title: Text("CREW_MANIFEST", style: GoogleFonts.orbitron()),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: isAdminLoggedIn ? FloatingActionButton(
        backgroundColor: const Color(0xFF00F2FF),
        child: const Icon(Icons.person_add, color: Colors.black),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1D29),
            title: Text("ADD_NEW_CREW", style: GoogleFonts.orbitron(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: _linkCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Social Link", labelStyle: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FF)),
                onPressed: _add, 
                child: const Text("RECRUIT", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ) : null,
      body: FutureBuilder<List<Friend>>(
        // Make sure your service method is named fetchFriends or getFriends
        future: SupabaseService.getFriends(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00F2FF)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("MANIFEST_EMPTY", style: TextStyle(color: Colors.white24)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final f = snapshot.data![i];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white12, 
                  child: Icon(Icons.account_circle, color: Colors.white)
                ),
                title: Text(f.name, style: GoogleFonts.orbitron(color: Colors.white)),
                subtitle: Text(f.socialLink, style: const TextStyle(color: Color(0xFF00F2FF), fontSize: 10)),
                trailing: isAdminLoggedIn ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1D29),
                        title: const Text("CONFIRM_EJECTION?", style: TextStyle(color: Colors.white)),
                        content: Text("Remove ${f.name} from manifest?", style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async { 
                              // 2. Added AWAIT here so it deletes before refreshing
                              await SupabaseService.removeFriend(f.id); 
                              if (mounted) {
                                setState(() {}); 
                                Navigator.pop(context); 
                              }
                            }, 
                            child: const Text("REMOVE", style: TextStyle(color: Colors.white))
                          ),
                        ],
                      ),
                    );
                  },
                ) : const Icon(Icons.rocket_launch, size: 16, color: Color(0xFFFF007F)),
                onTap: () async {
                  // Actually redirect them to the link
                  final Uri url = Uri.parse(f.socialLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
