import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static const String _mongoUri = 'mongodb+srv://mwboline:k1ivR9Xc0UCfCJsp@readingcluster.my7xr.mongodb.net/WordInfo?retryWrites=true&w=majority&appName=ReadingCluster';
  static const String _dbName = 'WordInfo';
  
  late Db _db;
  late DbCollection _wordsCollection;
  late DbCollection _phonogramsCollection;
  
  bool _isConnected = false;
  Map<String, dynamic>? _cachedData;

  /// Connect to MongoDB and cache all data
  Future<Map<String, dynamic>> fetchAllData() async {
    // Return cached data if already loaded
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      // Try to connect to MongoDB
      _db = Db(_mongoUri);
      await _db.open();
      
      _wordsCollection = _db.collection('words');
      _phonogramsCollection = _db.collection('phonograms');
      _isConnected = true;

      // Fetch data from MongoDB
      final wordsList = await _wordsCollection.find().toList();
      final phonogramsList = await _phonogramsCollection.find().toList();

      _cachedData = {
        'words': wordsList,
        'phonograms': phonogramsList,
      };

      print('✓ Loaded data from MongoDB (${wordsList.length} words, ${phonogramsList.length} phonograms)');
      return _cachedData!;
    } catch (e) {
      print('✗ MongoDB connection failed: $e');
      print('↓ Falling back to local JSON file...');
      
      // Fallback to local JSON
      return await _loadLocalJSON();
    }
  }

  /// Load data from local JSON file (fallback)
  Future<Map<String, dynamic>> _loadLocalJSON() async {
    try {
      final String response = await rootBundle.loadString('assets/data/data.json');
      _cachedData = json.decode(response);
      print('✓ Loaded data from local JSON file (${_cachedData!['words'].length} words)');
      return _cachedData!;
    } catch (e) {
      print('✗ Failed to load local JSON: $e');
      rethrow;
    }
  }

  /// Close MongoDB connection
  Future<void> close() async {
    if (_isConnected && _db.isConnected) {
      await _db.close();
      _isConnected = false;
      print('MongoDB connection closed');
    }
  }

  /// Refresh data from MongoDB (or JSON if offline)
  Future<Map<String, dynamic>> refresh() async {
    _cachedData = null;
    return await fetchAllData();
  }
}
