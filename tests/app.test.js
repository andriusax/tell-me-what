const request = require("supertest");
const app = require("../src/app");

describe("GET /artists", () => {
  it("returns a list of artist names", async () => {
    const res = await request(app).get("/artists");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("artists");
    expect(Array.isArray(res.body.artists)).toBe(true);
    expect(res.body.artists.length).toBeGreaterThan(0);
  });

  it("includes known artists", async () => {
    const res = await request(app).get("/artists");
    expect(res.body.artists).toContain("John Frusciante");
    expect(res.body.artists).toContain("David Gilmour");
    expect(res.body.artists).toContain("Jimi Hendrix");
  });
});

describe("GET /artists/:name/gear", () => {
  it("returns gear for a known artist", async () => {
    const res = await request(app).get("/artists/John Frusciante/gear");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("artist", "John Frusciante");
    expect(Array.isArray(res.body.gear)).toBe(true);
    expect(res.body.gear.length).toBeGreaterThan(0);
  });

  it("returns gear with expected fields", async () => {
    const res = await request(app).get("/artists/David Gilmour/gear");
    expect(res.status).toBe(200);
    res.body.gear.forEach((item) => {
      expect(item).toHaveProperty("type");
      expect(item).toHaveProperty("brand");
      expect(item).toHaveProperty("model");
    });
  });

  it("performs case-insensitive artist name lookup", async () => {
    const res = await request(app).get("/artists/jimi hendrix/gear");
    expect(res.status).toBe(200);
    expect(res.body.artist).toBe("Jimi Hendrix");
  });

  it("returns 404 for an unknown artist", async () => {
    const res = await request(app).get("/artists/Unknown Artist/gear");
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty("error");
  });
});
