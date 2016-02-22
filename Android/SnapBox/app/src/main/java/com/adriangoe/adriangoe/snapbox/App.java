package com.adriangoe.adriangoe.snapbox;

import android.app.Application;

import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseUser;

/**
 * Created by adriangoe on 12/14/15.
 */

public class App extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        Parse.enableLocalDatastore(this);
        Parse.initialize(this);
        ParseUser.enableAutomaticUser();
        ParseUser.getCurrentUser().increment("RunCount");
        try {
            ParseUser.getCurrentUser().save();
            } catch (ParseException e) {
            //Handle exception here
            e.printStackTrace();
            ParseUser.getCurrentUser().saveInBackground();
        }
    }
}