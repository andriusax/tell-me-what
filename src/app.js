const express = require("express");
const { artists } = require("./data");

const app = express();
app.use(express.json());

app.get("/artists", (req, res) => {
  const names = artists.map((a) => a.name);
  res.json({ artists: names });
});

app.get("/artists/:name/gear", (req, res) => {
  const artistName = req.params.name;
  const artist = artists.find(
    (a) => a.name.toLowerCase() === artistName.toLowerCase()
  );

  if (!artist) {
    return res.status(404).json({ error: `Artist '${artistName}' not found` });
  }

  res.json({ artist: artist.name, gear: artist.gear });
});

module.exports = app;
