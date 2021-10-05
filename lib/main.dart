import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_draw_whiteboard/shape_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData.dark(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _height, _width;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DemoApp())));
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Container(
      height: _height,
      width: _width,
      color: Colors.white,
      child: Image.asset(
        'asset/images/drawinglogo.png',
        height: 150,
        width: 200,
      ),
    );
  }
}

class DemoApp extends StatefulWidget {
  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  DrawingController controller;
  GlobalKey _globalKey = new GlobalKey();
  var captureImage;
  var appHeight, appWidth;
  var message;
  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      setState(() {
        captureImage = pngBytes;
      });
      if (pngBytes != null) {
        showDialog(
          context: context, barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)), //this right here
              child: Container(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.close),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory(
                              captureImage,
                              height: 300,
                              width: 200,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await saveImage(captureImage);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.save),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  var result = await (Connectivity()
                                      .checkConnectivity());
                                  if (result == ConnectivityResult.mobile ||
                                      result == ConnectivityResult.wifi) {
                                    await saveandShare(captureImage);
                                  } else {
                                    showMessage("Please Check Your Connection");
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.share),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = "Drawing_$time";
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filepath'];
  }

  Future saveandShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytes(bytes);
    final text = "Share From Drawing App";
    await Share.shareFiles([image.path], text: text);
  }

  @override
  void initState() {
    // TODO: implement initState
    controller = DrawingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.close();
    super.dispose();
  }

  static Route<Object> _dialogBuilder(BuildContext context, Object arguments) {
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            child: Icon(
              Icons.close_outlined,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text('About Us!',
                    style: GoogleFonts.mcLaren(
                        // fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 30,
                        color: Colors.black)),
              ),
              Divider(
                thickness: 3,
                color: Colors.black,
              ),
              Text(
                  '''Welcome to Drawing app, your number one source for Drawings. We're dedicated to providing you the very best drawing, with an emphasis on draw picture,color picture, save picture, share picture.
\nFounded in 2021 by Kinnari Dabgar, Drawing App has come a long way from its beginnings in MehtaSoftrack. When Kinnari Dabgar first started out, her job in MehtaSoftrack drove them to create their own Application.
\nWe hope you enjoy our Application as much as we enjoy offering them to you.

Sincerely,

Kinnari Dabgar''',
                  style: GoogleFonts.mcLaren(
                      // fontStyle: FontStyle.italic,
                      letterSpacing: 0.8,
                      color: Colors.black))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appHeight = MediaQuery.of(context).size.height;
    appWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Drawing',
          style: GoogleFonts.mcLaren(
              // fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              fontSize: 20,
              color: Colors.amber),
        ),
        centerTitle: true,
      ),
      drawer: Container(
        width: appWidth * 0.7,
        child: Drawer(
          child: Container(
            color: Colors.white,
            height: appHeight,
            child: ListView(
              children: [
                Column(
                  children: [
                    Image.asset(
                      'asset/images/drawinglogo.png',
                      height: 150,
                      width: 200,
                    ),
                    Text(
                      "Drawing",
                      style: GoogleFonts.mcLaren(
                          //fontStyle: FontStyle.italic,
                          fontSize: 30,
                          color: Colors.black),
                    ),
                  ],
                ),
                Divider(
                  thickness: 3,
                  color: Colors.amber,
                ),
                ListTile(
                  leading: Icon(Icons.home_outlined, color: Colors.black),
                  trailing: Text(
                    "Home",
                    style: GoogleFonts.mcLaren(
                        //fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => DemoApp()));
                  },
                ),
                Divider(
                  thickness: 3,
                  color: Colors.amber,
                ),
                ListTile(
                  leading:
                      Icon(Icons.architecture_outlined, color: Colors.black),
                  trailing: Text(
                    "Shape",
                    style: GoogleFonts.mcLaren(
                        //fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ShapePage()));
                  },
                ),
                Divider(
                  thickness: 3,
                  color: Colors.amber,
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.black),
                  trailing: Text(
                    "About Us",
                    style: GoogleFonts.mcLaren(
                        //fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.of(context).restorablePush(_dialogBuilder);
                  },
                ),
                Divider(
                  thickness: 3,
                  color: Colors.amber,
                ),
                ListTile(
                  leading: Icon(Icons.share_outlined, color: Colors.black),
                  trailing: Text(
                    "Share",
                    style: GoogleFonts.mcLaren(
                        //fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Share.share("https://github.com/KinnariDabgar");
                  },
                ),
                SizedBox(
                  height: appHeight * 0.22,
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    children: [
                      Align(
                          alignment: Alignment.bottomCenter,
                          child:
                              Icon(Icons.favorite_outline, color: Colors.red)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("Designed By Kinnari",
                            style: GoogleFonts.mcLaren(
                                //fontStyle: FontStyle.italic,
                                fontSize: 15,
                                color: Colors.black)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: appHeight,
        width: appWidth,
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: Whiteboard(
                  controller: controller,
                  style: WhiteboardStyle(
                    toolboxColor: Colors.amber,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    child: Icon(Icons.camera),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      _capturePng();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.amber,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.stacked_line_chart),
              label: "Line",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LinePaintPage()));
              }),
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.crop_landscape),
              label: "Rectangle",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RectanglePaintPage()));
              }),
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.crop_square),
              label: "Square",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RoundedRectanglePaintPage()));
              }),
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.circle_outlined),
              label: "Circle",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CirclePaintPage()));
              }),
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.architecture_outlined),
              label: "Arc",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ArcPaintPage()));
              }),
          SpeedDialChild(
              backgroundColor: Colors.amber,
              child: Icon(Icons.warning),
              label: "Triangle",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TrianglePaintPage()));
              }),
        ],
      ),
    );
  }

  Widget showMessage(String message) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        color: Colors.black54,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 28.0),
      backgroundColor: Colors.green[900],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.chrome_reader_mode, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Pressed Read Later'),
          label: 'Read',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.create, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Pressed Write'),
          label: 'Write',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.laptop_chromebook, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Pressed Code'),
          label: 'Code',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }
}
