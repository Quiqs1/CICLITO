import { useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import StatusBadge from "../../components/StatusBadge";

type Punto = { id_punto: number; nombre: string };
type Detalle = {
  id_bicicleta: number;
  codigo_interno: string;
  id_tipo: number;
  tipo_bicicleta: string;
};
type Reserva = {
  id_reserva: number;
  folio: string;
  estado_reserva: string;
  cliente: string;
  sucursal_recogida: string;
  fecha_inicio_prog: string;
  fecha_fin_prog: string;
  detalle: Detalle[];
};

export default function Mostrador() {
  const [reservas, setReservas] = useState<Reserva[]>([]);
  const [activa, setActiva] = useState<Reserva | null>(null);
  const [puntos, setPuntos] = useState<Record<number, Punto[]>>({});
  const [resultados, setResultados] = useState<Record<string, string>>({});
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  async function load() {
    const { data } = await client.get("/api/operacion/reservas");
    setReservas(data);
  }

  useEffect(() => {
    load().catch((err) => setError(apiError(err)));
  }, []);

  async function abrir(reserva: Reserva) {
    setActiva(reserva);
    const next: Record<number, Punto[]> = {};
    for (const d of reserva.detalle) {
      const { data } = await client.get("/api/operacion/puntos-inspeccion", {
        params: { id_tipo: d.id_tipo },
      });
      next[d.id_bicicleta] = data;
    }
    setPuntos(next);
  }

  function checklists() {
    if (!activa) return [];
    return activa.detalle.map((d) => ({
      id_bicicleta: d.id_bicicleta,
      cargo_dano: Number(resultados[`dano-${d.id_bicicleta}`] || 0),
      observaciones: resultados[`obs-${d.id_bicicleta}`] || "",
      puntos: (puntos[d.id_bicicleta] || []).map((p) => ({
        id_punto: p.id_punto,
        resultado: resultados[`${d.id_bicicleta}-${p.id_punto}`] || "CORRECTO",
        comentario: "",
      })),
    }));
  }

  async function entregar() {
    if (!activa) return;
    try {
      await client.post(`/api/operacion/reservas/${activa.id_reserva}/entregar`, {
        checklists: checklists(),
      });
      setOk(`Entrega registrada para ${activa.folio}`);
      setActiva(null);
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  async function devolver() {
    if (!activa) return;
    try {
      const { data } = await client.post(`/api/operacion/reservas/${activa.id_reserva}/devolver`, {
        checklists: checklists(),
      });
      setOk(
        `Devolución ${activa.folio}: recargo $${data.recargo_retraso}, daños $${data.cargo_dano}, depósito devuelto $${data.deposito_devuelto}`,
      );
      setActiva(null);
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Mostrador de sucursal</h1>
      <AlertBanner message={error} />
      <AlertBanner message={ok} tone="ok" />
      <div className="stack">
        {reservas.map((r) => (
          <article className="card" key={r.id_reserva}>
            <div className="bike-top">
              <strong>{r.folio}</strong>
              <StatusBadge value={r.estado_reserva} />
            </div>
            <p>{r.cliente}</p>
            <p className="muted">
              {r.sucursal_recogida} · {r.fecha_inicio_prog} → {r.fecha_fin_prog}
            </p>
            <p>{r.detalle.map((d) => d.codigo_interno).join(", ")}</p>
            <button className="btn" onClick={() => abrir(r).catch((err) => setError(apiError(err)))}>
              Checklist
            </button>
          </article>
        ))}
      </div>
      {activa && (
        <div className="card">
          <h3>Inspección {activa.folio}</h3>
          {activa.detalle.map((d) => (
            <div key={d.id_bicicleta} className="stack">
              <strong>
                {d.codigo_interno} · {d.tipo_bicicleta}
              </strong>
              {(puntos[d.id_bicicleta] || []).map((p) => (
                <label key={p.id_punto}>
                  {p.nombre}
                  <select
                    value={resultados[`${d.id_bicicleta}-${p.id_punto}`] || "CORRECTO"}
                    onChange={(e) =>
                      setResultados((prev) => ({
                        ...prev,
                        [`${d.id_bicicleta}-${p.id_punto}`]: e.target.value,
                      }))
                    }
                  >
                    <option>CORRECTO</option>
                    <option>REQUIERE_AJUSTE</option>
                    <option>FALLA</option>
                  </select>
                </label>
              ))}
              <label>
                Cargo por daño
                <input
                  type="number"
                  min={0}
                  value={resultados[`dano-${d.id_bicicleta}`] || "0"}
                  onChange={(e) =>
                    setResultados((prev) => ({ ...prev, [`dano-${d.id_bicicleta}`]: e.target.value }))
                  }
                />
              </label>
            </div>
          ))}
          <div className="row">
            <button className="btn" onClick={entregar}>
              Entregar
            </button>
            <button className="ghost" onClick={devolver}>
              Devolver
            </button>
          </div>
        </div>
      )}
    </section>
  );
}
