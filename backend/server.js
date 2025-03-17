const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
app.use(bodyParser.json());
const cors = require('cors');
app.use(cors());

const authKey = '9e423f27-6cab-4c95-9f16-5ef629f281a5:fx';

app.post('/translate', async (req, res) => {
  try {
    const { texts } = req.body;

    if (!Array.isArray(texts) || texts.length === 0) {
      return res.status(400).json({ error: 'Invalid input. "texts" must be a non-empty array.' });
    }

    const params = new URLSearchParams();
    params.append('auth_key', authKey);
    params.append('target_lang', 'ES');
    texts.forEach((text) => params.append('text', text));

    const response = await axios.post(
      'https://api-free.deepl.com/v2/translate',
      params.toString(),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );

    res.json({ translations: response.data.translations.map((t) => t.text) });
  } catch (err) {
    console.error('Translation error:', err.response?.data || err.message);
    res.status(500).json({ error: 'Error translating texts.' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

