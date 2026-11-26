import { FormEvent, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import BikeCard, { type Bike } from "../../components/BikeCard";

function defaultRange() {
  const start = new Date();
  start.setHours(start.getHours() + 3, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { inicio: start.toISOString().slice(0, 16), fin: end.toISOString().slice(0, 16) };
}

export default function NuevaReserva() {
  const navigate = useNavigate();
  const initial = useMemo(defaultRange, []);
  const [sucursales, setSucursales] = useState<{ id_sucursal: number; nombre: string }[]>([]);
  const [inicio, setInicio] = useState(initial.inicio);
  const [fin, setFin] = useState(initial.fin);
  const [recogida, setRecogida] = useState("");
  const [devolucion, setDevolucion] = useState("");
  const [bikes, setBikes] = useState<Bike[]>([]);
  const [seleccion, setSeleccion] = useState<number[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  useEffect(() => {
    client.get("/api/catalogo/sucursales").then((res) => {
      setSucursales(res.data);
      if (res.data[0]) {
        setRecogida(String(res.data[0].id_sucursal));
        setDevolucion(String(res.data[0].id_sucursal));
      }
    });
  }, []);

  async function buscar() {
    setError(null);
    const { data } = await client.get("/api/catalogo/disponibilidad", {
      params: { fecha_inicio: inicio, fecha_fin: fin, id_sucursal: recogida },
    });
    setBikes(data);
    setSeleccion([]);
  }

  function toggle(id: number) {
    setSeleccion((prev) => {
      if (prev.includes(id)) return prev.filter((x) => x !== id);
      if (prev.length >= 5) return prev;
      return [...prev, id];
    });
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setOk(null);
    try {
      const { data } = await client.post("/api/reservas", {
        id_sucursal_recogida: Number(recogida),
        id_sucursal_devolucion: Number(devolucion),
        fecha_inicio: inicio,
        fecha_fin: fin,
        ids_bicicletas: seleccion,
      });
      setOk(`Reserva creada: ${data.folio}`);
      navigate("/cliente/reservas");
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Nueva reserva</h1>
      <p className="muted">Selecciona de 1 a 5 bicicletas en la sucursal de recogida.</p>
      <AlertBanner message={error} />
      <AlertBanner message={ok} tone="ok" />
      <form className="card filters" onSubmit={(e) => { e.preventDefault(); buscar().catch((err) => setError(apiError(err))); }}>
        <label>
          Inicio
          <input type="datetime-local" value={inicio} onChange={(e) => setInicio(e.target.value)} />
        </label>
        <label>
          Fin
          <input type="datetime-local" value={fin} onChange={(e) => setFin(e.target.value)} />
        </label>
        <label>
          Recogida
          <select value={recogida} onChange={(e) => setRecogida(e.target.value)}>
            {sucursales.map((s) => (
              <option key={s.id_sucursal} value={s.id_sucursal}>
                {s.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Devolución
          <select value={devolucion} onChange={(e) => setDevolucion(e.target.value)}>
            {sucursales.map((s) => (
              <option key={s.id_sucursal} value={s.id_sucursal}>
                {s.nombre}
              </option>
            ))}
          </select>
        </label>
        <button className="btn" type="submit">
          Buscar
        </button>
      </form>
      <div className="grid">
        {bikes.map((bike) => (
          <BikeCard
            key={bike.id_bicicleta}
            bike={bike}
            selected={seleccion.includes(bike.id_bicicleta)}
            onSelect={() => toggle(bike.id_bicicleta)}
          />
        ))}
      </div>
      <form className="card" onSubmit={onSubmit}>
        <p>
          Seleccionadas: {seleccion.length} / 5
        </p>
        <button className="btn" disabled={seleccion.length === 0} type="submit">
          Confirmar reserva
        </button>
      </form>
    </section>
  );
}
