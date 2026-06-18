import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/mongo_service.dart';

void main() {
  runApp(const ReadingAssistantApp());
}

class ReadingAssistantApp extends StatelessWidget {
  const ReadingAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonogram University',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007bff),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _phonogramController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MongoService _mongoService = MongoService();

  Map<String, dynamic>? _allData;
  Map<String, dynamic>? _lookupData;
  Map<String, dynamic>? _phonogramData;
  String? _randomWordText;
  Map<String, dynamic>? _randomWordData;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final data = await _mongoService.fetchAllData();
      if (mounted) {
        setState(() {
          _allData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load data: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _phonogramController.dispose();
    _audioPlayer.dispose();
    _mongoService.close();
    super.dispose();
  }

  ButtonStyle _standardButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF007bff),
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  void _searchWord(String word) {
    if (_allData == null || word.isEmpty) return;
    final words = _allData!['words'] as List;
    final result = words.firstWhere(
      (item) => item['word'].toString().toLowerCase() == word.toLowerCase().trim(),
      orElse: () => null,
    );
    setState(() {
      _lookupData = result;
      _errorMessage = result == null ? "Word not found in database." : null;
      _wordController.clear(); // Clears the lookup search field
    });
  }

  void _generateRandomWord() {
    if (_allData == null) return;
    final words = _allData!['words'] as List;
    final randomEntry = (List.from(words)..shuffle()).first;
    setState(() {
      _randomWordText = randomEntry['word'];
      _randomWordData = null;
    });
  }

  void _revealRandomCoded() {
    if (_allData == null) return;
    final words = _allData!['words'] as List;
    final result = words.firstWhere(
      (item) => item['word'].toString().toLowerCase() == _randomWordText?.toLowerCase(),
      orElse: () => null,
    );
    setState(() => _randomWordData = result);
  }

  void _searchPhonogram(String p) {
    if (_allData == null || p.isEmpty) return;
    final phonograms = _allData!['phonograms'] as List;
    final result = phonograms.firstWhere(
      (item) => item['phonogram'].toString().toLowerCase() == p.toLowerCase().trim(),
      orElse: () => null,
    );
    setState(() {
      _phonogramData = result;
      _phonogramController.clear(); // Clears the phonogram search field
    });
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@phonogramuniversity.com',
      queryParameters: {'subject': 'Request to Add Word to Database'},
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/banner.gif', fit: BoxFit.fitWidth, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome to the Reading Assistant App",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Wrap(
                    children: [
                      const Text("Brought to you by ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse("https://phonogramuniversity.com")),
                        child: const Text("Phonogram University",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF007bff), decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                labelColor: const Color(0xFF007bff),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF007bff),
                indicatorWeight: 4,
                tabs: const [
                  Tab(text: "Lookup"),
                  Tab(text: "Random"),
                  Tab(text: "Sounds"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildLookupTab(), _buildRandomTab(), _buildPhonogramTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter a word to understand and view its coding:", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _wordController,
                  onSubmitted: (val) => _searchWord(val),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                ),
              ),
              ElevatedButton(
                style: _standardButtonStyle(),
                onPressed: () => _searchWord(_wordController.text),
                child: const Text("Get Word Info"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (_lookupData != null) ...[
            Text(_lookupData!['decodedInfo'] ?? "", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            if (_lookupData!['audio_url'] != null && _lookupData!['audio_url'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  style: _standardButtonStyle(),
                  label: const Text("Play Word Sound"),
                  onPressed: () => _audioPlayer.play(UrlSource(_lookupData!['audio_url'])),
                ),
              ),
            Align(alignment: Alignment.centerLeft, child: Image.network(_lookupData!['imageUrl'])),
          ] else if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendEmail, 
              child: const Text("Click here to email info@phonogramuniversity.com to request this word",
                style: TextStyle(color: Color(0xFF007bff), decoration: TextDecoration.underline))
            ),
          ] else
            const Text("Results will appear here.", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildRandomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Random Word Practice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: _standardButtonStyle(),
            onPressed: _generateRandomWord, 
            child: const Text("Get New Random Word")
          ),
          if (_randomWordText != null) ...[
            const SizedBox(height: 30),
            Text(_randomWordText!, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.normal)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: _standardButtonStyle(),
              onPressed: _revealRandomCoded, 
              child: const Text("Show Coded Version")
            ),
            if (_randomWordData != null) ...[
              const SizedBox(height: 30),
              Text(_randomWordData!['decodedInfo'] ?? "", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 15),
              if (_randomWordData!['audio_url'] != null && _randomWordData!['audio_url'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up),
                    style: _standardButtonStyle(),
                    label: const Text("Play Word Sound"),
                    onPressed: () => _audioPlayer.play(UrlSource(_randomWordData!['audio_url'])),
                  ),
                ),
              Image.network(_randomWordData!['imageUrl'], width: 300),
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildPhonogramTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Search Phonogram Sounds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _phonogramController,
                  onSubmitted: (val) => _searchPhonogram(val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(), 
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)
                  ),
                ),
              ),
              ElevatedButton(
                style: _standardButtonStyle(),
                onPressed: () => _searchPhonogram(_phonogramController.text), 
                child: const Text("Search")
              ),
            ],
          ),
          if (_phonogramData != null) ...[
            const SizedBox(height: 30),
            SizedBox(
              height: 140,
              child: Image.network(_phonogramData!['phonogram_png'].toString().replaceAll("http://", "https://")),
            ),
            const SizedBox(height: 10),
            Text("Sample: ${_phonogramData!['samplewords']}", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              style: _standardButtonStyle(),
              label: const Text("Play Sound"),
              onPressed: () => _audioPlayer.play(UrlSource(_phonogramData!['phonogram_url'])),
            ),
          ]
        ],
      ),
    );
  }
}