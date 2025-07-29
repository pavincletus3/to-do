const express = require("express");
const redis = require("redis");

const app = express();
app.use(express.json());

// If DOCKER_REDIS_HOST is provided, use it. Otherwise, connect to localhost.
// Docker Compose will provide this environment variable.
const redisHost = process.env.DOCKER_REDIS_HOST || "localhost";

const redisClient = redis.createClient({
  url: `redis://${redisHost}:6379`,
});

redisClient.on("error", (err) => console.log("Redis Client Error", err));

// Connect to Redis as soon as the app starts.
(async () => {
  await redisClient.connect();
})();

// GET endpoint to retrieve all to-do items
app.get("/todos", async (req, res) => {
  try {
    const todos = await redisClient.lRange("todos", 0, -1);
    res.json(todos);
  } catch (e) {
    res.status(500).send(e.message);
  }
});

// POST endpoint to add a new to-do item
app.post("/todos", async (req, res) => {
  const { item } = req.body;
  if (!item) {
    return res.status(400).send("Item is required");
  }
  try {
    await redisClient.lPush("todos", item);
    res.status(201).send(`Added: ${item}`);
  } catch (e) {
    res.status(500).send(e.message);
  }
});

const port = 8080;
app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
