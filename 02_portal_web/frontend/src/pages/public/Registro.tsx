import { FormEvent, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import { useAuth } from "../../context/AuthContext";

export default function Registro() {
  const navigate = useNavigate();
  const { setSession } = useAuth();
  const [paises, setPaises] = useState<{ id_pais: number; nombre: string }[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    correo: "",
    password: "",
    id_pais: "",
    tipo_identificacion: "INE",
    numero_identificacion: "",
    nombres: "",
    apellidos: "",
    telefono: "",
    fecha_nacimiento: "1998-01-01",
    contacto_nombre: "",
    contacto_parentesco: "Familiar",
    contacto_telefono: "",
  });

  useEffect(() => {
    client.get("/api/catalogo/paises").then((res) => {
      setPaises(res.data);
      if (res.data[0]) setForm((prev) => ({ ...prev, id_pais: String(res.data[0].id_pais) }));
    });
  }, []);

  function set<K extends keyof typeof form>(key: K, value: string) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    try {
      const { data } = await client.post("/api/auth/registro", {
        ...form,
        id_pais: Number(form.id_pais),
      });
      await setSession(data.access_token);
      navigate("/cliente/reservar");
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section className="narrow">
      <h1>Crear cuenta de cliente</h1>
      <AlertBanner message={error} />
      <form className="card form" onSubmit={onSubmit}>
        <label>
          Correo
          <input type="email" required value={form.correo} onChange={(e) => set("correo", e.target.value)} />
        </label>
        <label>
          Contraseña
          <input type="password" minLength={8} required value={form.password} onChange={(e) => set("password", e.target.value)} />
        </label>
        <label>
          Nombres
          <input required value={form.nombres} onChange={(e) => set("nombres", e.target.value)} />
        </label>
        <label>
          Apellidos
          <input required value={form.apellidos} onChange={(e) => set("apellidos", e.target.value)} />
        </label>
        <label>
          Teléfono
          <input required value={form.telefono} onChange={(e) => set("telefono", e.target.value)} />
        </label>
        <label>
          Fecha de nacimiento
          <input type="date" required value={form.fecha_nacimiento} onChange={(e) => set("fecha_nacimiento", e.target.value)} />
        </label>
        <label>
          País
          <select value={form.id_pais} onChange={(e) => set("id_pais", e.target.value)}>
            {paises.map((p) => (
              <option key={p.id_pais} value={p.id_pais}>
                {p.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Identificación
          <select value={form.tipo_identificacion} onChange={(e) => set("tipo_identificacion", e.target.value)}>
            <option>INE</option>
            <option>PASAPORTE</option>
            <option>LICENCIA</option>
            <option>OTRA</option>
          </select>
        </label>
        <label>
          Número
          <input required value={form.numero_identificacion} onChange={(e) => set("numero_identificacion", e.target.value)} />
        </label>
        <label>
          Contacto de emergencia
          <input required value={form.contacto_nombre} onChange={(e) => set("contacto_nombre", e.target.value)} />
        </label>
        <label>
          Parentesco
          <input required value={form.contacto_parentesco} onChange={(e) => set("contacto_parentesco", e.target.value)} />
        </label>
        <label>
          Teléfono de emergencia
          <input required value={form.contacto_telefono} onChange={(e) => set("contacto_telefono", e.target.value)} />
        </label>
        <button className="btn" type="submit">
          Registrarme
        </button>
      </form>
    </section>
  );
}
