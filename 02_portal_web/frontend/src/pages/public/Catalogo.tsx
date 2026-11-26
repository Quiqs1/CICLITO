import { useEffect, useMemo, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import BikeCard, { type Bike } from "../../components/BikeCard";

function defaultRange() {
  const start = new Date();
  start.setHours(start.getHours() + 2, 0, 0, 0);
  const end = new Date(start);
  end.setHours(end.getHours() + 4);
  const toLocal = (d: Date) => d.toISOString().slice(0, 16);
  return { inicio: toLocal(start), fin: toLocal(end) };
}

export default function Catalogo() {
  const initial = useMemo(defaultRange, []);
  const [sucursales, setSucursales] = useState<{ id_sucursal: number; nombre: string }[]>([]);
  const [tipos, setTipos] = useState<{ id_tipo: number; nombre: string }[]>([]);
  const [idSucursal, setIdSucursal] = useState("");
  const [idTipo, setIdTipo] = useState("");
  const [inicio, setInicio] = useState(initial.inicio);
  const [fin, setFin] = useState(initial.fin);
  const [bikes, setBikes] = useState<Bike[]>([]);
  const [cotizacion, setCotizacion] = useState<Record<string, unknown> | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      client.get("/api/catalogo/sucursales"),
      client.get("/api/catalogo/tipos"),
    ]).then(([s, t]) => {
      setSucursales(s.data);
      setTipos(t.data);
    });
  }, []);

  async function buscar() {
    setError(null);
    try {
      const { data } = await client.get("/api/catalogo/disponibilidad", {
        params: {
          fecha_inicio: inicio,
          fecha_fin: fin,
          id_sucursal: idSucursal || undefined,
          id_tipo: idTipo || undefined,
        },
      });
      setBikes(data);
      if (idTipo) {
        const quote = await client.post("/api/catalogo/cotizar", {
          id_tipo: Number(idTipo),
          fecha_inicio: inicio,
          fecha_fin: fin,
          cantidad: 1,
        });
        setCotizacion(quote.data);
      } else {
        setCotizacion(null);
      }
    } catch (err) {
      setError(apiError(err));
    }
  }

  useEffect(() => {
    buscar().catch(() => undefined);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <section>
      <h1>Explorar flota</h1>
      <div className="filters card">
        <label>
          Recogida
          <input type="datetime-local" value={inicio} onChange={(e) => setInicio(e.target.value)} />
        </label>
        <label>
          Devolución
          <input type="datetime-local" value={fin} onChange={(e) => setFin(e.target.value)} />
        </label>
        <label>
          Sucursal
          <select value={idSucursal} onChange={(e) => setIdSucursal(e.target.value)}>
            <option value="">Todas</option>
            {sucursales.map((s) => (
              <option key={s.id_sucursal} value={s.id_sucursal}>
                {s.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Tipo
          <select value={idTipo} onChange={(e) => setIdTipo(e.target.value)}>
            <option value="">Todos</option>
            {tipos.map((t) => (
              <option key={t.id_tipo} value={t.id_tipo}>
                {t.nombre}
              </option>
            ))}
          </select>
        </label>
        <button className="btn" onClick={buscar}>
          Cotizar / filtrar
        </button>
      </div>
      <AlertBanner message={error} />
      {cotizacion && (
        <div className="card">
          <strong>Cotización</strong>
          <p>
            ${String(cotizacion.costo_unitario)} por unidad · depósito ${String(cotizacion.deposito_unitario)} ·{" "}
            {String(cotizacion.temporada_aplicada)} (+{String(cotizacion.porcentaje_incremento)}%)
          </p>
        </div>
      )}
      <div className="grid">
        {bikes.map((bike) => (
          <BikeCard key={bike.id_bicicleta} bike={bike} />
        ))}
      </div>
      {bikes.length === 0 && <p className="muted">No hay unidades disponibles en ese horario.</p>}
    </section>
  );
}
