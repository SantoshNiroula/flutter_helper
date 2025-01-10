package com.santoshniroula.native_view

import CameraController
import android.app.Activity
import android.content.Context
import android.view.View
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.view.LifecycleCameraController
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


internal class CameraPreviewFactory(
    private val activity: Activity
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(
        context: Context?, viewId: Int, args: Any?
    ): PlatformView {
        return CameraPreview(context!!, activity)
    }
}


class CameraPreview(
    private val context: Context, private val activity: Activity
) : PlatformView, CameraController {

    var cameraController: LifecycleCameraController = LifecycleCameraController(context)

    override fun getView(): View? {
//       val textView = TextView(context)
//        textView.text = "This is native text"
//        return textView

        cameraController.bindToLifecycle(activity as LifecycleOwner)

        return PreviewView(context).apply {
            controller = cameraController
        }
    }

    override fun dispose() {
        cameraController.unbind()
    }

    override fun toggleFlash(): Boolean {
        cameraController.enableTorch(!isFlashOn())
        return isFlashOn()
    }

    override fun toggleCamera(): Boolean {
        if (cameraController.cameraSelector == CameraSelector.DEFAULT_FRONT_CAMERA) {
            cameraController.cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
        } else {
            cameraController.cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA
        }

        return true
    }

    private fun isFlashOn(): Boolean {
        val mode = cameraController.imageCaptureFlashMode
        return mode == ImageCapture.FLASH_MODE_ON
    }
}