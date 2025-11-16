import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docket Uploader',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: DocketUploaderPage(),
    );
  }
}

class DocketUploaderPage extends StatefulWidget {
  const DocketUploaderPage({super.key});

  @override
  _DocketUploaderPageState createState() => _DocketUploaderPageState();
}

class _DocketUploaderPageState extends State<DocketUploaderPage> {
  final picker = ImagePicker();
  File? _originalFile;
  File? _compressedFile;
  bool _isUploading = false;
  String? _selectedCategory;

  final List<String> categories = [
    'Electrical',
    'Plumbing',
    'Cleaning',
    'Security',
    'Other',
  ];

  Future<void> _takePhoto() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (picked == null) return;
    setState(() {
      _originalFile = File(picked.path);
      _compressedFile = null;
    });
  }

  Future<File?> _compressImage(File file, {int quality = 70}) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'cmp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      keepExif: false,
    );
    return result != null ? File(result.path) : null;
  }

  String _buildFilename(String category) {
    // Using timestamp with date+time to avoid collisions:
    final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final cleanedCategory = category.replaceAll(
      RegExp(r'\s+'),
      '_',
    ); // remove spaces
    return '${ts}_${cleanedCategory}_0.jpg';
  }

  Future<void> _upload() async {
    if (_originalFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No photo taken')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Select a category')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final originalSize = await _originalFile!.length();

      // compress
      _compressedFile = await _compressImage(_originalFile!, quality: 70);
      final compressedSize = _compressedFile != null
          ? await _compressedFile!.length()
          : originalSize;

      final filename = _buildFilename(_selectedCategory!);
      final storagePath = 'temp_images/$filename';

      // upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = ref.putFile(_compressedFile ?? _originalFile!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // write metadata to Firestore
      final doc = {
        'filename': filename,
        'storagePath': storagePath,
        'category': _selectedCategory,
        'uploadedAt': FieldValue.serverTimestamp(),
        'downloadUrl': downloadUrl,
        'originalSize': originalSize,
        'compressedSize': compressedSize,
      };
      await FirebaseFirestore.instance.collection('temp_uploads').add(doc);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload successful')));
      setState(() {
        _originalFile = null;
        _compressedFile = null;
        _selectedCategory = null;
      });
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((c) {
        return RadioListTile<String>(
          title: Text(c),
          value: c,
          groupValue: _selectedCategory,
          onChanged: (v) => setState(() => _selectedCategory = v),
        );
      }).toList(),
    );
  }

  Widget _buildImagePreview() {
    final file = _compressedFile ?? _originalFile;
    if (file == null) {
      return SizedBox(height: 200, child: Center(child: Text('No photo yet')));
    }
    return Column(
      children: [
        Image.file(file, height: 200),
        SizedBox(height: 8),
        Text('Size: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Docket Uploader')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildCategorySelector(),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: Icon(Icons.camera_alt),
              label: Text('Take Photo'),
            ),
            SizedBox(height: 12),
            _buildImagePreview(),
            SizedBox(height: 16),
            if (_isUploading) Center(child: CircularProgressIndicator()),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _upload,
                    child: Text('Compress & Upload'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
