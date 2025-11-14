import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class SecretPage extends StatefulWidget {
  const SecretPage({super.key});

  @override
  State<SecretPage> createState() => _SecretPageState();
}

class _SecretPageState extends State<SecretPage> {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  Map<String, dynamic> _storageData = {};
  bool _isLoading = false;
  String? _currentBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
    _loadAllData();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Load current baseUrl from storage
  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    setState(() {
      _currentBaseUrl = baseUrl;
      _baseUrlController.text = baseUrl ?? '';
    });
  }

  /// Save baseUrl to SharedPreferences
  Future<void> _saveBaseUrl() async {
    if (_baseUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a base URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseUrl', _baseUrlController.text.trim());
      
      // Update ApiClient baseUrl
      await ApiClient().updateBaseUrl();
      
      setState(() {
        _currentBaseUrl = _baseUrlController.text.trim();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base URL saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload all data to show updated baseUrl
      await _loadAllData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving base URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Clear baseUrl (use default)
  Future<void> _clearBaseUrl() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('baseUrl');
      
      // Update ApiClient to use default baseUrl
      await ApiClient().updateBaseUrl();
      
      setState(() {
        _currentBaseUrl = null;
        _baseUrlController.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base URL cleared. Using default URL.'),
          backgroundColor: Colors.orange,
        ),
      );

      await _loadAllData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing base URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Save custom key-value pair
  Future<void> _saveData() async {
    if (_keyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyController.text.trim(), _valueController.text);
      
      setState(() {
        _isLoading = false;
        _keyController.clear();
        _valueController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadAllData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Load all keys and values from SharedPreferences
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final data = <String, dynamic>{};
      for (final key in keys) {
        final value = prefs.get(key);
        data[key] = value;
      }

      setState(() {
        _storageData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Delete a key-value pair
  Future<void> _deleteKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Key "$key" deleted'),
          backgroundColor: Colors.orange,
        ),
      );

      // If deleting baseUrl, update ApiClient
      if (key == 'baseUrl') {
        await ApiClient().updateBaseUrl();
        _currentBaseUrl = null;
        _baseUrlController.clear();
      }

      await _loadAllData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting key: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Page - Storage Manager'),
        backgroundColor: const Color(0xFF136AF6),
      ),
      body: _isLoading && _storageData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Base URL Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.link,
                                color: Color(0xFF136AF6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Base URL Configuration',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentBaseUrl != null
                                ? 'Current: $_currentBaseUrl'
                                : 'Current: Using default (http://localhost:8080)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _baseUrlController,
                            decoration: InputDecoration(
                              labelText: 'Base URL',
                              hintText: 'http://localhost:8080',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.api),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _saveBaseUrl,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save Base URL'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF136AF6),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : _clearBaseUrl,
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Custom Key-Value Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.storage,
                                color: Color(0xFF136AF6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Custom Key-Value Storage',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _keyController,
                            decoration: InputDecoration(
                              labelText: 'Key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Value',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.text_fields),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveData,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Key-Value'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF136AF6),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // All Stored Data Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.list,
                                    color: Color(0xFF136AF6),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'All Stored Data',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _isLoading ? null : _loadAllData,
                                icon: const Icon(Icons.refresh),
                                tooltip: 'Refresh',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total keys: ${_storageData.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_storageData.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'No data stored',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._storageData.entries.map((entry) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: entry.key == 'baseUrl'
                                    ? Colors.blue[50]
                                    : Colors.grey[50],
                                child: ListTile(
                                  leading: Icon(
                                    entry.key == 'baseUrl'
                                        ? Icons.link
                                        : entry.key == 'user'
                                            ? Icons.person
                                            : entry.key == 'auth_token'
                                                ? Icons.lock
                                                : Icons.storage,
                                    color: entry.key == 'baseUrl'
                                        ? Colors.blue
                                        : Colors.grey[700],
                                  ),
                                  title: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    entry.value.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteKey(entry.key),
                                  ),
                                  isThreeLine: entry.value.toString().length > 30,
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
