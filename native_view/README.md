# Flutter And Native View
Flutter provides way to present the native side view, android and ios. In case of plugin package we can follow this.

## 1. Generate package
First of all genrate the plugin using flutter plugin template.
```bash
flutter create --template=plugin --org=com.santoshniroula --platforms=android,ios native_view
```


> Clear all the version code information generated when creating plugin. Delete the file inside the lib folder, remove integration test and test folder.

## 2. Pigoen for code generation
> If you only need to bind the native view you can skip this section. 

For addition control over the native view we might need multiple functions to communicate with flutter and host side. Flutter provides `MethodChannel` to comminicate to and from the native side and flutter. Additionally `pigeon` packge provides code generation solution, which generates code for native, and flutter side. Let's add the `pigeon` dependecy into the project.
```bash
flutter pub add pigoen
```
It requires to add global package dependency into the developing environment.
We need to define contract in dart side and run the code genration. Contract with two function will look like
```dart
@ConfigurePigeon(
    options: PigeonOptions()
)
@HostApi()
abstrct class CameraController(){
    bool toogleFlash();
    void toggleCamera();
}
```

During code generation pigeon will look after the `ConfigureOption`, define the path where dart side, android side, and ios side code should generate. After defining the contract run the pigeon code genration command
```bash
dart run pigeon --input <conntract_file_path>
```


## 3. Android side configration
On directly opening the android folder in android studio, studio is unable to provide code action and other ide feature. To properly work with it we need to run config build on example folder
```bash
cd example
flutter build apk --config-only
```
Now open the `build.gradle` file located at `example/android/` directory. After syncing you are good to go.

### 4. Android view implementation
Open the `NativeViewPlugin.kt` file from `native_view` folder, then remove the `MethodCallHandler` class from inherating and methodCallHandler override function. To display the android view we need to register the viewfactory.
```kotlin
flutterPluginBinding.platformViewRegistry.registerViewFactory("<view-id>", CameraPreviewFactory())
```
Where `<view-id>` is the unique view id register in flutter side, must be unique, and `CameraPreviewFactory` is `PlatformViewFactory` which provides the `PlatformView` through `create` function.

```kotlin
internal class CameraPreviewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(
        context: Context?,
        viewId: Int,
        args: Any?
    ): PlatformView {
        TODO("Not yet implemented")
    }
}
```

`CameraPreviewFactory` is internal to the library. From `create` function we need to return the `PlatformView` which provide android side view. For simple view we can create text view and use it. 
```kotlin
class CameraPreview(
    private val context: Context,
): PlatformView{
    override fun getView(): View? {
        textView = TextView(context)
        textView.text = "This is native text"
    }

    override fun dispose(){}
}
```

`PlatformView` provides two function for override, `getView` is for returing the native view that we are going to display, in this case `TextView`, and `dispose` function.

### 5. Flutter side implementation
In flutter ther is `AndroidView` widget  to bind with native view.
```dart
AndroidView(viewType:'<view-id>')
```

![image view](./screenshots/text%20view.png)

> If you are interested how camera preview is implemented follow this article, else you are done with this.

### 5. Implementation of Camera preview in Android 
CameraX in high level api build around the Camera2 in android. Add following dependencies in `build.gradle` file of `native_view` package.
```gradle
dependencies {
    // CameraX dependencies
    implementation("androidx.camera:camera-core:1.4.1")
    implementation("androidx.camera:camera-camera2:1.4.1")
    implementation("androidx.camera:camera-view:1.4.1")

    // --other dependencies
}
```

Also need to add the camera permission in `AndroidManifest.xml` file
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:required="false" android:name="android.hardware.camera" />
```
> __Background__
> 
> Camera preview is attached to the exsting view (activity), which haves it's own lifecycle. Thus we nee to pass the activity and context to the `CameraPreview` class, which provides `LifecycleOwner`, for start, paus and stop camera based on the lifecycle of the provided activity. 

To get the activity in `CameraPreview` implement the `ActivityAware` interface provided by flutter engine in `NativeViewPlugin`. Currently we are interested in `onAttactedToActivity` function override.
```kotlin
private lateinit var flutterBinding: FlutterPlugin.FlutterPluginBinding
private lateinit var activityBinding: ActivityPluginBinding

override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterBinding = flutterPluginBinding
}

override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    flutterBinding.platformViewRegistry.registerViewFactory(
        "<view-id>",
        CameraPreviewFactory(activityBinding.activity)
    )
}
```
In above code we extrat two variable `flutterBinding` and `acrtivityBinding` and view is attached from `onAttactedToActivity` by passing the activity to view factory.

To display camer preview it requires preview holder and camera controller. For simplicity to handle the camera state, start, stop and pause use `LifecycleCameraController`, handles camera state which is aware of lifecycle owner activity. And CameraX provides the `PreviewView`, accepts controller, for preview use case.

```kotlin
var cameraController: LifecycleCameraController = LifecycleCameraController(context)

override fun getView(): View? {
    cameraController.bindToLifecycle(activity as LifecycleOwner)
    return PreviewView(context).apply{controller = cameraController}
}
```
First of all we initialize the camera controller with provided context and then it is bind to the lifecycle owner. Finally, `PreviewView` is used to show preview by passing the cameraContoller to controll the preview.

![camera preview](./screenshots/intial%20camera%20preview.png)

## 6. Implementation CameraController
In the start of the project we created the contract in dart side with two function and generate code usign pigon, kotlin side generated code in `CameraController.kt` file. Let's implemnet those function.  