package cajonmaster.cajonmaster;

import java.util.ArrayList;

public class SongList {
    protected static ArrayList<Song> list;
    static{
        list = new ArrayList<Song>();
        SongList.list.add(new Song(R.drawable.sad, "傷心的人別聽慢歌", "sad", "五月天"));
        SongList.list.add(new Song(R.drawable.ruchen, "入陣曲", "ruchen", "五月天"));
        SongList.list.add(new Song(R.drawable.general, "將軍令", "general", "五月天"));
        SongList.list.add(new Song(R.drawable.stop, "所以我停下來", "strop", "那我懂你意思了"));
        SongList.list.add(new Song(R.drawable.chaosmyth, "C.H.A.O.S.M.Y.T.H", "chaosmyth", "ONE OK ROCK"));
    }
}

class Song {
    private int image;
    private String name;
    private String shortName;
    private String author;

    public Song(int _image, String _name, String _shortName, String _author){
        image = _image;
        name = _name;
        shortName = _shortName;
        author = _author;
    }

    public int getImageResource() { return image; }

    public String getName() { return name; }

    public String getShortName() { return shortName; }

    public String getAuthor() { return author; }
}