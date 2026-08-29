import { useEffect, useState } from 'react';

// Nota: se usan rutas RELATIVAS ("/api/..."), no una URL absoluta.
// El Nginx del taller sirve el frontend y hace de proxy del backend en el
// MISMO origen (mismo host:puerto), así que no hace falta configurar CORS.
function App() {
  const [visits, setVisits] = useState(null);
  const [pings, setPings] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/visits')
      .then((res) => res.json())
      .then(setVisits)
      .catch((err) => setError(err.message));
  }, []);

  // Dispara varias peticiones a /api/health para que se note, en la
  // interfaz, cómo Nginx reparte el tráfico entre las réplicas del backend.
  const probeBackends = async () => {
    const results = [];
    for (let i = 0; i < 6; i++) {
      const res = await fetch('/api/health');
      const json = await res.json();
      results.push(json.servedBy);
    }
    setPings(results);
  };

  return (
    <div style={{ fontFamily: 'system-ui, sans-serif', padding: '2.5rem', maxWidth: 640 }}>
      <h1>Taller IaC · Terraform + Docker</h1>
      <p style={{ color: '#555' }}>
        React → Nginx (balanceador) → Node.js (réplicas) → MySQL, todo desplegado con Terraform.
      </p>

      <section style={{ marginTop: '2rem' }}>
        <h2>Conexión a la base de datos</h2>
        {error && <p style={{ color: 'crimson' }}>Error: {error}</p>}
        {visits ? (
          <p>
            Total de visitas registradas en MySQL: <strong>{visits.totalVisits}</strong>
            <br />
            Petición atendida por: <code>{visits.servedBy}</code>
          </p>
        ) : (
          <p>Cargando…</p>
        )}
      </section>

      <section style={{ marginTop: '2rem' }}>
        <h2>Balanceo de carga entre réplicas</h2>
        <button onClick={probeBackends}>Enviar 6 peticiones a /api/health</button>
        {pings.length > 0 && (
          <ul>
            {pings.map((host, i) => (
              <li key={i}>
                Petición {i + 1} → atendida por <code>{host}</code>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}

export default App;
