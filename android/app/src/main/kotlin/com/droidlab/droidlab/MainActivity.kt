package com.droidlab.droidlab

import com.droidlab.droidlab.bridge.DroidLabHostApi
import com.droidlab.droidlab.bridge.DroidLabHostApiImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DroidLabHostApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            DroidLabHostApiImpl(applicationContext)
        )
    }
}
