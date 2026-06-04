package com.example.warehouse_amf;

import java.util.Timer;
import java.util.TimerTask;
import java.util.function.DoubleUnaryOperator;

public class CountUpTimer {
    //time in milliSecond
    private Double currentTime;
    private static CountUpTimer instance;

    CountUpTimer(){
        instance = this;
        currentTime = 0.0;

        Timer timer = new Timer();
        TimerTask timerTask = new TimerTask() {
            @Override
            public void run() {
               currentTime+=10;
            }
        };
        timer.schedule(timerTask,0,10);
    }


    public static CountUpTimer getInstance(){
        if(instance==null){
            instance = new CountUpTimer();
        }
        return instance;
    }

    public Double getCurrentTimeInMilliSec(){
        return currentTime;
    }

    public void resetTimer() {
        currentTime = 0.0;
    }
}
