const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.status(200).send('Hello world!');
});

app.use((err, req, res, next) => {
  res.sendStatus(500);
});

app.listen(8080, ()=> {console.log(`I am listening to port 3000`)});
