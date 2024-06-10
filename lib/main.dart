import 'package:flutter/material.dart';
import 'package:ichooseapp/screens/youwin.dart';
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
  late Future<List<Image>> listImages;
  List<Image> finalList = List.unmodifiable([]);
  //Future<void> getlistimages() async {}
  @override
  void initState() {
    super.initState();
    firstSelectedIndex = -1;
    secondSelectedIndex = -1;

    listImages = splitImage('lib/assets/images/filmdirector.png');

    getlistimages();
  }

  Future<void> getlistimages() async {
    finalList = await listImages;
  }

  @override
  Widget build(BuildContext context) {
    //print(listImages);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Image Swap'),
        ),
        body: FutureBuilder(
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 3),
            // itemCount: listImages.length,
            future: listImages,
            //splitImage('lib/assets/images/filmdirector.png'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //List<Image> listimgs = snapshot.data!;
                return GridView.builder(
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          if (onPieceTapped(index, await listImages) == true) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WinScreen()));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: snapshot.data!.elementAt(index),
                        ),
                      );
                    });
              } else {
                return const CircularProgressIndicator();
              }
            })

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  bool onPieceTapped(int index, List<Image> listimg) {
    bool checking = false;
    setState(() {
      if (firstSelectedIndex == -1) {
        firstSelectedIndex = index;
      } else if (secondSelectedIndex == -1) {
        secondSelectedIndex = index;
        checking = swapPieces(listimg);
      }
    });
    return checking;
  }

  bool swapPieces(List<Image> listimg) {
    bool checkifsame = false;
    setState(() {
      if (firstSelectedIndex != -1 && secondSelectedIndex != -1) {
        final temp = listimg[firstSelectedIndex];
        listimg[firstSelectedIndex] = listimg[secondSelectedIndex];
        listimg[secondSelectedIndex] = temp;
        final bool check = checkifimageslistsame(listimg);
        if (check == true) {
          checkifsame = true;
        } else {
// Reset the selected indices
          firstSelectedIndex = -1;
          secondSelectedIndex = -1;
        }
      }
    });
    return checkifsame;
  }

  checkifimageslistsame(List<Image> listimg) {
    bool imageiteratorcheck = false;
    for (int k = 0; k < listimg.length; k++) {
      if (finalList[k] == listimg[k]) {
        imageiteratorcheck = true;
      } else {
        return false;
      }
    }
    return imageiteratorcheck;
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
