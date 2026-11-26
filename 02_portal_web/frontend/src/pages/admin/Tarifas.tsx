import { FormEvent, useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";

export default function Tarifas() {
  const [data, setData] = useState<{ tarifas: any[]; temporadas: any[] }>({ tarifas: [], temporadas: [] });
  const [tipos, setTipos] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [tarifa, setTarifa] = useState({
    id_tipo: "",
    precio_hora: "50",
    precio_dia: "300",
    vigente_desde: "2026-11-23",
  });
  const [temp, setTemp] = useState({
    nombre: "",
    fecha_inicio: "2026-12-18",
    fecha_fin: "2027-01-03",
    porcentaje_incremento: "15",
  });

  async function load() {
    const [tarifas, catalogos] = await Promise.all([
      client.get("/api/admin/tarifas"),
      client.get("/api/admin/catalogos"),
    ]);
    setData(tarifas.data);
    setTipos(catalogos.data.tipos);
    setTarifa((prev) => ({ ...prev, id_tipo: prev.id_tipo || String(catalogos.data.tipos[0]?.id_tipo ?? "") }));
  }

  useEffect(() => {
    load().catch((err) => setError(apiError(err)));
  }, []);

  async function crearTarifa(event: FormEvent) {
    event.preventDefault();
    try {
      await client.post("/api/admin/tarifas", {
        ...tarifa,
        id_tipo: Number(tarifa.id_tipo),
        precio_hora: Number(tarifa.precio_hora),
        precio_dia: Number(tarifa.precio_dia),
      });
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  async function crearTemp(event: FormEvent) {
    event.preventDefault();
    try {
      await client.post("/api/admin/temporadas", {
        ...temp,
        porcentaje_incremento: Number(temp.porcentaje_incremento),
      });
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Tarifas y temporadas</h1>
      <AlertBanner message={error} />
      <div className="grid">
        <form className="card form" onSubmit={crearTarifa}>
          <h3>Nueva tarifa</h3>
          <label>
            Tipo
            <select value={tarifa.id_tipo} onChange={(e) => setTarifa({ ...tarifa, id_tipo: e.target.value })}>
              {tipos.map((t) => (
                <option key={t.id_tipo} value={t.id_tipo}>
                  {t.nombre}
                </option>
              ))}
            </select>
          </label>
          <label>
            Precio hora
            <input value={tarifa.precio_hora} onChange={(e) => setTarifa({ ...tarifa, precio_hora: e.target.value })} />
          </label>
          <label>
            Precio día
            <input value={tarifa.precio_dia} onChange={(e) => setTarifa({ ...tarifa, precio_dia: e.target.value })} />
          </label>
          <button className="btn">Guardar tarifa</button>
        </form>
        <form className="card form" onSubmit={crearTemp}>
          <h3>Nueva temporada</h3>
          <label>
            Nombre
            <input value={temp.nombre} onChange={(e) => setTemp({ ...temp, nombre: e.target.value })} required />
          </label>
          <label>
            Inicio
            <input type="date" value={temp.fecha_inicio} onChange={(e) => setTemp({ ...temp, fecha_inicio: e.target.value })} />
          </label>
          <label>
            Fin
            <input type="date" value={temp.fecha_fin} onChange={(e) => setTemp({ ...temp, fecha_fin: e.target.value })} />
          </label>
          <label>
            Incremento %
            <input
              value={temp.porcentaje_incremento}
              onChange={(e) => setTemp({ ...temp, porcentaje_incremento: e.target.value })}
            />
          </label>
          <button className="btn">Guardar temporada</button>
        </form>
      </div>
      <h2>Vigentes</h2>
      <div className="stack">
        {data.tarifas.map((t) => (
          <article className="card" key={t.id_tarifa}>
            {t.tipo}: ${t.precio_hora}/h · ${t.precio_dia}/día · desde {t.vigente_desde}
          </article>
        ))}
        {data.temporadas.map((t) => (
          <article className="card" key={t.id_temporada}>
            {t.nombre}: {t.fecha_inicio} a {t.fecha_fin} (+{t.porcentaje_incremento}%)
          </article>
        ))}
      </div>
    </section>
  );
}
