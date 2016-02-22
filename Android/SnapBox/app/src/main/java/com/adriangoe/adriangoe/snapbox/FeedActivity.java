package com.adriangoe.adriangoe.snapbox;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ListView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks;
import com.google.android.gms.common.api.GoogleApiClient.OnConnectionFailedListener;
import com.google.android.gms.location.LocationServices;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.List;


public class FeedActivity extends AppCompatActivity implements ConnectionCallbacks, OnConnectionFailedListener{
    GridView listView ;

    public ArrayList<String> suggestionList = new ArrayList<String>();
    public ArrayList<JSONArray> suggestionSnapsList;

    double[] coordinates = new double[]{0.0,0.0};
    ParseGeoPoint loc = new ParseGeoPoint();
    Double parseSetMiles = 0.6;
    String parseMessage = "@strings/parseMessage";
    boolean connected = false;
    public String user;
    CustomListAdapter adapter;


    private GoogleApiClient mGoogleApiClient;
    SwipeRefreshLayout mSwipeRefreshLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        user = ParseUser.getCurrentUser().getObjectId().toString();
        setValues();

        setContentView(R.layout.activity_feed);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(view.getContext(),AddSuggestionActivity.class);
                intent.putExtra("LOCATION",coordinates);
                startActivity(intent);
            }
        });

        // Create an instance of GoogleAPIClient.
        if (mGoogleApiClient == null) {
            mGoogleApiClient = new GoogleApiClient.Builder(this)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .build();
        }

        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.activity_main_swipe_refresh_layout);
        mSwipeRefreshLayout.setColorSchemeResources(R.color.orange, R.color.green, R.color.blue);
        mSwipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadFeed();
            }
        });


    }

    protected void onStart() {
        mGoogleApiClient.connect();

        if (!connected) {
            //suggestionList.add("Please make sure you have internet and Location Services activated");
            Snackbar snackbar = Snackbar
                    .make(findViewById(R.id.snackbarPosition), "There is a Problem with your Network Connection :(", Snackbar.LENGTH_LONG);
            snackbar.show();
        }
        super.onStart();
    }

    protected void onResume(){
        super.onResume();
    }

    protected void onStop() {
        mGoogleApiClient.disconnect();
        super.onStop();
    }

    public void loadListView() {
        adapter=new CustomListAdapter(this, suggestionList, suggestionSnapsList);
        ListView listView=(ListView)findViewById(R.id.listView);
        listView.setAdapter(adapter);
        listView.setClickable(true);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> arg0, View v, final int position, long id) {
                ParseQuery<ParseObject> snapped = ParseQuery.getQuery("Suggestions");
                snapped.whereEqualTo("text", suggestionList.get(position));
                snapped.findInBackground(new FindCallback<ParseObject>() {
                    @Override
                    public void done(List<ParseObject> objects, ParseException e) {
                        if (e == null) {
                            ParseObject object = objects.get(0);
                            if (suggestionSnapsList.get(position).toString().contains(user)) {
                                final ArrayList<String> removeArr = new ArrayList<>();
                                removeArr.add(user);
                                object.removeAll("usersThatSnapped", removeArr);
                            } else {
                                object.addUnique("usersThatSnapped", user);
                                Snackbar snackbar = Snackbar
                                        .make(findViewById(R.id.snackbarPosition), "Keep Snapping :)", Snackbar.LENGTH_SHORT);
                                snackbar.show();
                            }
                            object.saveInBackground();
                            getSuggestions();
                        } else {
                        }
                    }
                });
            }

        });
        listView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> arg0, View arg1,
                                           final int position, long id) {
                AlertDialog.Builder builder1 = new AlertDialog.Builder(adapter.getContext());
                builder1.setMessage("Flag this Suggestions? (Suggestions with 3 Flags will be removed");
                builder1.setCancelable(true);
                builder1.setPositiveButton("Okay",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                ParseQuery<ParseObject> flag = ParseQuery.getQuery("Suggestions");
                                flag.whereEqualTo("text", suggestionList.get(position));
                                flag.findInBackground(new FindCallback<ParseObject>() {
                                    @Override
                                    public void done(List<ParseObject> objects, ParseException e) {
                                        if (e == null) {
                                            ParseObject object = objects.get(0);
                                            if (object.getJSONArray("flag").toString().contains(user)) {
                                                final ArrayList<String> removeArr = new ArrayList<>();
                                                removeArr.add(user);
                                                object.removeAll("flag", removeArr);
                                                Snackbar snackbar = Snackbar
                                                        .make(findViewById(R.id.snackbarPosition), "You unflagged this Post", Snackbar.LENGTH_LONG);
                                                snackbar.show();
                                            } else {
                                                object.addUnique("flag", user);
                                                Snackbar snackbar = Snackbar
                                                        .make(findViewById(R.id.snackbarPosition), "You flagged this Post", Snackbar.LENGTH_LONG);
                                                snackbar.show();
                                            }
                                            int len = object.getJSONArray("flag").length();
                                            if (len > 2) {
                                                object.deleteInBackground();
                                                Snackbar snackbar = Snackbar
                                                        .make(findViewById(R.id.snackbarPosition), "We deleted the Post", Snackbar.LENGTH_LONG);
                                                snackbar.show();
                                            } else {
                                                object.saveInBackground();
                                            }
                                            getSuggestions();
                                        } else {

                                        }
                                    }
                                });
                                dialog.cancel();
                            }
                        });
                builder1.setNegativeButton("Cancel",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
                AlertDialog alert11 = builder1.create();
                alert11.show();

                return true;
            }
        });
    }

    @Override
    public void onConnected(Bundle connectionHint) {
        // Connected to Google Play services!
        // The good stuff goes here.
        Location mLastLocation = LocationServices.FusedLocationApi.getLastLocation(
                mGoogleApiClient);
        if (mLastLocation != null) {
            coordinates[0] = (double)(mLastLocation.getLatitude());
            coordinates[1] = (double)(mLastLocation.getLongitude());
            Snackbar snackbar = Snackbar
                    .make(findViewById(R.id.snackbarPosition), "Found your Location, let's go! :)", Snackbar.LENGTH_SHORT);
            snackbar.show();
        }
        else {
            Snackbar snackbar = Snackbar
                    .make(findViewById(R.id.snackbarPosition), "We couldn/'t receive your Location :(", Snackbar.LENGTH_LONG);
            snackbar.show();
        }
        getSuggestions();
    }

    @Override
    public void onConnectionSuspended(int cause) {
        // The connection has been interrupted.
        // Disable any UI components that depend on Google APIs
        // until onConnected() is called.
    }

    @Override
    public void onConnectionFailed(ConnectionResult result) {
        // This callback is important for handling errors that
        // may occur while attempting to connect with Google.
        //
        // More about this in the 'Handle Connection Failures' section.
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
            AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
            builder1.setMessage(parseMessage);
            builder1.setCancelable(true);
            builder1.setPositiveButton("Okay",
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.cancel();
                        }
                    });

            AlertDialog alert11 = builder1.create();
            alert11.show();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void loadFeed() {
        mSwipeRefreshLayout.setRefreshing(true);
        setValues();
        CustomListAdapter adapter=new CustomListAdapter(this, suggestionList, suggestionSnapsList);
        ListView listView=(ListView)findViewById(R.id.listView);
        listView.setAdapter(adapter);
        listView.setClickable(true);
        mSwipeRefreshLayout.setRefreshing(false);
    }

    public void setValues() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Miles");
        query.getInBackground("H0Zw3iHDbD", new GetCallback<ParseObject>() {
            public void done(ParseObject object, ParseException e) {
                if (e == null) {
                    parseSetMiles = object.getDouble("miles");
                    parseMessage = object.getString("message");
                } else {

                }
            }
        });
    }

    public void getSuggestions() {
        ParseQuery query2 = new ParseQuery("Suggestions");
        loc = new ParseGeoPoint(coordinates[0], coordinates[1]);
        query2.whereWithinMiles("location", loc, parseSetMiles);
        query2.setLimit(20);
        query2.orderByDescending("createdAt");
        query2.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    suggestionList = new ArrayList<String>();
                    suggestionSnapsList = new ArrayList<JSONArray>();
                    for (ParseObject Suggestion : objects) {
                        String suggString = Suggestion.getString("text");
                        if (!suggestionList.contains(suggString)){
                            suggestionList.add(suggString);
                            suggestionSnapsList.add(Suggestion.getJSONArray("usersThatSnapped"));
                        }
                    }
                } else {
                }
                loadListView();
            }

        });
    }

    public static <T> boolean contains(final T[] array, final T v) {
        for (final T e : array)
            if (e == v || v != null && v.equals(e))
                return true;

        return false;
    }

}


