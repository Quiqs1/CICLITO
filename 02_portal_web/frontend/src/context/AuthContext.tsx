import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import client from "../api/client";

export type Perfil = {
  id_usuario: number;
  rol: "CLIENTE" | "EMPLEADO" | "ADMINISTRADOR";
  correo: string;
  estado_cuenta: string;
  id_cliente: number | null;
  cliente_nombres: string | null;
  cliente_apellidos: string | null;
  id_empleado: number | null;
  id_sucursal: number | null;
  sucursal_nombre: string | null;
  empleado_nombres: string | null;
  empleado_apellidos: string | null;
  puesto: string | null;
};

type AuthContextValue = {
  user: Perfil | null;
  loading: boolean;
  login: (correo: string, password: string) => Promise<Perfil>;
  logout: () => void;
  setSession: (token: string) => Promise<Perfil>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<Perfil | null>(null);
  const [loading, setLoading] = useState(true);

  async function loadMe(): Promise<Perfil> {
    const { data } = await client.get<Perfil>("/api/auth/me");
    setUser(data);
    return data;
  }

  async function setSession(token: string): Promise<Perfil> {
    localStorage.setItem("ciclito_token", token);
    return loadMe();
  }

  async function login(correo: string, password: string): Promise<Perfil> {
    const { data } = await client.post("/api/auth/login", { correo, password });
    return setSession(data.access_token);
  }

  function logout() {
    localStorage.removeItem("ciclito_token");
    setUser(null);
  }

  useEffect(() => {
    const token = localStorage.getItem("ciclito_token");
    if (!token) {
      setLoading(false);
      return;
    }
    loadMe()
      .catch(() => logout())
      .finally(() => setLoading(false));
  }, []);

  const value = useMemo(
    () => ({ user, loading, login, logout, setSession }),
    [user, loading],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de AuthProvider");
  return ctx;
}
