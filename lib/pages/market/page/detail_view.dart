import 'package:clippy_flutter/paralellogram.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io';
import 'package:flutter/services.dart';
import '../constant/constant.dart';
import '../model/champion.dart';

class DetailView extends StatefulWidget {
  final Champion champion;

  const DetailView({required this.champion});

  @override
  _DetailViewState createState() => _DetailViewState(champion: champion);
}

class _DetailViewState extends State<DetailView> with TickerProviderStateMixin {
  final Champion champion;

  _DetailViewState({required this.champion});

  bool init = false;

  late Animation<double> animation;
  late AnimationController controller;

  bool isDownloading = false; // State to track download progress

  /// Handles button press based on button text
  Future<void> handleButtonPress() async {
    if (widget.champion.buttunText == "VISIT THE PAGE") {
      // Navigate to the page specified in the champion's page field

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.champion.targetPage,
        ),
      );
    } else if (widget.champion.buttunText == "DOWNLOAD FILE") {
      // Start download
      setState(() {
        isDownloading = true;
      });

      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/data_file.pdf';
        final byteData =
            await rootBundle.load('assets/data/${champion.imageUrl}.pdf');
        final file = File(filePath);

        await file.writeAsBytes(byteData.buffer.asUint8List());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath')),
        );

        await OpenFilex.open(filePath);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download file: $e')),
        );
      } finally {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    Tween<double> tween = Tween(begin: 0.0, end: 400.0);

    animation = tween
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInExpo))
      ..addListener(() {
        setState(() {});
      });

    controller.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        init = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgoundColor,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: LayoutBuilder(builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;

                return Stack(children: [
                  Stack(
                    children: [
                      Hero(
                        tag: champion.name.toUpperCase(),
                        child: Image.asset(
                          'assets/logo/${champion.imageUrl}.jpg',
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: init ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          width: maxWidth,
                          height: maxWidth,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                backgoundColor.withOpacity(0.0),
                                backgoundColor.withOpacity(0.0),
                                backgoundColor.withOpacity(0.0),
                                backgoundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      children: [
                        Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 20),
                            width: double.infinity,
                            height: 320,
                            child: Stack(
                              children: [
                                AnimatedBorder(animation: animation),
                                Align(
                                  alignment: Alignment.center,
                                  child: AnimatedOpacity(
                                    opacity: init ? 1 : 0,
                                    duration: Duration(milliseconds: 500),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: OutlinedButton(
                                                      onPressed: isDownloading
                                                          ? null
                                                          : handleButtonPress, // Disable button during download
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            Colors.black,
                                                        side: const BorderSide(
                                                            color: Colors.black,
                                                            width: 2.0),
                                                      ),
                                                      child: isDownloading
                                                          ? const CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .green),
                                                            )
                                                          : Text(
                                                              widget.champion
                                                                  .buttunText,
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      2.2),
                                                            ),
                                                    ),
                                                  ),
                                                  Text("Description",
                                                      style: textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                              color: Color(
                                                                  0xffAE914B)))
                                                ]),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30.0),
                                              child: Divider(
                                                color: Colors.black87,
                                                height: 1,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 30),
                                              child: Text(champion.description,
                                                  style: textTheme.bodyLarge,
                                                  maxLines: 6,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )
                                          ]),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: init ? 1.0 : 0.0,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 185),
                        width: double.infinity,
                        height: 270,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                champion.name.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Colors.black,
                                        letterSpacing: 4 +
                                            25 *
                                                ((400 - animation.value) /
                                                    400.0)),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ]);
              }),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 25, top: 25),
              child: CustomBackButton()),
        ],
      ),
    );
  }
}

class DifficultyGraph extends StatelessWidget {
  final count;
  const DifficultyGraph({this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Parallelogram(
        cutLength: 10.0,
        child: Container(
          color: difficultyEnableColor,
          width: 25.0,
          height: 10.0,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 16),
        child: Parallelogram(
          cutLength: 10.0,
          child: Container(
            color: count > 0 ? difficultyEnableColor : difficultyDisableColor,
            width: 25.0,
            height: 10.0,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 32),
        child: Parallelogram(
          cutLength: 10.0,
          child: Container(
            color: count > 1 ? difficultyEnableColor : difficultyDisableColor,
            width: 25.0,
            height: 10.0,
          ),
        ),
      ),
    ]);
  }
}

class AnimatedBorder extends StatelessWidget {
  const AnimatedBorder({
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, snapshot) {
          return CustomPaint(
            painter: MyPainter(value: animation.value),
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          );
        },
      );
    });
  }
}

class CustomBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.grey[850]?.withOpacity(0.3), shape: BoxShape.circle),
      child: InkWell(
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double value;

  MyPainter({required this.value});

  final paintBorder = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final transparentBorder = Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    if (value < 15) {
      double lineValue = size.width * value / 100;
      path.lineTo(lineValue, 0);
      canvas.drawPath(path, paintBorder);
      return;
    } else {
      path.lineTo(size.width * 15 / 100, 0);
      canvas.drawPath(path, paintBorder);
    }

    path = Path();
    path.moveTo(size.width * 15 / 100, 0);

    if (value >= 15 && value <= 85) {
      double lineValue = size.width * value / 100;
      path.lineTo(lineValue, 0);
      canvas.drawPath(path, transparentBorder);
      return;
    } else {
      path.lineTo(size.width * 85 / 100, 0);
      canvas.drawPath(path, transparentBorder);
    }

    path = Path();
    path.moveTo(size.width * 85 / 100, 0);

    if (value > 85 && value < 100) {
      double lineValue = size.width * value / 100;
      path.lineTo(lineValue, 0);
      canvas.drawPath(path, paintBorder);
      return;
    } else {
      path.lineTo(size.width, 0);
      canvas.drawPath(path, paintBorder);
    }

    if (value < 200) {
      double lineValue = size.height * (value - 100) / 100;
      path.lineTo(size.width, lineValue);
      canvas.drawPath(path, paintBorder);
      return;
    } else {
      path.lineTo(size.width, size.height);
      canvas.drawPath(path, paintBorder);
    }

    path = Path();
    path.moveTo(size.width, size.height);

    if (value < 300) {
      double lineValue = size.width - size.width * (value - 200) / 100;
      path.lineTo(lineValue, size.height);
      canvas.drawPath(path, paintBorder);
      return;
    } else {
      path.lineTo(0, size.height);
      canvas.drawPath(path, paintBorder);
    }

    path = Path();
    path.moveTo(0, size.height);

    if (value < 400) {
      double lineValue = size.height - size.height * (value - 300) / 100;
      path.lineTo(0, lineValue);
      canvas.drawPath(path, paintBorder);
      return;
    } else {
      path.lineTo(0, 0);
      canvas.drawPath(path, paintBorder);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
