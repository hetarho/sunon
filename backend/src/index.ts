import express from 'express'
import cors from 'cors'

const app = express()
const port = 3000

app.use(cors())

app.get('/api/health', (_req, res) => {
  res.json({ message: 'hi sunon' })
})

app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`)
})
