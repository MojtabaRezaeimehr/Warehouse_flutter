package com.example.warehouse_amf;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.warehouse_amf.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Set;

import javax.security.auth.login.LoginException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {


    String lastResult = "";
    boolean run = true;

    public static final String STREAM = "android-barcode-scan-event";
    public static final String SCAN_CHANNEL = "android-barcode-scan-channel";
    private EventChannel.EventSink attachEvent;
    final String TAG_NAME = "From_Native";
    private android.os.Handler handler;

    String action = "com.android.serial.BARCODEPORT_RECEIVEDDATA_ACTION";
    String data = "DATA";

    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            if (run) {
                run = false;
                IntentFilter intentFilter = new IntentFilter();
                
                intentFilter.addAction(action);

                registerReceiver(new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        if (action.equals(intent.getAction())) {
                            String extra = intent.getStringExtra(data);
                            if (attachEvent == null || extra == null) {
                                return;
                            }
                                try{
                                // if last result equals to current scanned barcode
                                // check if enough time has passed from last scanning time
                                // if so ,return the current scanned barcode and reset the timer
                                CountUpTimer timer = CountUpTimer.getInstance();
                                if (lastResult.equals(extra)) {
                                    double time = timer.getCurrentTimeInMilliSec();
                                    if (time > 1500) {
                                        timer.resetTimer();
                                        lastResult = extra;
                                        attachEvent.success(lastResult);
                                        Log.i(TAG_NAME, "attachEvent.success");
                                    } else {
                                        Log.i(TAG_NAME, "not enough time has passed");
                                    }
                                } else {
                                    timer.resetTimer();
                                    lastResult =extra;
                                    attachEvent.success(lastResult);
                                    Log.i(TAG_NAME, "attachEvent.success");
                                }

                                }catch (Exception e) {
                                Log.i("registerReceiver", "error in registerReceiver" + e.toString());
                                }
                            
                        }
                    }
                }, intentFilter);
            }
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new EventChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor(), STREAM).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, final EventChannel.EventSink events) {
                Log.w(TAG_NAME, "Adding listener");
                attachEvent = events;
                handler = new Handler();
                run = true;
                runnable.run();

            }

            @Override
            public void onCancel(Object args) {
                Log.w(TAG_NAME, "Cancelling listener");
                handler.removeCallbacks(runnable);
                handler = null;
                attachEvent = null;
                System.out.println("StreamHandler - onCanceled: ");
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i("destroy", "My Debug --> OnDestroy Called");
        handler.removeCallbacks(runnable);
        handler = null;
        attachEvent = null;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //update intent action and intent data key name
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SCAN_CHANNEL).setMethodCallHandler((call, result) -> {
            Map<String, Object> args = call.arguments();
            if (call.method.equals("action")) {
                action = (String) args.get("action");
                Log.i("SCAN_CHANNEL", "updated action" + action);
            }else if(call.method.equals("data_key")){
                data = (String) args.get("data_key");
                Log.i("SCAN_CHANNEL", "updated data key" + data);
            }
        });
    }

}
