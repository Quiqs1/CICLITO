import { useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import StatusBadge from "../../components/StatusBadge";

export default function Reportes() {
  const [data, setData] = useState<{ ingresos: any[]; rentabilidad: any[]; historial: any[] }>({
    ingresos: [],
    rentabilidad: [],
    historial: [],
  });
  const [usuarios, setUsuarios] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([client.get("/api/admin/reportes/ingresos"), client.get("/api/admin/usuarios")])
      .then(([r, u]) => {
        setData(r.data);
        setUsuarios(u.data);
      })
      .catch((err) => setError(apiError(err)));
  }, []);

  async function toggle(id: number, estado: string) {
    const next = estado === "ACTIVA" ? "BLOQUEADA" : "ACTIVA";
    await client.patch(`/api/admin/usuarios/${id}`, { estado_cuenta: next });
    setUsuarios((prev) => prev.map((u) => (u.id_usuario === id ? { ...u, estado_cuenta: next } : u)));
  }

  return (
    <section>
      <h1>Panel administrativo</h1>
      <AlertBanner message={error} />
      <h2>Ingresos por sucursal</h2>
      <div className="grid">
        {data.ingresos.map((row, idx) => (
          <article className="card" key={`${row.id_sucursal}-${row.anio_mes}-${idx}`}>
            <h3>{row.sucursal}</h3>
            <p>{row.anio_mes}</p>
            <p>Neto ${row.ingreso_neto}</p>
          </article>
        ))}
      </div>
      <h2>Rentabilidad por tipo</h2>
      <div className="grid">
        {data.rentabilidad.map((row) => (
          <article className="card" key={row.tipo_bicicleta}>
            <h3>{row.tipo_bicicleta}</h3>
            <p>{row.veces_rentada} rentas</p>
            <p>${row.ingreso_base}</p>
          </article>
        ))}
      </div>
      <h2>Cuentas</h2>
      <div className="stack">
        {usuarios.map((u) => (
          <article className="card bike-top" key={u.id_usuario}>
            <div>
              <strong>{u.correo}</strong>
              <p className="muted">
                {u.rol} {u.puesto ? `· ${u.puesto}` : ""}
              </p>
            </div>
            <div className="row">
              <StatusBadge value={u.estado_cuenta} />
              <button className="ghost" onClick={() => toggle(u.id_usuario, u.estado_cuenta)}>
                Cambiar estado
              </button>
            </div>
          </article>
        ))}
      </div>
      <h2>Historial de flota</h2>
      <div className="stack">
        {data.historial.slice(0, 20).map((h) => (
          <article className="card" key={h.id_historial}>
            {h.codigo_interno}: {h.estado_anterior || "—"} → {h.estado_nuevo} · {h.motivo}
          </article>
        ))}
      </div>
    </section>
  );
}
