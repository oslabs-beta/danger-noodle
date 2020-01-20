const express = require('express');
const redis = require('redis');
const app = express();
const process = require('process');
const redisClient = redis.createClient({
  host: 'redis-server',
  port: 6379,
});
redisClient.set('visits', 0);

app.get('/', (req, res, next) => {
  process.exit(0);
  redisClient.get('visits', (err, visits) => {
    if (err) return next(err);
    res.status(200).send(`Number of visits is ${visits}`);
    redisClient.set('visits', parseInt(visits) + 1);
  })
});

app.use((err, req, res, next) => {
  res.sendStatus(500);
});


app.listen(3000, ()=> {console.log(`I am listening to 3000`)});
