import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecretPage extends StatefulWidget {
  @override
  _SecretPageState createState() => _SecretPageState();
}

class _SecretPageState extends State<SecretPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  Map<String, Object> _storageData = {};

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String key = _keyController.text;
    String value = _valueController.text;
    if (key.isNotEmpty) {
      await prefs.setString(key, value);
      await _loadAllData();
      _keyController.clear();
      _valueController.clear();
    }
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storageData = prefs.getKeys().fold<Map<String, Object>>(
        {},
        (map, k) {
          map[k] = prefs.get(k) ?? '';
          return map;
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SecretPage")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _keyController,
              decoration: InputDecoration(labelText: 'Key'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Value'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: Text("Save"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAllData,
                child: ListView.builder(
                  itemCount: _storageData.length,
                  itemBuilder: (context, idx) {
                    String key = _storageData.keys.elementAt(idx);
                    return ListTile(
                      title: Text(key),
                      subtitle: Text(_storageData[key].toString()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}