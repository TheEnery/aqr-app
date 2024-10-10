import 'package:camera/camera.dart';
import 'package:cqr/camera_controller_extension.dart';
import 'package:flutter/material.dart';

import 'file:///home/enery/Documents/cqr/test/image_testers/test_color_diff.dart';
import 'file:///home/enery/Documents/cqr/test/image_testers/test_palette_diff.dart';

late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      _cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('Camera access denied.');
            break;
          default:
            debugPrint('Camera exception. Code: ${e.code}');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
      ),
      body: Center(child: _getCamera()),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final image = await controller.inMemoryImage();

              final pixel = image.getPixel(
                  (image.width / 2).round(), (image.height / 2).round());

              if (context.mounted) {
                final messenger = ScaffoldMessenger.of(context);

                messenger.hideCurrentMaterialBanner();

                messenger.showMaterialBanner(
                  MaterialBanner(
                    leading: Container(
                      width: 16.0,
                      height: 16.0,
                      color: Color.fromRGBO(pixel.r.toInt(), pixel.g.toInt(),
                          pixel.b.toInt(), 1.0),
                    ),
                    content: Text("R: ${pixel.r} G: ${pixel.g} B: ${pixel.b}"),
                    elevation: 1.0,
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => messenger.hideCurrentMaterialBanner(),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Scan'),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () async {
              final image = await controller.inMemoryImage();

              testColorDiff(image);
            },
            child: const Text('Test1'),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () async {
              final image = await controller.inMemoryImage();

              testPaletteDiff(image);
            },
            child: const Text('Test2'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _getCamera() {
    if (!controller.value.isInitialized) {
      return const Text("Something went wrong");
    }

    return CameraPreview(
      controller,
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
          ),
        ),
      ),
    );
  }
}
