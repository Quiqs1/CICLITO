import { Navigate, Route, Routes } from "react-router-dom";
import Navbar from "./components/Navbar";
import ProtectedRoute from "./components/ProtectedRoute";
import Flota from "./pages/admin/Flota";
import Reportes from "./pages/admin/Reportes";
import Tarifas from "./pages/admin/Tarifas";
import MisReservas from "./pages/cliente/MisReservas";
import NuevaReserva from "./pages/cliente/NuevaReserva";
import Mostrador from "./pages/operacion/Mostrador";
import Taller from "./pages/operacion/Taller";
import Catalogo from "./pages/public/Catalogo";
import Home from "./pages/public/Home";
import Login from "./pages/public/Login";
import Registro from "./pages/public/Registro";

export default function App() {
  return (
    <div className="app">
      <Navbar />
      <main>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/catalogo" element={<Catalogo />} />
          <Route path="/login" element={<Login />} />
          <Route path="/registro" element={<Registro />} />
          <Route
            path="/cliente/reservar"
            element={
              <ProtectedRoute allowedRoles={["CLIENTE"]}>
                <NuevaReserva />
              </ProtectedRoute>
            }
          />
          <Route
            path="/cliente/reservas"
            element={
              <ProtectedRoute allowedRoles={["CLIENTE"]}>
                <MisReservas />
              </ProtectedRoute>
            }
          />
          <Route
            path="/operacion"
            element={
              <ProtectedRoute allowedRoles={["EMPLEADO", "ADMINISTRADOR"]}>
                <Mostrador />
              </ProtectedRoute>
            }
          />
          <Route
            path="/operacion/taller"
            element={
              <ProtectedRoute allowedRoles={["EMPLEADO", "ADMINISTRADOR"]}>
                <Taller />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/flota"
            element={
              <ProtectedRoute allowedRoles={["ADMINISTRADOR"]}>
                <Flota />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/tarifas"
            element={
              <ProtectedRoute allowedRoles={["ADMINISTRADOR"]}>
                <Tarifas />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/reportes"
            element={
              <ProtectedRoute allowedRoles={["ADMINISTRADOR"]}>
                <Reportes />
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}
