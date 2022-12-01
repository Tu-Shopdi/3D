import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:snapshot/utils/image_downloader.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math' as math;
import 'package:collection/collection.dart';

class CustomAnimationPage extends StatefulWidget {
  @override
  _CustomAnimationPageState createState() => _CustomAnimationPageState();
}

class _CustomAnimationPageState extends State<CustomAnimationPage> {
  late ARKitController arkitController;
  ARKitReferenceNode? node;
  ARKitReferenceNode? changeNode;
  bool idle = true;

  double scaleModel = 1.2;
  double moveDown = -5;
  double moveFar = -10;
  double moveLeftRight = 0;
  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(title: const Text('Custom Animation')),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              // FloatingActionButton(
              //   onPressed: () async {
              //     playAnimation();
              //   },
              //   backgroundColor: Colors.red,
              //   child: Icon(idle ? Icons.play_arrow : Icons.stop),
              // ),
              InkWell(
                onLongPress: () {
                  moveLeftRightModel(isMove: true);
                },
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () async {
                    moveLeftRightModel(isMove: false);
                  },
                  child: Icon(Icons.switch_left),
                ),
              ),
              const SizedBox(width: 2,),
              InkWell(
                onLongPress: () {
                  zoomModel(isAdd: false);
                },
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () async {
                    zoomModel(isAdd: true);
                    },
                  child: Icon(Icons.zoom_in_map),
                ),
              ),
              const Spacer(),
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: () async {
                  try {
                    final image =
                    await arkitController.snapshot() as MemoryImage;
                    final isSuccess = await imageDownload(
                      bytes: image.bytes,
                    );

                    _showSnackBar(this.context,
                        msg: isSuccess == true
                            ? 'Lưu ảnh thành công'
                            : 'Lưu ảnh thất bại, thử lại.');
                    // await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => SnapshotPreview(
                    //       imageProvider: image,
                    //     ),
                    //   ),
                    // );
                  } catch (e) {
                    print(e);
                  }
                },
                child: Icon(Icons.add_a_photo_outlined),
              ),
              const Spacer(),
              InkWell(
                onLongPress: () {
                  moveFarModel(isMove: false);
                },
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () async {
                    moveFarModel(isMove: true);
                  },
                  child: Icon(Icons.file_upload_outlined),
                ),
              ),
              const SizedBox(width: 2,),
              InkWell(
                onLongPress: () {
                  moveDownModel(isMove: false);
                },
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () async {
                    moveDownModel(isMove: true);
                  },
                  child: Icon(Icons.download_outlined),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          child: ARKitSceneView(
            enablePinchRecognizer: true,
            enablePanRecognizer: true,
            enableRotationRecognizer: true,
            planeDetection: ARPlaneDetection.horizontal,
            onARKitViewCreated: onARKitViewCreated,
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    arkitController.addCoachingOverlay(CoachingOverlayGoal.horizontalPlane);
    // this.arkitController.onNodePinch = (pinch) => _onPinchHandler(pinch);
    // this.arkitController.onNodePan = (pan) => _onPanHandler(pan);
    // this.arkitController.onNodeRotation =
    //     (rotation) => _onRotationHandler(rotation);
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitPlaneAnchor)) {
      return;
    }
    _addPlane(arkitController, anchor);
  }

  void _addPlane(ARKitController? controller, ARKitPlaneAnchor anchor) {
    if (node != null) {
      controller?.remove(node!.name);
    }
    node = ARKitReferenceNode(
      url: 'models.scnassets/idleFixed.dae',
      eulerAngles: vector.Vector3.zero(),
      position: vector.Vector3(0, -5, -10),
      scale: vector.Vector3.all(1.2),
    );
    controller?.add(node!, parentNodeName: anchor.nodeName);
    changeNode = node;
  }

  void zoomModel({bool isAdd = true}){
    isAdd ? scaleModel += 0.1 : scaleModel -= 0.1;
    setState(() {});

    print('scaleModel: $scaleModel');
    final scale = vector.Vector3.all(scaleModel);
    node?.scale = scale;
    setState(() {});
  }

  void moveDownModel({bool isMove = true}){
    isMove ? moveDown += 1 : moveDown -= 1;
    setState(() {});


    final position = vector.Vector3(moveLeftRight, moveDown, moveFar);
    node?.position = position;
    setState(() {});
  }

  void moveFarModel({bool isMove = true}){
    isMove ? moveFar += 1 : moveFar -= 1;
    setState(() {});

    final position = vector.Vector3(moveLeftRight, moveDown, moveFar);
    node?.position = position;
    setState(() {});
  }

  void moveLeftRightModel({bool isMove = true}){
    isMove ? moveLeftRight += 1 : moveLeftRight -= 1;
    setState(() {});

    final position = vector.Vector3(moveLeftRight, moveDown, moveFar);
    node?.position = position;
    setState(() {});
  }

  void playAnimation() async{
    if (idle) {
      await arkitController.playAnimation(
          key: 'dancing',
          sceneName: 'models.scnassets/twist_danceFixed',
          animationIdentifier: 'twist_danceFixed-1');
    } else {
      await arkitController.stopAnimation(key: 'dancing');
    }
    setState(() => idle = !idle);
  }

  void _showSnackBar(BuildContext context, {String msg = ''}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
        ));
      }
    });
  }
}
