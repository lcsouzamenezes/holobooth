import 'dart:async';
import 'dart:typed_data';

import 'package:avatar_detector_repository/avatar_detector_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_photobooth/avatar_detector/avatar_detector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../helpers/helpers.dart';

class _MockAvatarDetectorBloc
    extends MockBloc<AvatarDetectorEvent, AvatarDetectorState>
    implements AvatarDetectorBloc {}

class _MockCameraController extends Mock implements CameraController {
  _MockCameraController(this.cameraImage);
  final CameraImage cameraImage;
  @override
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {
    onAvailable(cameraImage);
  }
}

class _FakePlane extends Fake implements Plane {
  @override
  Uint8List get bytes => Uint8List.fromList(List.empty());
}

class _FakeCameraImage extends Fake implements CameraImage {
  @override
  List<Plane> get planes => [_FakePlane()];

  @override
  int get width => 0;

  @override
  int get height => 0;
}

class _FakeCameraImageData extends Fake implements CameraImageData {}

class _MockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {}

class _FakeAvatar extends Fake implements Avatar {}

void main() {
  late AvatarDetectorBloc avatarDetectorBloc;
  late CameraController cameraController;
  late CameraImage cameraImage;

  setUp(() {
    cameraImage = _FakeCameraImage();
    avatarDetectorBloc = _MockAvatarDetectorBloc();
    when(() => avatarDetectorBloc.state).thenReturn(AvatarDetectorInitial());
    cameraController = _MockCameraController(cameraImage);
  });

  group('AvatarDetector', () {
    testWidgets(
      'renders AvatarDetectorContent',
      (WidgetTester tester) async {
        await tester.pumpApp(
          AvatarDetector(
            cameraController: cameraController,
            loadingChild: SizedBox(),
            child: SizedBox(),
          ),
        );
        expect(find.byType(AvatarDetectorContent), findsOneWidget);
      },
    );
  });

  group('AvatarDetectorContent', () {
    testWidgets(
      'adds AvatarDetectorEstimateRequested when AvatarDetectorLoaded',
      (WidgetTester tester) async {
        final cameraPlatform = _MockCameraPlatform();
        CameraPlatform.instance = cameraPlatform;
        final frameStreamController = StreamController<CameraImageData>();
        final frameStream = frameStreamController.stream;
        when(() => cameraPlatform.onStreamedFrameAvailable(any()))
            .thenAnswer((_) => frameStream);

        whenListen(
          avatarDetectorBloc,
          Stream.value(AvatarDetectorLoaded()),
        );
        await tester.pumpSubject(
          AvatarDetectorContent(
            cameraController: cameraController,
            loadingChild: SizedBox(),
            child: SizedBox(),
          ),
          avatarDetectorBloc,
        );
        frameStreamController.add(_FakeCameraImageData());
        verify(
          () => avatarDetectorBloc
              .add(AvatarDetectorEstimateRequested(cameraImage)),
        ).called(1);
      },
    );

    testWidgets(
      'renders child when AvatarDetectorDetected',
      (WidgetTester tester) async {
        when(() => avatarDetectorBloc.state)
            .thenReturn(AvatarDetectorDetected(_FakeAvatar()));
        final childKey = Key('childKey');
        await tester.pumpSubject(
          AvatarDetectorContent(
            cameraController: cameraController,
            loadingChild: SizedBox(),
            child: SizedBox(key: childKey),
          ),
          avatarDetectorBloc,
        );
        expect(find.byKey(childKey), findsOneWidget);
      },
    );

    testWidgets(
      'renders child state is not AvatarDetectorDetected',
      (WidgetTester tester) async {
        when(() => avatarDetectorBloc.state)
            .thenReturn(AvatarDetectorEstimating());
        final loadingChildKey = Key('loadingChildKey');
        await tester.pumpSubject(
          AvatarDetectorContent(
            cameraController: cameraController,
            loadingChild: SizedBox(key: loadingChildKey),
            child: SizedBox(),
          ),
          avatarDetectorBloc,
        );
        expect(find.byKey(loadingChildKey), findsOneWidget);
      },
    );
  });
}

extension on WidgetTester {
  Future<void> pumpSubject(
    AvatarDetectorContent subject,
    AvatarDetectorBloc avatarDetectorBloc,
  ) =>
      pumpApp(
        BlocProvider.value(
          value: avatarDetectorBloc,
          child: subject,
        ),
      );
}