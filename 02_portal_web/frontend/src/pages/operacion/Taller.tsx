import { FormEvent, useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import StatusBadge from "../../components/StatusBadge";

type Orden = {
  id_orden: number;
  id_bicicleta: number;
  codigo_interno: string;
  marca: string;
  modelo: string;
  diagnostico: string;
  estado_orden: string;
  costo_mano_obra: number;
  refacciones: { nombre_refaccion: string; cantidad: number; costo_unitario: number }[];
};

export default function Taller() {
  const [ordenes, setOrdenes] = useState<Orden[]>([]);
  const [flota, setFlota] = useState<{ id_bicicleta: number; codigo_interno: string }[]>([]);
  const [form, setForm] = useState({ id_bicicleta: "", diagnostico: "", costo_mano_obra: "0" });
  const [error, setError] = useState<string | null>(null);

  async function load() {
    const { data } = await client.get("/api/operacion/mantenimiento");
    setOrdenes(data);
  }

  useEffect(() => {
    load().catch((err) => setError(apiError(err)));
    client.get("/api/operacion/bicicletas").then((res) => setFlota(res.data));
  }, []);

  async function crear(event: FormEvent) {
    event.preventDefault();
    try {
      await client.post("/api/operacion/mantenimiento", {
        id_bicicleta: Number(form.id_bicicleta),
        diagnostico: form.diagnostico,
        costo_mano_obra: Number(form.costo_mano_obra),
      });
      setForm({ id_bicicleta: "", diagnostico: "", costo_mano_obra: "0" });
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  async function cerrar(id: number) {
    try {
      await client.patch(`/api/operacion/mantenimiento/${id}`, { estado_orden: "CERRADA" });
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Taller</h1>
      <AlertBanner message={error} />
      <form className="card form" onSubmit={crear}>
        <label>
          Bicicleta
          <select
            required
            value={form.id_bicicleta}
            onChange={(e) => setForm({ ...form, id_bicicleta: e.target.value })}
          >
            <option value="">Selecciona</option>
            {flota.map((b) => (
              <option key={b.id_bicicleta} value={b.id_bicicleta}>
                {b.codigo_interno}
              </option>
            ))}
          </select>
        </label>
        <label>
          Diagnóstico
          <input
            required
            value={form.diagnostico}
            onChange={(e) => setForm({ ...form, diagnostico: e.target.value })}
          />
        </label>
        <label>
          Mano de obra
          <input
            type="number"
            min={0}
            value={form.costo_mano_obra}
            onChange={(e) => setForm({ ...form, costo_mano_obra: e.target.value })}
          />
        </label>
        <button className="btn" type="submit">
          Abrir orden
        </button>
      </form>
      <div className="stack">
        {ordenes.map((o) => (
          <article className="card" key={o.id_orden}>
            <div className="bike-top">
              <strong>
                #{o.id_orden} {o.codigo_interno}
              </strong>
              <StatusBadge value={o.estado_orden} />
            </div>
            <p>
              {o.marca} {o.modelo}
            </p>
            <p>{o.diagnostico}</p>
            <p className="muted">Mano de obra ${o.costo_mano_obra}</p>
            {o.estado_orden !== "CERRADA" && (
              <button className="btn" onClick={() => cerrar(o.id_orden)}>
                Cerrar y devolver a Disponible
              </button>
            )}
          </article>
        ))}
      </div>
    </section>
  );
}
