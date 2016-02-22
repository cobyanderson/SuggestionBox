package com.adriangoe.adriangoe.snapbox;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.parse.ParseUser;

import org.json.JSONArray;

import java.util.ArrayList;

public class CustomListAdapter extends ArrayAdapter<String> {

    private final Activity context;
    public ArrayList<String> itemname;
    private ArrayList<JSONArray> snaps;
    private final String user;

    public CustomListAdapter(Activity context, ArrayList<String> itemname, ArrayList<JSONArray> snaps) {
        super(context, R.layout.suggestion, itemname);
        // TODO Auto-generated constructor stub

        this.context=context;
        this.itemname=itemname;
        this.snaps=snaps;
        this.user = ParseUser.getCurrentUser().getObjectId();
    }

    public void setData(ArrayList<String> itemname, ArrayList<JSONArray> snaps){
        this.itemname=itemname;
        this.snaps=snaps;
    }

    public View getView(int position,View view,ViewGroup parent) {
        LayoutInflater inflater=context.getLayoutInflater();
        View rowView=inflater.inflate(R.layout.suggestion, null, true);

        TextView txtTitle = (TextView) rowView.findViewById(R.id.Itemname);
        TextView snapView = (TextView) rowView.findViewById(R.id.Snaps);
        ImageView img = (ImageView) rowView.findViewById(R.id.icon);


        txtTitle.setText(getItem(position));

        if (snaps.get(position).toString().contains(user)){
            img.setImageResource(R.drawable.snap_active);
        }
        else{
            img.setImageResource(R.drawable.snap_unactive);
        }

        snapView.setText(Integer.toString(snaps.get(position).length()));
        return rowView;

    };
}