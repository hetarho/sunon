import { useEffect, useState } from 'react'

function App() {
  const [message, setMessage] = useState('loading...')

  useEffect(() => {
    fetch('/api/health')
      .then(res => res.json())
      .then(data => setMessage(data.message))
      .catch(() => setMessage('hi sunon'))
  }, [])

  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100vh',
      fontSize: '2rem',
      fontFamily: 'system-ui, sans-serif',
    }}>
      {message}
    </div>
  )
}

export default App
