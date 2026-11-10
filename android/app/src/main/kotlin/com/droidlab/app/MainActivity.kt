package com.droidlab.app

import com.droidlab.app.bridge.DroidLabHostApi
import com.droidlab.app.bridge.DroidLabHostApiImpl
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
