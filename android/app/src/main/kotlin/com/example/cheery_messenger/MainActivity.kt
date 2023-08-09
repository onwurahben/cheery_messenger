package com.example.cheery_messenger
import android.os.Bundle
import androidx.multidex.MultiDexApplication


import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MultiDexApplication()
    }
}
