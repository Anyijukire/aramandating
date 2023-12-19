package com.aramanservices.lite

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.google.android.gms.ads.MobileAds

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        MobileAds.initialize(this) {}
    }
}

