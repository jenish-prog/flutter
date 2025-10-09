import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SleepyRideApp());
}

class SleepyRideApp extends StatelessWidget {
  const SleepyRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepyRide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SleepyRideHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// App State Management
class AppState extends ChangeNotifier {
  String? _destination;
  String? _wakeUpSong;
  bool _isRideActive = false;
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  double _destinationLat = 0.0;
  double _destinationLng = 0.0;
  Timer? _locationTimer;
  List<Map<String, dynamic>> _recentDestinations = [];
  String? _destinationAddress;

  String? get destination => _destination;
  String? get destinationAddress => _destinationAddress;
  String? get wakeUpSong => _wakeUpSong;
  bool get isRideActive => _isRideActive;
  double get distanceToDestination => _calculateDistance();
  List<Map<String, dynamic>> get recentDestinations => _recentDestinations;

  void setDestination(String destination, double lat, double lng, {String? address}) {
    _destination = destination;
    _destinationLat = lat;
    _destinationLng = lng;
    _destinationAddress = address;
    
    // Add to recent destinations
    _addToRecentDestinations(destination, lat, lng, address);
    
    notifyListeners();
  }

  void _addToRecentDestinations(String name, double lat, double lng, String? address) {
    // Remove if already exists
    _recentDestinations.removeWhere((dest) => dest['name'] == name);
    
    // Add to beginning of list
    _recentDestinations.insert(0, {
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Keep only last 10 destinations
    if (_recentDestinations.length > 10) {
      _recentDestinations = _recentDestinations.take(10).toList();
    }
  }

  void loadSavedDestinations() {
    // Sample recent destinations for demo
    _recentDestinations = [
      {
        'name': 'Home',
        'lat': 37.7749,
        'lng': -122.4194,
        'address': '123 Main St, San Francisco, CA',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      },
      {
        'name': 'Work',
        'lat': 37.7849,
        'lng': -122.4094,
        'address': '456 Business Ave, San Francisco, CA',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      },
    ];
  }

  void setWakeUpSong(String song) {
    _wakeUpSong = song;
    notifyListeners();
  }

  void startRide() {
    _isRideActive = true;
    _startLocationTracking();
    notifyListeners();
  }

  void stopRide() {
    _isRideActive = false;
    _locationTimer?.cancel();
    notifyListeners();
  }

  void _startLocationTracking() {
    // Simulate GPS tracking
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Simulate moving towards destination
      _currentLat += (Random().nextDouble() - 0.5) * 0.001;
      _currentLng += (Random().nextDouble() - 0.5) * 0.001;

      // Check if we're close to destination (200 meters)
      if (_calculateDistance() < 0.2) {
        _triggerWakeUp();
      }

      notifyListeners();
    });
  }

  double _calculateDistance() {
    if (_destinationLat == 0.0 || _destinationLng == 0.0) return 999.0;

    // Simple distance calculation (in km)
    double deltaLat = _destinationLat - _currentLat;
    double deltaLng = _destinationLng - _currentLng;
    return sqrt(deltaLat * deltaLat + deltaLng * deltaLng) * 111;
  }

  void _triggerWakeUp() {
    // Play wake-up song and vibrate
    HapticFeedback.heavyImpact();
    stopRide();
  }
}cla
ss SleepyRideHome extends StatefulWidget {
  const SleepyRideHome({super.key});

  @override
  State<SleepyRideHome> createState() => _SleepyRideHomeState();
}

class _SleepyRideHomeState extends State<SleepyRideHome> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, child) {
        if (_appState.isRideActive) {
          return SleepModeScreen(appState: _appState);
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // App title
                  const Text(
                    'SleepyRide',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  const Text(
                    'Sleep peacefully — I\'ll wake you\nwhen we reach college!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Set Destination button
                  _buildActionButton(
                    icon: Icons.location_on_outlined,
                    text: _appState.destination ?? 'Set Destination',
                    subtitle: _appState.destination != null ? 'Tap to change' : null,
                    onTap: () => _showDestinationPicker(),
                    isCompleted: _appState.destination != null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Select Wake-up Song button
                  _buildActionButton(
                    icon: Icons.music_note_outlined,
                    text: _appState.wakeUpSong ?? 'Select Wake-up Song',
                    subtitle: _appState.wakeUpSong != null ? 'Tap to change' : null,
                    onTap: () => _showSongPicker(),
                    isCompleted: _appState.wakeUpSong != null,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Start Ride button
                  GestureDetector(
                    onTap: _canStartRide() ? () => _appState.startRide() : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _canStartRide() ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 28,
                            color: _canStartRide() ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Start Ride',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _canStartRide() ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Sleep icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_very_satisfied,
                          size: 60,
                          color: Colors.blue,
                        ),
                        Positioned(
                          top: 15,
                          right: 20,
                          child: Text(
                            'Z\n Z\n  Z',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              height: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom text
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You\'re safe to sleep ',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text('😴', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    String? subtitle,
    required VoidCallback onTap,
    bool isCompleted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isCompleted ? Colors.green : Colors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.green : Colors.black,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }

  bool _canStartRide() {
    return _appState.destination != null && _appState.wakeUpSong != null;
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DestinationPicker(appState: _appState),
    );
  }

  void _showSongPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SongPicker(appState: _appState),
    );
  }
}// En
hanced Destination Picker with Search
class DestinationPicker extends StatefulWidget {
  final AppState appState;

  const DestinationPicker({super.key, required this.appState});

  @override
  State<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchTimer;

  final List<Map<String, dynamic>> _popularPlaces = [
    {
      'name': 'SRM University',
      'lat': 12.8230,
      'lng': 80.0444,
      'type': 'University',
      'address': 'Kattankulathur, Tamil Nadu, India',
    },
    {
      'name': 'MIT College',
      'lat': 18.5204,
      'lng': 73.8567,
      'type': 'College',
      'address': 'Pune, Maharashtra, India',
    },
    {
      'name': 'IIT Bombay',
      'lat': 19.1334,
      'lng': 72.9133,
      'type': 'Institute',
      'address': 'Powai, Mumbai, Maharashtra, India',
    },
    {
      'name': 'Anna University',
      'lat': 13.0067,
      'lng': 80.2206,
      'type': 'University',
      'address': 'Chennai, Tamil Nadu, India',
    },
    {
      'name': 'Phoenix MarketCity',
      'lat': 13.0827,
      'lng': 80.2707,
      'type': 'Mall',
      'address': 'Velachery, Chennai, Tamil Nadu, India',
    },
    {
      'name': 'Chennai Central Railway Station',
      'lat': 13.0827,
      'lng': 80.2707,
      'type': 'Transport',
      'address': 'Chennai, Tamil Nadu, India',
    },
  ];

  @override
  void initState() {
    super.initState();
    widget.appState.loadSavedDestinations();
    _loadInitialSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _loadInitialSuggestions() {
    setState(() {
      _searchResults = [
        ...widget.appState.recentDestinations,
        ..._popularPlaces,
      ];
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    _searchTimer?.cancel();

    if (query.isEmpty) {
      _loadInitialSuggestions();
      return;
    }

    // Debounce search
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchResults = _popularPlaces
          .where((place) =>
              place['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              place['address'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectDestination(Map<String, dynamic> destination) {
    final name = destination['name'] as String;
    final lat = destination['lat'] as double;
    final lng = destination['lng'] as double;
    final address = destination['address'] as String?;
    
    _showConfirmation(name, lat, lng, address);
  }

  void _addCustomDestination() {
    final name = _searchController.text.trim();
    if (name.isNotEmpty) {
      // Generate coordinates based on place type
      final random = Random();
      double lat, lng;
      
      if (name.toLowerCase().contains('college') || name.toLowerCase().contains('university')) {
        lat = 12.0 + (random.nextDouble() * 16);
        lng = 77.0 + (random.nextDouble() * 8);
      } else {
        lat = 12.5 + (random.nextDouble() * 15);
        lng = 77.0 + (random.nextDouble() * 7);
      }
      
      _showConfirmation(name, lat, lng, 'Custom destination');
    }
  }

  void _showConfirmation(String name, double lat, double lng, String? address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set "$name" as your destination?'),
            const SizedBox(height: 12),
            if (address != null)
              Text(
                address,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.appState.setDestination(name, lat, lng, address: address);
              Navigator.pop(context);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Destination set to: $name ✅'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Set Your Destination',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Type any destination (college, mall, etc.)...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Custom destination button
          if (_isSearching && _searchController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _addCustomDestination,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_location, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set "${_searchController.text.trim()}" as destination',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Results list
          Expanded(
            child: _searchResults.isEmpty && _isSearching
                ? const Center(
                    child: Text(
                      'Type any place name above to set as destination',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final destination = _searchResults[index];
                      final name = destination['name'] as String;
                      final address = destination['address'] as String? ?? '';
                      final isRecent = destination['timestamp'] != null;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            isRecent ? Icons.history : Icons.location_on,
                            color: isRecent ? Colors.purple : Colors.blue,
                          ),
                          title: Text(name),
                          subtitle: address.isNotEmpty ? Text(address) : null,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectDestination(destination),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}