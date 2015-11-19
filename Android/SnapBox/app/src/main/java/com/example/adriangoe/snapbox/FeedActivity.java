package com.example.adriangoe.snapbox;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.GridView;
import android.widget.ListView;

public class FeedActivity extends AppCompatActivity {
    GridView listView ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_feed);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(view.getContext(), AddSuggestionActivity.class));
            }
        });

        // Get ListView object from xml
        //final GridView gridView = (GridView) findViewById(R.id.gridView);

        // Defined Array values to show in ListView
        String[] values = new String[] {
                "The wifi sucks",
                "I want to take class from here",
                "I always take class from here",
                "I am just coming up with random phrases",
                "Same though",
                "Let's see if it scrolls",
                "Interesting"
        };

        Integer[] imgid={
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
                R.drawable.snap_unactive,
        };

        CustomListAdapter adapter=new CustomListAdapter(this, values, imgid);
        ListView listView=(ListView)findViewById(R.id.listView);
        listView.setAdapter(adapter);

        /*/ Define a new Adapter
        // First parameter - Context
        // Second parameter - Layout for the row
        // Third parameter - ID of the TextView to which the data is written
        // Forth - the Array of data

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, android.R.id.text1, values);


        // Assign adapter to ListView
        gridView.setAdapter(adapter);

        // ListView Item Click Listener
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {

                // ListView Clicked item index
                int itemPosition = position;

                // ListView Clicked item value
                String itemValue = (String) gridView.getItemAtPosition(position);

                // Show Alert
                Snackbar.make(view, "Position :" + itemPosition + "  ListItem : " + itemValue, Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();

            }

        });*/
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_feed, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_info) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}

