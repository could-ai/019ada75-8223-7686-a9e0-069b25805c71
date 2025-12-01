import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isGenerating = false;
  bool _resultReady = false;
  String _selectedStyle = 'مودرن (Modern)';
  String _selectedRoomType = 'غرفة معيشة';

  final List<String> _styles = [
    'مودرن (Modern)',
    'كلاسيك (Classic)',
    'بوهيمي (Bohemian)',
    'صناعي (Industrial)',
    'اسكندنافية (Scandinavian)',
    'ريفي (Rustic)',
  ];

  final List<String> _roomTypes = [
    'غرفة معيشة',
    'غرفة نوم',
    'مطبخ',
    'حمام',
    'مكتب',
    'غرفة طعام',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        var f = await image.readAsBytes();
        setState(() {
          _webImageBytes = f;
          _selectedImage = image;
          _resultReady = false;
        });
      } else {
        setState(() {
          _selectedImage = image;
          _resultReady = false;
        });
      }
    }
  }

  void _generateDesign() {
    if (_selectedImage == null) return;

    setState(() {
      _isGenerating = true;
    });

    // محاكاة عملية الذكاء الاصطناعي
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isGenerating = false;
        _resultReady = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء التصميم بنجاح!')),
      );
    });
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _webImageBytes = null;
      _resultReady = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استوديو التصميم'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              tooltip: 'بدء من جديد',
            )
        ],
      ),
      body: Row(
        children: [
          // لوحة التحكم (للموبايل ستكون في الأسفل، للويب ستكون جانبية إذا كانت الشاشة عريضة)
          // هنا سنستخدم LayoutBuilder لتبسيط الأمر وجعلها عمودية دائماً للموبايل
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // منطقة عرض الصورة
                  _buildImageArea(),

                  const SizedBox(height: 24),

                  // أدوات التحكم
                  if (_selectedImage != null && !_resultReady && !_isGenerating)
                    _buildControls(),
                  
                  // زر الحفظ والمشاركة (يظهر بعد النتيجة)
                  if (_resultReady)
                    _buildResultActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_selectedImage == null)
            InkWell(
              onTap: _pickImage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 16),
                  Text(
                    'اضغط لرفع صورة الغرفة',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else if (_resultReady)
            // عرض النتيجة (صورة وهمية للمحاكاة)
            Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1616486338812-3dadae4b4f9d?q=80&w=1000&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'النتيجة (محاكاة)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            // عرض الصورة الأصلية
            Stack(
              fit: StackFit.expand,
              children: [
                kIsWeb
                    ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                if (_isGenerating)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'جاري تصميم غرفتك...',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات التصميم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // نوع الغرفة
            DropdownButtonFormField<String>(
              value: _selectedRoomType,
              decoration: const InputDecoration(
                labelText: 'نوع الغرفة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.room),
              ),
              items: _roomTypes.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRoomType = val!),
            ),
            
            const SizedBox(height: 16),

            // النمط
            DropdownButtonFormField<String>(
              value: _selectedStyle,
              decoration: const InputDecoration(
                labelText: 'نمط الديكور',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette),
              ),
              items: _styles.map((String style) {
                return DropdownMenuItem(value: style, child: Text(style));
              }).toList(),
              onChanged: (val) => setState(() => _selectedStyle = val!),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _generateDesign,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('تغيير الديكور'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _resultReady = false;
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('تعديل الإعدادات'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // هنا يمكن إضافة كود حفظ الصورة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الصورة في المعرض')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('حفظ الصورة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
