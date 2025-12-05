const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8080';

app.use(express.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/get_object/:id', async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/get_object/${req.params.id}`);
    res.json(response.data);
  } catch (error) {
    if (error.response) {
      res.status(error.response.status).json({ error: error.response.data });
    } else {
      res.status(500).json({ error: 'Backend service unavailable' });
    }
  }
});

app.post('/put_object', async (req, res) => {
  try {
    const response = await axios.post(`${BACKEND_URL}/put_object`, req.body);
    res.status(response.status).json(response.data);
  } catch (error) {
    if (error.response) {
      res.status(error.response.status).json({ error: error.response.data });
    } else {
      res.status(500).json({ error: 'Backend service unavailable' });
    }
  }
});

app.listen(PORT, () => {
  console.log(`Frontend server running on port ${PORT}`);
});
