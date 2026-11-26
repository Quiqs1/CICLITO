import { Navigate } from "react-router-dom";
import { useAuth, type Perfil } from "../context/AuthContext";

export default function ProtectedRoute({
  allowedRoles,
  children,
}: {
  allowedRoles: Perfil["rol"][];
  children: React.ReactNode;
}) {
  const { user, loading } = useAuth();
  if (loading) return <p className="muted">Cargando sesión…</p>;
  if (!user) return <Navigate to="/login" replace />;
  if (!allowedRoles.includes(user.rol)) return <Navigate to="/" replace />;
  return children;
}
