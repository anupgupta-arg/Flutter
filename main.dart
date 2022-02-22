import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: const TextTheme(
            headline6: TextStyle(
          color: Colors.yellow,
          fontSize: 50,
        )),
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Screenshot Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  List<String> imagePaths = [];
  @override
  void initState() {
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
                controller: screenshotController,
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Image(
                      image: NetworkImage(
                          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                    ),
                    Text(
                      "Hello ji bye bye !!!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                )

                //  Container(
                //   padding: const EdgeInsets.all(30.0),
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blueAccent, width: 5.0),
                //     color: Colors.amberAccent,
                //   ),
                //   child: const Text("This widget will be captured as an image"),
                // ),
                ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              child: const Text(
                'Capture Above Widget',
              ),
              onPressed: () {
                screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((capturedImage) async {
                  ShowCapturedWidget(context, capturedImage);
                }).catchError((onError) {
                  print(onError);
                });
              },
            ),
            ElevatedButton(
              child: const Text(
                'Capture An Invisible Widget',
              ),
              onPressed: () {
                var container = Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 5.0),
                      color: Colors.redAccent,
                    ),
                    child: Text(
                      "This is an invisible widget",
                      style: Theme.of(context).textTheme.headline6,
                    ));
                screenshotController
                    .captureFromWidget(
                        InheritedTheme.captureAll(
                            context, Material(child: container)),
                        delay: const Duration(seconds: 1))
                    .then((capturedImage) {
                  ShowCapturedWidget(context, capturedImage);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Captured widget screenshot"),
        ),
        body: Column(
          children: [
            Center(
              child: capturedImage != null
                  ? Image.memory(capturedImage)
                  : Container(),
            ),
            ElevatedButton(
              child: const Text("Share"),
              onPressed: () {
                // _onShare(context);
                // _saved(capturedImage);
                _savedImg(capturedImage);
                print("Share Button Pressed");
              },
            )
          ],
        ),
      ),
    );
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox;

    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: "",
          subject: "",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share("",
          subject: "",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  _savedImg(Uint8List image) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    File imgFile = File('$directory/screenshot.png');
    imgFile.writeAsBytesSync(image);
    var imgPath = '$directory/screenshot.png';
    print("imgFile Path" + imgPath);
    imagePaths.add(imgPath);
    _onShare(context);
  }
}
