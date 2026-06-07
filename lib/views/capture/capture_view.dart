import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../services/background_removal_service.dart';
import '../../services/image_storage_service.dart';

class CaptureView extends ConsumerStatefulWidget {
  const CaptureView({super.key});

  @override
  ConsumerState<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends ConsumerState<CaptureView> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  Uint8List? _processedPng;

  final _nameController = TextEditingController();
  String _selectedCategory = ClothingCategory.camisa.name;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final controller =
        CameraController(cameras.first, ResolutionPreset.high);
    await controller.initialize();
    if (!mounted) return;
    setState(() => _cameraController = controller);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null) return;
    setState(() => _isProcessing = true);
    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      final png = await BackgroundRemovalService().removeBackground(bytes);
      setState(() => _processedPng = png);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveItem() async {
    final png = _processedPng;
    if (png == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a peça.')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final path = await ImageStorageService().savePng(png);
      await ref.read(clothingControllerProvider.notifier).addItem(
            name: name,
            imagePath: path,
            category: _selectedCategory,
          );
      if (mounted) {
        setState(() {
          _processedPng = null;
          _nameController.clear();
          _selectedCategory = ClothingCategory.camisa.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peça salva com sucesso!')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_processedPng != null) {
      return _buildPreviewForm();
    }
    return _buildCameraView();
  }

  Widget _buildCameraView() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          if (_isProcessing)
            const ColoredBox(
              color: Color(0x80000000),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _isProcessing ? null : _captureAndProcess,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvar Peça'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _processedPng = null),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.memory(
              _processedPng!,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da peça',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isDense: true,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                      items: ClothingCategory.values
                          .map((c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(c.name[0].toUpperCase() +
                                    c.name.substring(1)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _saveItem,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar Peça'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
