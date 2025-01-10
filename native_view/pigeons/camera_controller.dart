import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/camera_controller.dart',
    kotlinOut:
        'android/src/main/kotlin/com/santoshniroula/native_view/CameraController.kt',
  ),
)
@HostApi()
abstract class CameraController {
  bool toggleFlash();
  bool toggleCamera();
}
