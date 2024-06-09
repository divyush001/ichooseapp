import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'widgets/ListTileCustom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IchooseApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int firstSelectedIndex = -1;
  int secondSelectedIndex = -1;
  List<Image> listImages = List.empty();

  @override
  void initState() {
    super.initState();
    firstSelectedIndex = -1;
    secondSelectedIndex = -1;

    Future<void> getlistimages() async {
      listImages = await splitImage('lib/assets/images/filmdirector.png');
    }

    getlistimages();
  }

  @override
  Widget build(BuildContext context) {
    //print(listImages);
    return Scaffold(
        appBar: AppBar(
          title: Text('Image'),
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: listImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onPieceTapped(index, listImages),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: listImages[index],
                ),
              );
            })

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void onPieceTapped(int index, List<Image> listimg) {
    setState(() {
      if (firstSelectedIndex == -1) {
        firstSelectedIndex = index;
      } else if (secondSelectedIndex == -1) {
        secondSelectedIndex = index;
        swapPieces(listimg);
      }
    });
  }

  void swapPieces(List<Image> listimg) {
    setState(() {
      if (firstSelectedIndex != -1 && secondSelectedIndex != -1) {
        final temp = listimg[firstSelectedIndex];
        listimg[firstSelectedIndex] = listimg[secondSelectedIndex];
        listimg[secondSelectedIndex] = temp;

        // Reset the selected indices
        firstSelectedIndex = -1;
        secondSelectedIndex = -1;
      }
    });
  }
}

// List<ListTileCustom> _buildGridTileList(
//     int count, AsyncSnapshot<dynamic> snapshot) {
//   List<ListTileCustom> tileslist;

//   tileslist = List.generate(
//       count,
//       (i) => ListTileCustom(
//             index: i,
//             snapshot: snapshot,
//           ));

//   return tileslist;
// }

Future<List<Image>> splitImage(String path) async {
  imglib.Image? image = await decodeAsset(path);
  //Image img = getImage(path);

  // imglib.Image? image =
  //     imglib.decodeImage((await rootBundle.load(path)).buffer.asUint8List());

  List<Image> pieces = [];
  int x = 0, y = 0;
  int width = (image!.width / 3).floor();
  int height = (image.height / 3).floor();
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      imglib.Image croppedImage =
          imglib.copyCrop(image, x: x, y: y, width: width, height: height);
      pieces.add(Image.memory(imglib.encodeJpg(croppedImage)));
      x += width;
    }
    x = 0;
    y += height;
  }

  return pieces;
}

/* From documentation: 
   * https://github.com/brendan-duncan/image/blob/main/doc/flutter.md#convert-a-flutter-asset-to-the-dart-image-library
   */

// Image getImage(String path) {
//   return Image.asset(path);
// }

Future<imglib.Image?> decodeAsset(String path) async {
  final data = await rootBundle.load(path);

  // Utilize flutter's built-in decoder to decode asset images as it will be
  // faster than the dart decoder.
  final buffer =
      await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());

  final id = await ui.ImageDescriptor.encoded(buffer);
  final codec =
      await id.instantiateCodec(targetHeight: id.height, targetWidth: id.width);

  final fi = await codec.getNextFrame();

  final uiImage = fi.image;
  final uiBytes = await uiImage.toByteData();

  final image = imglib.Image.fromBytes(
      width: id.width,
      height: id.height,
      bytes: uiBytes!.buffer,
      numChannels: 4);

  return image;
}
