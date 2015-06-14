package cajonmaster.cajonmaster;

import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;


public class ConnectActivity extends Activity {
    private final String SERVERADDRESS = "140.112.29.202";
    private final int SERVERPORT = 5566;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_connect);
        connectWithCajon();
    }

    private void connectWithCajon() {
        ConnectionSyncTask connectTask = new ConnectionSyncTask();
        connectTask.execute();
    }

    private void startMainPage() {
        Intent intent = new Intent(ConnectActivity.this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    private void startSettingsPage() {
        Intent intent = new Intent(ConnectActivity.this, SettingsActivity.class);
        startActivity(intent);
    }

    class ConnectionSyncTask extends AsyncTask<Integer, Integer, String> {
        @Override
        protected String doInBackground(Integer... params) {
            try {
                SocketUtility.socket = new Socket(SERVERADDRESS, SERVERPORT);
                if (SocketUtility.socket.isConnected()) {
                    SocketUtility.in = new BufferedReader(new InputStreamReader(SocketUtility.socket.getInputStream()));
                    SocketUtility.out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(SocketUtility.socket.getOutputStream(),"UTF-8")), true);
                    startMainPage();
                } else {
                    startSettingsPage();
                }
            } catch (Exception e) {
                // TODO: exception handler
            }
            return null;
        }

        protected void onPostExecute(String result) {
        }

        protected void onPreExecute() {
        }

    }
}
