import { FormEvent, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import { useAuth } from "../../context/AuthContext";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [correo, setCorreo] = useState("diego.lopez@gmail.com");
  const [password, setPassword] = useState("Ciclito2026#");
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    try {
      const user = await login(correo, password);
      if (user.rol === "ADMINISTRADOR") navigate("/admin/reportes");
      else if (user.rol === "EMPLEADO") navigate("/operacion");
      else navigate("/cliente/reservas");
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section className="narrow">
      <h1>Iniciar sesión</h1>
      <p className="muted">Cuentas semilla: password Ciclito2026# (tras ejecutar el script de hashes).</p>
      <AlertBanner message={error} />
      <form className="card form" onSubmit={onSubmit}>
        <label>
          Correo
          <input value={correo} onChange={(e) => setCorreo(e.target.value)} type="email" required />
        </label>
        <label>
          Contraseña
          <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" required />
        </label>
        <button className="btn" type="submit">
          Entrar
        </button>
        <p>
          ¿Aún no tienes cuenta? <Link to="/registro">Regístrate</Link>
        </p>
      </form>
    </section>
  );
}
