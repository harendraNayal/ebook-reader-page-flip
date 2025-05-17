import 'dart:async';
import 'dart:io';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Book Reader | Page Flip Animation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'E-Book Reader | Page Flip Animation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlipCardController flipController;

  // Adjust these UI settings according to design ***
  // double pageHeight = 600.0;
  // double pageWidth = 450.0;
  late double pageHeight;
  late double pageWidth;
  double pageBorderWidth = 3;
  double pageCornerRadius = 10;
  int pageFlipSpeedMs = 500;
  Color pageBorderColor = Colors.black45;
  Color pageBackgroundColor = Colors.pink.shade100;

  // ************************************************

  // Don't change these settings ###
  static const int NEXT = 0;
  static const int PREVIOUS = 1;
  int clickedButton = -1;
  int leftPageIndex = -1;
  int rightPageIndex = 0;
  int turningPageFrontIndex = 0;
  int turningPageBackIndex = 1;
  bool isPageTurned = false;
  bool isPageReversed = false;
  bool isRestrictButtonClick = false;
  bool isFlipCardVisible = false;

  // ##################################

  List<String> imageURLs = <String>[
    "assets/images/1.jpeg",
    "assets/images/2.jpeg",
    "assets/images/3.jpeg",
    "assets/images/4.jpeg",
    "assets/images/5.jpeg",
    "assets/images/6.jpeg",
    "assets/images/7.jpeg",
    "assets/images/8.jpeg",
    "assets/images/9.jpeg",
    "assets/images/10.jpeg",
    "assets/images/11.jpeg",
  ];

  @override
  void initState() {
    // init height width..
    if (kIsWeb) {
      pageHeight = 600.0;
    } else if (Platform.isAndroid || Platform.isIOS) {
      pageHeight = 320.0;
    } else {
      pageHeight = 600.0;
    }

    pageWidth = pageHeight * (3.0 / 4.0);

    flipController = FlipCardController();

    if (imageURLs.length.isEven) {
      imageURLs.add("assets/images/last_page.jpg");
    }

    turningPageFrontIndex = rightPageIndex;
    turningPageBackIndex = turningPageFrontIndex + 1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.yellow.shade50,
        appBar: kIsWeb || Platform.isAndroid || Platform.isIOS ? null : getAppBar(),
        body: Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  leftPageIndex == -1
                      ? SizedBox(
                          height: pageHeight,
                          width: pageWidth,
                        )
                      : Container(
                          height: pageHeight,
                          width: pageWidth,
                          decoration: BoxDecoration(
                            color: pageBackgroundColor,
                            border: Border.all(color: pageBorderColor, width: pageBorderWidth),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(pageCornerRadius),
                                bottomLeft: Radius.circular(pageCornerRadius)),
                          ),
                          child: Image.asset(imageURLs[leftPageIndex]), /*Image.network(imageURLs[leftPageIndex]),*/
                        ),
                  Container(
                    height: pageHeight,
                    width: pageWidth,
                    decoration: BoxDecoration(
                      color: pageBackgroundColor,
                      border: Border.all(color: pageBorderColor, width: pageBorderWidth),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(pageCornerRadius), bottomRight: Radius.circular(pageCornerRadius)),
                    ),
                    child: Image.asset(imageURLs[rightPageIndex]),
                  ),
                ],
              ),
            ),
            Center(
              child: FlipCard(
                controller: flipController,
                flipOnTouch: false,
                speed: pageFlipSpeedMs,
                // Fill the back side of the card to make in the same size as the front.
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                onFlip: () {
                  print(
                      "onFlip ??????????????????????? start :: left/right/Front/Back : $leftPageIndex/$rightPageIndex/$turningPageFrontIndex/$turningPageBackIndex");
                  isRestrictButtonClick = true;
                  if (clickedButton == NEXT) {
                    if (!isPageTurned) {
                      if (rightPageIndex < imageURLs.length - 1) {
                        turningPageFrontIndex = rightPageIndex;
                        turningPageBackIndex = turningPageFrontIndex + 1;
                        // setState(() {});
                      }
                      isFlipCardVisible = true;
                      rightPageIndex += 2;
                      setState(() {});
                    }
                  } else if (clickedButton == PREVIOUS) {
                    if (isPageReversed) {
                      leftPageIndex -= 2;
                      setState(() {});
                    }
                  }
                  print(
                      "onFlip ??????????????????????? end :: left/right/Front/Back : $leftPageIndex/$rightPageIndex/$turningPageFrontIndex/$turningPageBackIndex");
                },
                onFlipDone: (isFront) {
                  print(
                      "onFlipDone ********************* start :: left/right/Front/Back : $leftPageIndex/$rightPageIndex/$turningPageFrontIndex/$turningPageBackIndex");
                  if (clickedButton == NEXT) {
                    isPageTurned = isFront;
                    if (isPageTurned) {
                      leftPageIndex += 2;
                      isFlipCardVisible = false;
                      setState(() {});
                      Timer(const Duration(milliseconds: 100), () {
                        flipController.toggleCardWithoutAnimation();
                      });
                    }
                  } else if (clickedButton == PREVIOUS) {
                    isPageReversed = isFront;
                    if (isPageReversed) {
                      isFlipCardVisible = true;
                      setState(() {});
                      Timer(const Duration(milliseconds: 100), () {
                        flipController.toggleCard();
                      });
                    } else {
                      rightPageIndex -= 2;
                      isFlipCardVisible = false;
                      if (rightPageIndex > 0) {
                        turningPageBackIndex = leftPageIndex;
                        turningPageFrontIndex = turningPageBackIndex - 1;
                      }
                      setState(() {});
                    }
                  }
                  isRestrictButtonClick = false;
                  print(
                      "onFlipDone ********************* end :: left/right/Front/Back : $leftPageIndex/$rightPageIndex/$turningPageFrontIndex/$turningPageBackIndex");
                },
                front: Container(
                  child: getFrontPage(),
                ),
                back: Container(
                  child: getRearPage(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: OutlinedButton(
                    onPressed: () {
                      if (!isRestrictButtonClick) {
                        if (rightPageIndex < imageURLs.length - 1) {
                          clickedButton = NEXT;
                          flipController.toggleCard();
                        } else {
                          const snackBar = SnackBar(
                            content: Text('This is last page of book!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Text("Next")),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: OutlinedButton(
                    onPressed: () {
                      if (!isRestrictButtonClick) {
                        if (rightPageIndex > 0) {
                          clickedButton = PREVIOUS;
                          flipController.toggleCardWithoutAnimation();
                        } else {
                          const snackBar = SnackBar(
                            content: Text('This is first page of book!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Text("Previous")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFrontPage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: pageHeight,
          width: pageWidth,
        ),
        !isFlipCardVisible
            ? SizedBox(
                height: pageHeight,
                width: pageWidth,
              )
            : Container(
                height: pageHeight,
                width: pageWidth,
                decoration: BoxDecoration(
                  color: pageBackgroundColor,
                  border: Border.all(color: pageBorderColor, width: pageBorderWidth),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(pageCornerRadius), bottomRight: Radius.circular(pageCornerRadius)),
                ),
                child: Image.asset(imageURLs[turningPageFrontIndex]),
              ),
      ],
    );
  }

  Widget getRearPage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        !isFlipCardVisible
            ? SizedBox(
                height: pageHeight,
                width: pageWidth,
              )
            : Container(
                height: pageHeight,
                width: pageWidth,
                decoration: BoxDecoration(
                  color: pageBackgroundColor,
                  border: Border.all(color: pageBorderColor, width: pageBorderWidth),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(pageCornerRadius), bottomLeft: Radius.circular(pageCornerRadius)),
                ),
                child: Image.asset(imageURLs[turningPageBackIndex]),
              ),
        SizedBox(
          height: pageHeight,
          width: pageWidth,
        ),
      ],
    );
  }

  getAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("E-Book Reader | Page Flip Animation"),
    );
  }
}
