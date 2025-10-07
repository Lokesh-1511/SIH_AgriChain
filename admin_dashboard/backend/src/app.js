const express = require('express');
const helmet = require('helmet');
const cors = require('cors');

const routes = require('./routes');
const notFound = require('./middleware/notFound');
const errorHandler = require('./middleware/errorHandler');
const rateLimiter = require('./middleware/rateLimiter');
const requestContext = require('./middleware/requestContext');
const requestLogger = require('./middleware/requestLogger');

const app = express();

app.use(helmet());
app.use(cors());
app.use(requestContext);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/api', rateLimiter);
app.use(requestLogger);

app.get('/', (req, res) => {
  res.json({
    message: 'AgriChain Admin Dashboard Backend',
    documentation: '/health'
  });
});

app.use('/api', routes);
app.use(notFound);
app.use(errorHandler);

module.exports = app;
