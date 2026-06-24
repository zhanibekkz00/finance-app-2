import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../utils/image_crop_helper.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../services/upload_service.dart';
import '../../widgets/glass_container.dart';
import 'package:uuid/uuid.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final UploadService _uploadService = UploadService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.category,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    final color = Color(c.colorValue);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        borderRadius: 16.0,
                        padding: 8.0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.15),
                              border: Border.all(color: color.withOpacity(0.3), width: 1),
                              image: c.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(c.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: c.imageUrl == null
                                ? Icon(
                                    IconData(c.iconCode, fontFamily: 'MaterialIcons'),
                                    color: color,
                                  )
                                : null,
                          ),
                          title: Text(
                            c.getLocalizedName(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            color: const Color(0xFF1E293B),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showAddDialog(context, category: c);
                              } else if (val == 'delete') {
                                _confirmDelete(context, ref, c);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Өңдеу', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Өшіру', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories_fab',
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CategoryModel category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
        content: Text('"${category.name}" санатын өшіру керек пе?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              ref.read(categoryProvider.notifier).delete(category.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, {CategoryModel? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    String categoryType = category?.type ?? 'expense';
    int selectedColor = category?.colorValue ?? 0xFF6366F1;
    String? localImagePath;
    String? uploadedImageUrl = category?.imageUrl;
    bool isUploading = false;

    final colorOptions = [
      0xFF6366F1, // Indigo
      0xFF8B5CF6, // Purple
      0xFFEC4899, // Pink
      0xFFEF4444, // Red
      0xFFF97316, // Orange
      0xFFF59E0B, // Amber
      0xFFEAB308, // Yellow
      0xFF84CC16, // Lime
      0xFF10B981, // Emerald
      0xFF14B8A6, // Teal
      0xFF06B6D4, // Cyan
      0xFF0EA5E9, // Light Blue
      0xFF3B82F6, // Blue
      0xFF64748B, // Slate
      0xFF94A3B8, // Light Slate
      0xFFF43F5E, // Rose
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            category == null ? 'Санат құру' : 'Санатты өңдеу',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Санат атауы',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
                  ),
                ),
                const SizedBox(height: 20),

                // Image Picker Row
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(selectedColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(selectedColor).withOpacity(0.3)),
                        image: localImagePath != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(localImagePath!) as ImageProvider
                                    : FileImage(File(localImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : (uploadedImageUrl != null
                                ? DecorationImage(image: NetworkImage(uploadedImageUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: localImagePath == null && uploadedImageUrl == null
                          ? const Icon(Icons.image_outlined, color: Colors.white38)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: isUploading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.06),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.photo_library_outlined, size: 18),
                              label: const Text('Фото жүктеу', style: TextStyle(fontSize: 13)),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  if (!mounted) return;
                                  final cropped = await ImageCropHelper.cropImage(
                                    sourcePath: image.path,
                                    cropStyle: CropStyle.rectangle,
                                    context: context,
                                  );
                                  if (cropped == null) return;

                                  setState(() {
                                    localImagePath = cropped.path;
                                    isUploading = true;
                                  });
                                  final bytes = await cropped.readAsBytes();
                                  final url = await _uploadService.uploadImage(bytes, image.name);
                                  setState(() {
                                    uploadedImageUrl = url;
                                    isUploading = false;
                                  });
                                }
                              },
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Color options palette
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Санат түсі:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...colorOptions.map((cValue) {
                      final isSelected = selectedColor == cValue;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = cValue),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(cValue),
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx2) {
                            Color tempColor = Color(selectedColor);
                            return AlertDialog(
                              backgroundColor: const Color(0xFF1E293B),
                              title: const Text('Түсті таңдаңыз', style: TextStyle(color: Colors.white)),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempColor,
                                  onColorChanged: (Color color) {
                                    tempColor = color;
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                  enableAlpha: false,
                                  labelTypes: const [],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Дайын', style: TextStyle(color: const Color(0xFF6366F1).withOpacity(0.8))),
                                  onPressed: () {
                                    setState(() {
                                      selectedColor = tempColor.value;
                                      if (!colorOptions.contains(selectedColor)) {
                                        colorOptions.add(selectedColor);
                                      }
                                    });
                                    Navigator.of(ctx2).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1),
                        ),
                        child: const Icon(Icons.palette, color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Болдырмау', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              onPressed: isUploading
                  ? null
                  : () {
                      final name = nameCtrl.text.trim();
                      if (name.isNotEmpty) {
                        if (category == null) {
                          ref.read(categoryProvider.notifier).add(CategoryModel(
                                id: const Uuid().v4(),
                                name: name,
                                colorValue: selectedColor,
                                iconCode: 58826, // Icons.category default code
                                type: categoryType,
                                imageUrl: uploadedImageUrl,
                                isDefault: false,
                              ));
                        } else {
                          ref.read(categoryProvider.notifier).updateCategory(
                                category.id,
                                CategoryModel(
                                  id: category.id,
                                  name: name,
                                  colorValue: selectedColor,
                                  iconCode: category.iconCode,
                                  type: categoryType,
                                  imageUrl: uploadedImageUrl,
                                  isDefault: false,
                                ),
                              );
                        }
                        Navigator.pop(ctx);
                      }
                    },
              child: Text(category == null ? 'Құру' : 'Сақтау'),
            ),
          ],
        ),
      ),
    );
  }
}
