import 'dart:async';
import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tensorflow_models/tensorflow_models.dart' as tf;

class FacesDetectorBuilder extends StatefulWidget {
  const FacesDetectorBuilder({
    Key? key,
    required this.cameraController,
    required this.builder,
  }) : super(key: key);

  final CameraController cameraController;

  final Widget Function(BuildContext context, tf.Faces faces) builder;

  @override
  State<FacesDetectorBuilder> createState() => _FacesDetectorBuilderState();
}

class _FacesDetectorBuilderState extends State<FacesDetectorBuilder> {
  final _streamController = StreamController<tf.Faces>();
  late final tf.FaceLandmarksDetector _faceLandmarksDetector;
  late Size _size;

  static const _estimationConfig = tf.EstimationConfig(
    flipHorizontal: true,
    staticImageMode: false,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _faceLandmarksDetector = await tf.TensorFlowFaceLandmarks.load();
    await widget.cameraController.startImageStream((image) {
      final imageData = tf.ImageData(
        bytes: image.planes.first.bytes,
        width: image.width,
        height: image.height,
      );
      _estimateFaces(imageData);
    });
  }

  Future<bool> _estimateFaces(tf.ImageData imageData) async {
    final faces = (await _faceLandmarksDetector.estimateFaces(
      imageData,
      estimationConfig: _estimationConfig,
    ))
        .normalize(
      fromMax: Size(imageData.width.toDouble(), imageData.height.toDouble()),
      toMax: _size,
    );

    if (!_streamController.isClosed) _streamController.add(faces);
    return !_streamController.isClosed;
  }

  @override
  void dispose() {
    _faceLandmarksDetector.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.cameraController.value.aspectRatio,
      child: LayoutBuilder(builder: (context, constraints) {
        _size = constraints.biggest;
        return StreamBuilder<tf.Faces>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final data = snapshot.data;
            if (data != null) {
              return widget.builder(context, data);
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }
}

extension on tf.Faces {
  tf.Faces normalize({
    required Size fromMax,
    required Size toMax,
  }) =>
      map((face) => face.normalize(fromMax: fromMax, toMax: toMax)).toList();
}

extension on tf.Face {
  tf.Face normalize({
    required Size fromMax,
    required Size toMax,
  }) {
    final keypoints = this
        .keypoints
        .map(
          (keypoint) => keypoint.copyWith(
            x: keypoint.x.normalize(fromMax: fromMax.width, toMax: toMax.width),
            y: keypoint.y
                .normalize(fromMax: fromMax.height, toMax: toMax.height),
          ),
        )
        .toList();
    final boundingBox = this.boundingBox.copyWith(
          height: this
              .boundingBox
              .height
              .normalize(fromMax: fromMax.height, toMax: toMax.height),
          width: this
              .boundingBox
              .width
              .normalize(fromMax: fromMax.width, toMax: toMax.width),
          xMax: this.boundingBox.xMax.normalize(
                fromMax: fromMax.width,
                toMax: toMax.width,
              ),
          xMin: this.boundingBox.xMin.normalize(
                fromMax: fromMax.width,
                toMax: toMax.width,
              ),
          yMax: this.boundingBox.yMax.normalize(
                fromMax: fromMax.height,
                toMax: toMax.height,
              ),
          yMin: this.boundingBox.yMin.normalize(
                fromMax: fromMax.height,
                toMax: toMax.height,
              ),
        );
    return copyWith(
      keypoints: UnmodifiableListView(keypoints),
      boundingBox: boundingBox,
    );
  }
}

extension on num {
  double normalize({
    num fromMin = 0,
    required num fromMax,
    num toMin = 0,
    required num toMax,
  }) {
    assert(fromMin < fromMax, 'fromMin must be less than fromMax');
    assert(toMin < toMax, 'toMin must be less than toMax');

    return (toMax - toMin) * ((this - fromMin) / (fromMax - fromMin)) + toMin;
  }
}