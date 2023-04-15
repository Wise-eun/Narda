package com.example.speelow;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import android.net.Uri;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import com.skt.Tmap.TMapTapi;
import com.skt.Tmap.TMapView;
import android.widget.RelativeLayout;
public class MainActivity extends FlutterActivity {
    private static final String mChannel = "mobile/parameters";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), mChannel);
        channel.setMethodCallHandler(handler);
    }

    private MethodChannel.MethodCallHandler handler = (methodCall, result) -> {
        TMapTapi tMapTapi = new TMapTapi(this);
        TMapView tmapview = new TMapView(this);
        RelativeLayout relativeLayout = new RelativeLayout(this);
        if(methodCall.method.equals("initTmapAPI")) {
             tMapTapi = new TMapTapi(this);
            tMapTapi.setSKTMapAuthentication("yIvsQzTPnWa2bnrbh6HeN9iq4CbOhadO3M3g46RT");
            result.success("initTmapAPI");
        }
        else if(methodCall.method.equals("isTmapApplicationInstalled")) {
            if(tMapTapi.isTmapApplicationInstalled()) {
                result.success("");
            } else {
                  Uri uri = Uri.parse(tMapTapi.getTMapDownUrl().get(0));
               // Log.e("cylog", "tMapTapi.getTMapDownUrl () : " + tMapTapi.getTMapDownUrl());
                result.success(uri.toString());
            }
        }
        else if(methodCall.method.equals("tmapViewAPI"))
        {

            tmapview.setSKTMapApiKey("yIvsQzTPnWa2bnrbh6HeN9iq4CbOhadO3M3g46RT");
            tmapview.setLanguage(TMapView.LANGUAGE_KOREAN);
            tmapview.setIconVisibility(true);
            tmapview.setZoomLevel(10);
            tmapview.setMapType(TMapView.MAPTYPE_STANDARD);
            tmapview.setCompassMode(true);
            tmapview.setTrackingMode(true);

          //  relativeLayout.addView(tmapview);
          //  result.success(relativeLayout);
           // result.success("얍");
        }

    };
}