const app = require("./src/app");

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`tell-me-what API running on port ${PORT}`);
  console.log(`  GET /artists             - list all artists`);
  console.log(`  GET /artists/:name/gear  - get gear for a specific artist`);
});
