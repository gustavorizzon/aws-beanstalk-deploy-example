import express from 'express'

const app = express()

app.get('/', (req, res) => {
  return res.status(200).json({ message: 'Hello World' })
})

app.get('/health', (req, res) => {
  return res.status(200).send('Healthy')
})

const port = process.env.SERVER_PORT
app.listen(port, () => {
  console.log(`Server started on port ${port}!`)
})
