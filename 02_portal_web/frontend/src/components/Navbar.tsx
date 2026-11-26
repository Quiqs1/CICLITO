import { Link, NavLink } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Navbar() {
  const { user, logout } = useAuth();
  const nombre =
    user?.cliente_nombres ||
    user?.empleado_nombres ||
    user?.correo.split("@")[0] ||
    "sesión";

  return (
    <header className="nav">
      <Link to="/" className="brand">
        CICLITO
        <span>Cantera y Pedal</span>
      </Link>
      <nav>
        <NavLink to="/catalogo">Flota</NavLink>
        {user?.rol === "CLIENTE" && (
          <>
            <NavLink to="/cliente/reservar">Reservar</NavLink>
            <NavLink to="/cliente/reservas">Mis reservas</NavLink>
          </>
        )}
        {(user?.rol === "EMPLEADO" || user?.rol === "ADMINISTRADOR") && (
          <>
            <NavLink to="/operacion">Mostrador</NavLink>
            <NavLink to="/operacion/taller">Taller</NavLink>
          </>
        )}
        {user?.rol === "ADMINISTRADOR" && (
          <>
            <NavLink to="/admin/flota">Inventario</NavLink>
            <NavLink to="/admin/tarifas">Tarifas</NavLink>
            <NavLink to="/admin/reportes">Reportes</NavLink>
          </>
        )}
      </nav>
      <div className="nav-actions">
        {user ? (
          <>
            <span className="muted">{nombre}</span>
            <button type="button" className="ghost" onClick={logout}>
              Salir
            </button>
          </>
        ) : (
          <>
            <Link to="/login">Entrar</Link>
            <Link to="/registro" className="btn">
              Crear cuenta
            </Link>
          </>
        )}
      </div>
    </header>
  );
}
