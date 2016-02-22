package com.adriangoe.adriangoe.snapbox;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.EditText;

import com.parse.ParseException;
import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.util.Arrays;

public class AddSuggestionActivity extends AppCompatActivity {
    public double[] coordinates;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_suggestion);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            coordinates = extras.getDoubleArray("LOCATION");
        }

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ParseObject sugg = new ParseObject("Suggestions");
                EditText mytext = (EditText) findViewById(R.id.editText2);
                String text = mytext.getText().toString();
                if (text.length() > 0) {
                    sugg.put("text", text);
                    sugg.put("usersThatSnapped", Arrays.asList(new String[0]));
                    ParseGeoPoint location = new ParseGeoPoint(coordinates[0], coordinates[1]);
                    sugg.put("location", location);
                    sugg.put("flag", Arrays.asList(new String[0]));
                    sugg.put("user", ParseUser.getCurrentUser().getObjectId());
                    sugg.saveInBackground(new SaveCallback() {

                        public void done(ParseException e) {
                            if (e == null) {
                                finish();
                            } else {
                            }
                        }
                    });
                } else {
                    finish();
                }
            }
        });
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

    }



}
