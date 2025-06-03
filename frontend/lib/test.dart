import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: GeminiKeyCheckerPage(),
  ));
}

class GeminiKeyCheckerPage extends StatefulWidget {
  @override
  _GeminiKeyCheckerPageState createState() => _GeminiKeyCheckerPageState();
}

class _GeminiKeyCheckerPageState extends State<GeminiKeyCheckerPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  String _status = '';
  bool _isLoading = false;

  Future<void> checkApiKey(String apiKey) async {
    setState(() {
      _isLoading = true;
      _status = 'Checking...';
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Hello'}
            ]
          }
        ]
      }),
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        _status = '✅ API Key is valid!';
      } else if (response.statusCode == 401) {
        _status = '❌ Invalid or expired API Key.';
      } else {
        _status =
        '⚠️ Unexpected error (${response.statusCode}): ${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini API Key Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Enter your Gemini API key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => checkApiKey(_apiKeyController.text.trim()),
              child: Text(_isLoading ? 'Checking...' : 'Check Key'),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: TextStyle(
                fontSize: 16,
                color: _status.contains('✅')
                    ? Colors.green
                    : _status.contains('❌')
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
