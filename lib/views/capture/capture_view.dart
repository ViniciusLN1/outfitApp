import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../models/item_color.dart';
import '../../services/background_removal_service.dart';
import '../../services/user_scope.dart';

enum _UiState { sourceSelection, camera }

class CaptureView extends ConsumerStatefulWidget {
  const CaptureView({super.key});

  @override
  ConsumerState<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends ConsumerState<CaptureView> {
  _UiState _uiState = _UiState.sourceSelection;
  CameraController? _cameraController;
  bool _isProcessing = false;
  Uint8List? _finalImage;

  final _nameController = TextEditingController();
  String _selectedCategory = ClothingCategory.camisa.name;
  String? _selectedColor;

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;
    final controller = CameraController(cameras.first, ResolutionPreset.high);
    await controller.initialize();
    if (!mounted) return;
    setState(() => _cameraController = controller);
  }

  Future<void> _selectCamera() async {
    setState(() => _uiState = _UiState.camera);
    await _initCamera();
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    await _handleBgChoice(bytes);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      setState(() => _isProcessing = false);
      await _handleBgChoice(bytes);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao capturar: $e')),
        );
      }
    }
  }

  Future<void> _handleBgChoice(Uint8List rawBytes) async {
    if (!mounted) return;
    final remove = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover fundo?'),
        content: const Text('Deseja remover o fundo desta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (remove == null || !mounted) return;
    if (!remove) {
      setState(() => _finalImage = rawBytes);
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final result = await BackgroundRemovalService().removeBackground(rawBytes);
      if (mounted) setState(() => _finalImage = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha na remoção de fundo. Usando imagem original.')),
        );
        setState(() => _finalImage = rawBytes);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveItem() async {
    final png = _finalImage;
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
      final path = await ref.read(imageStorageServiceProvider).savePng(png);
      await ref.read(clothingControllerProvider.notifier).addItem(
            name: name,
            imagePath: path,
            category: _selectedCategory,
            color: _selectedColor,
          );
      if (mounted) {
        setState(() {
          _finalImage = null;
          _uiState = _UiState.sourceSelection;
          _cameraController?.dispose();
          _cameraController = null;
          _nameController.clear();
          _selectedCategory = ClothingCategory.camisa.name;
          _selectedColor = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peça salva com sucesso!')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _reset() {
    _cameraController?.dispose();
    setState(() {
      _cameraController = null;
      _uiState = _UiState.sourceSelection;
      _finalImage = null;
      _nameController.clear();
      _selectedCategory = ClothingCategory.camisa.name;
      _selectedColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing && _finalImage == null && _uiState == _UiState.sourceSelection) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Removendo fundo…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    if (_finalImage != null) return _buildPreviewForm();
    if (_uiState == _UiState.camera) return _buildCameraView();
    return _buildSourceSelection();
  }

  Widget _buildSourceSelection() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar Peça')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 64, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text('Nova peça', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Fotografe a roupa ou escolha uma imagem da galeria.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Câmera'),
                  onPressed: _selectCamera,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                  onPressed: _pickFromGallery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Câmera'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _reset,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          // Overlay de câmera é inerentemente escuro (scrim sobre a foto);
          // branco aqui é intencional e independe do tema.
          if (_isProcessing)
            ColoredBox(
              color: scheme.scrim.withValues(alpha: 0.55),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Removendo fundo…',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 48,
            left: 16,
            child: SafeArea(
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: scheme.scrim.withValues(alpha: 0.4),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _reset,
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _isProcessing ? null : _capturePhoto,
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
          onPressed: _reset,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.memory(
                _finalImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome da peça'),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                      items: ClothingCategory.values
                          .map((c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(c.displayName),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Cor (opcional)'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedColor,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (v) => setState(() => _selectedColor = v),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sem cor'),
                        ),
                        ...kItemColors.entries.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.key,
                            child: Row(
                              children: [
                                ColorDot(color: e.value),
                                const SizedBox(width: 10),
                                Text(colorLabel(e.key)),
                              ],
                            ),
                          ),
                        ),
                      ],
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
