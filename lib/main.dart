import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classification App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageClassificationScreen(),
    );
  }
}

class ImageClassificationScreen extends StatefulWidget {
  const ImageClassificationScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ImageClassificationScreenState createState() =>
      _ImageClassificationScreenState();
}

class _ImageClassificationScreenState
    extends State<ImageClassificationScreen> {
  XFile? _imageFile;
  String _prediction = '';

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  void _predict() async {
    if (_imageFile == null) return;

    var url = Uri.parse('http://localhost:3000');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath(
        'imagefile', _imageFile!.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          _prediction = responseBody;
        });
      } else {
        setState(() {
          _prediction = 'Error: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _prediction = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classification App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _imageFile != null
              ? Image.file(File(_imageFile!.path),
              height: 200.0, width: 200.0)
              : Container(),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pick an Image'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _predict,
            child: const Text('Predict'),
          ),
          const SizedBox(height: 20),
          Text(
            'Prediction: $_prediction',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

