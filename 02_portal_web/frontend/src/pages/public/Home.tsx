import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";

type Sucursal = {
  id_sucursal: number;
  nombre: string;
  direccion: string;
  colonia_barrio: string;
  telefono: string;
  latitud: number;
  longitud: number;
  horarios: { dia_semana: number; abierto: string; hora_apertura: string | null; hora_cierre: string | null }[];
};

const DIAS = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

export default function Home() {
  const [sucursales, setSucursales] = useState<Sucursal[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    client
      .get("/api/catalogo/sucursales")
      .then((res) => setSucursales(res.data))
      .catch((err) => setError(apiError(err)));
  }, []);

  return (
    <section className="hero-wrap">
      <div className="hero">
        <p className="eyebrow">Oaxaca · renta por hora o por día</p>
        <h1>Pedalea el Centro, El Llano y Jalatlaco con flota lista.</h1>
        <p>
          CICLITO administra disponibilidad en tiempo real, depósitos, inspecciones de entrega y
          taller para Cantera y Pedal.
        </p>
        <div className="row">
          <Link className="btn" to="/catalogo">
            Ver disponibilidad
          </Link>
          <Link className="ghost" to="/registro">
            Registrarme
          </Link>
        </div>
      </div>
      <AlertBanner message={error} />
      <div className="grid">
        {sucursales.map((s) => (
          <article className="card" key={s.id_sucursal}>
            <h3>{s.nombre}</h3>
            <p>
              {s.direccion}, {s.colonia_barrio}
            </p>
            <p className="muted">{s.telefono}</p>
            <ul className="hours">
              {s.horarios.map((h) => (
                <li key={h.dia_semana}>
                  {DIAS[h.dia_semana - 1]}:{" "}
                  {h.abierto === "S" ? `${h.hora_apertura}–${h.hora_cierre}` : "Cerrado"}
                </li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </section>
  );
}
