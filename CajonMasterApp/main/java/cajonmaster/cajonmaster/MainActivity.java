package cajonmaster.cajonmaster;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;

import at.technikum.mti.fancycoverflow.FancyCoverFlow;
import at.technikum.mti.fancycoverflow.FancyCoverFlowAdapter;

public class MainActivity extends Activity {
    private String SERVERADDRESS = "140.112.29.43";
    private int SERVERPORT = 5567;

    private ProgressBar connectProgressBar = null;
    private TextView connectText = null;
    private ImageButton controlButton = null;
    private LinearLayout playingSongInfo = null;
    private TextView playingSongName = null;
    private TextView playingSongAuthor = null;
    private View horizontalLine = null;

    private FancyCoverFlow songSelectorView = null;
    private FancyCoverFlowAdapter songSelectorAdapter = null;
    private ImageButton playButton = null;
    private boolean playing = false;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        connectProgressBar = (ProgressBar) findViewById(R.id.connectProgressBar);
        connectText = (TextView) findViewById(R.id.connectText);
        playingSongInfo = (LinearLayout) findViewById(R.id.playingSongInfo);
        playingSongName = (TextView) findViewById(R.id.playingSongName);
        playingSongAuthor = (TextView) findViewById(R.id.playingSongAuthor);
        controlButton = (ImageButton) findViewById(R.id.controlButton);
        controlButton.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!playing) {
                    playing = true;
                    controlButton.setBackgroundResource(R.drawable.pause);
                    sendMsg("continue");
                } else {
                    playing = false;
                    controlButton.setBackgroundResource(R.drawable.conti);
                    sendMsg("pause");
                }
            }
        });
        horizontalLine = findViewById(R.id.horizontalLine);
        connectWithCajon();
    }

    private void SongSelectionMode() {
        connectProgressBar.setVisibility(View.GONE);
        connectText.setVisibility(View.GONE);

        songSelectorView = (FancyCoverFlow) findViewById(R.id.songSelectorView);
        songSelectorAdapter = new FancyCoverFlowImageAdapter(this);
        songSelectorView.setAdapter(songSelectorAdapter);
        playButton = (ImageButton) findViewById(R.id.playButton);
        playButton.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                playing = true;
                int songId = (int)songSelectorView.getSelectedItemId();
                String songShortName = SongList.list.get(songId).getShortName();
                String songName = SongList.list.get(songId).getName();
                String songAuthor = SongList.list.get(songId).getAuthor();
                playingSongName.setText(songName);
                playingSongAuthor.setText(songAuthor);
                playingSongInfo.setVisibility(View.VISIBLE);
                controlButton.setVisibility(View.VISIBLE);
                controlButton.setBackgroundResource(R.drawable.pause);
                horizontalLine.setVisibility(View.VISIBLE);
                sendMsg("songName:" + songShortName);
            }
        });
        songSelectorView.setVisibility(View.VISIBLE);
        playButton.setVisibility(View.VISIBLE);
    }


    private void connectWithCajon() {
        ConnectionSyncTask connectTask = new ConnectionSyncTask();
        connectTask.execute();
    }

    private void sendMsg(String msg) {
        if (SocketUtility.socket.isConnected()) {
            if (!SocketUtility.socket.isOutputShutdown() && msg.length() > 0) {
                Log.d("INFO:", "Sending Msg : " + msg);
                SocketUtility.out.println(msg);
                SocketUtility.out.flush();
            } else {
                Toast.makeText(getApplicationContext(), "Sending message is failed", Toast.LENGTH_LONG).show();
            }
        } else {
            Log.d("INFO:", "Sending Msg : socket is disconnected!");
        }
    }

    private void openSettingsDialog() {
        LayoutInflater factory=LayoutInflater.from(MainActivity.this);
        final View dialog_layout = factory.inflate(R.layout.dialog_connect_settings,null);
        new AlertDialog.Builder(MainActivity.this)
                .setTitle("Connection Settings")
                .setView(dialog_layout)
                .setIcon(R.drawable.logo)
                .setPositiveButton("connect", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        EditText ip = (EditText) (dialog_layout.findViewById(R.id.ip));
                        EditText port = (EditText) (dialog_layout.findViewById(R.id.port));
                        SERVERADDRESS = ip.getText().toString();
                        SERVERPORT = Integer.parseInt(port.getText().toString());
                        connectWithCajon();
                    }
                })
                .show();
    }

    class ConnectionSyncTask extends AsyncTask<Integer, Integer, String> {
        private boolean connected = false;
        @Override
        protected String doInBackground(Integer... params) {
            try {
                Log.d("INFO:", "Connecting!!");
                SocketUtility.socket = new Socket(SERVERADDRESS, SERVERPORT);
                SocketUtility.socket.setSoTimeout(5000);
                if (SocketUtility.socket.isConnected()) {
                    Log.d("INFO:", "Connecting success.");
                    SocketUtility.in = new BufferedReader(new InputStreamReader(SocketUtility.socket.getInputStream()));
                    SocketUtility.out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(SocketUtility.socket.getOutputStream(),"UTF-8")), true);
                    connected = true;
                } else {
                    Log.d("INFO:", "Connecting fail.");
                }
            } catch (Exception e) {
                Log.d("Exception:", e.toString());
            }
            return null;
        }

        protected void onPostExecute(String result) {
            if (connected) {
                SongSelectionMode();
            } else {
                openSettingsDialog();
            }

        }

        protected void onPreExecute() {
        }

    }

    class FancyCoverFlowImageAdapter extends FancyCoverFlowAdapter {
        //[TODO] Modify image res ID to image bitmap
        private ArrayList<Bitmap> images = new ArrayList<Bitmap>();

        public FancyCoverFlowImageAdapter(Context context) {
            for (int i=0 ; i<SongList.list.size() ; i++) {
                images.add(BitmapFactory.decodeResource(context.getResources(), SongList.list.get(i).getImageResource()));
            }
        }

        @Override
        public int getCount() {
            return images.size();
        }

        public void addItem(Bitmap newBitmap) {
            images.add(newBitmap);
            notifyDataSetChanged();
        }

        public void replaceItem(Bitmap srcBitmap, Bitmap targetBitmap) {
            images.set(images.indexOf(srcBitmap), targetBitmap);
            notifyDataSetChanged();
        }

        public int getItemIndex(Bitmap targetBitmap) {
            return images.indexOf(targetBitmap);
        }

        public Bitmap getItem(int i) {
            return images.get(i);
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @Override
        public View getCoverFlowItem(int i, View reuseableView, ViewGroup viewGroup) {
            ImageView imageView = null;

            if (reuseableView != null) {
                imageView = (ImageView) reuseableView;
            } else {
                imageView = new ImageView(viewGroup.getContext());
                imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                imageView.setLayoutParams(new FancyCoverFlow.LayoutParams(300, 400));
            }

            imageView.setImageBitmap(this.getItem(i));
            return imageView;
        }
    }
}
