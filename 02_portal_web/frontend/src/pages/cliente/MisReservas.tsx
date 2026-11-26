import { useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import StatusBadge from "../../components/StatusBadge";

type Reserva = {
  id_reserva: number;
  folio: string;
  estado_reserva: string;
  sucursal_recogida: string;
  sucursal_devolucion: string;
  fecha_inicio_prog: string;
  fecha_fin_prog: string;
  temporada: string;
  total_estimado: number;
  detalle: { codigo_interno: string; subtotal: number; deposito_aplicado: number }[];
  pagos: { concepto_pago: string; monto: number }[];
};

export default function MisReservas() {
  const [reservas, setReservas] = useState<Reserva[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  async function load() {
    const { data } = await client.get("/api/reservas/mias");
    setReservas(data);
  }

  useEffect(() => {
    load().catch((err) => setError(apiError(err)));
  }, []);

  async function pagar(id: number) {
    setError(null);
    try {
      await client.post(`/api/reservas/${id}/pagos`, {
        metodo_pago: "TARJETA",
        concepto_pago: "ANTICIPO",
        monto: 200,
        referencia: "WEB",
      });
      setOk("Anticipo registrado.");
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  async function cancelar(id: number) {
    setError(null);
    try {
      await client.post(`/api/reservas/${id}/cancelar`);
      setOk("Reserva cancelada.");
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Mis reservas</h1>
      <AlertBanner message={error} />
      <AlertBanner message={ok} tone="ok" />
      <div className="stack">
        {reservas.map((r) => (
          <article className="card" key={r.id_reserva}>
            <div className="bike-top">
              <strong>{r.folio}</strong>
              <StatusBadge value={r.estado_reserva} />
            </div>
            <p>
              {r.sucursal_recogida} → {r.sucursal_devolucion}
            </p>
            <p className="muted">
              {r.fecha_inicio_prog} — {r.fecha_fin_prog} · {r.temporada}
            </p>
            <p>Total estimado ${r.total_estimado}</p>
            <p>{r.detalle.map((d) => d.codigo_interno).join(", ")}</p>
            <p className="muted">
              Pagos: {r.pagos.map((p) => `${p.concepto_pago} $${p.monto}`).join(" · ") || "sin pagos"}
            </p>
            <div className="row">
              {r.estado_reserva === "Pendiente de pago" && (
                <button className="btn" onClick={() => pagar(r.id_reserva)}>
                  Pagar anticipo
                </button>
              )}
              {!["Cancelada", "Finalizada", "En curso"].includes(r.estado_reserva) && (
                <button className="ghost" onClick={() => cancelar(r.id_reserva)}>
                  Cancelar
                </button>
              )}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
