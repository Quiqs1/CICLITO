import { FormEvent, useEffect, useState } from "react";
import client, { apiError } from "../../api/client";
import AlertBanner from "../../components/AlertBanner";
import BikeCard from "../../components/BikeCard";

export default function Flota() {
  const [bikes, setBikes] = useState<any[]>([]);
  const [cats, setCats] = useState<{ tipos: any[]; estados: any[]; sucursales: any[] }>({
    tipos: [],
    estados: [],
    sucursales: [],
  });
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    codigo_interno: "",
    num_serie: "",
    id_tipo: "",
    id_estado_actual: "",
    id_sucursal_actual: "",
    marca: "",
    modelo: "",
    rodada: "26",
    talla_cuadro: "M",
    color: "",
    anio: "2024",
    fecha_adquisicion: "2024-01-15",
    costo_adquisicion: "5000",
    autonomia_km: "",
    capacidad_bateria_wh: "",
  });

  async function load() {
    const [flota, catalogos] = await Promise.all([
      client.get("/api/admin/flota"),
      client.get("/api/admin/catalogos"),
    ]);
    setBikes(flota.data);
    setCats(catalogos.data);
    setForm((prev) => ({
      ...prev,
      id_tipo: prev.id_tipo || String(catalogos.data.tipos[0]?.id_tipo ?? ""),
      id_estado_actual: prev.id_estado_actual || String(catalogos.data.estados[0]?.id_estado_bici ?? ""),
      id_sucursal_actual: prev.id_sucursal_actual || String(catalogos.data.sucursales[0]?.id_sucursal ?? ""),
    }));
  }

  useEffect(() => {
    load().catch((err) => setError(apiError(err)));
  }, []);

  async function crear(event: FormEvent) {
    event.preventDefault();
    try {
      await client.post("/api/admin/flota", {
        ...form,
        id_tipo: Number(form.id_tipo),
        id_estado_actual: Number(form.id_estado_actual),
        id_sucursal_actual: Number(form.id_sucursal_actual),
        rodada: Number(form.rodada),
        anio: Number(form.anio),
        costo_adquisicion: Number(form.costo_adquisicion),
        autonomia_km: form.autonomia_km ? Number(form.autonomia_km) : null,
        capacidad_bateria_wh: form.capacidad_bateria_wh ? Number(form.capacidad_bateria_wh) : null,
      });
      await load();
    } catch (err) {
      setError(apiError(err));
    }
  }

  return (
    <section>
      <h1>Inventario</h1>
      <AlertBanner message={error} />
      <form className="card form" onSubmit={crear}>
        <label>
          Código
          <input required value={form.codigo_interno} onChange={(e) => setForm({ ...form, codigo_interno: e.target.value })} />
        </label>
        <label>
          Serie
          <input required value={form.num_serie} onChange={(e) => setForm({ ...form, num_serie: e.target.value })} />
        </label>
        <label>
          Tipo
          <select value={form.id_tipo} onChange={(e) => setForm({ ...form, id_tipo: e.target.value })}>
            {cats.tipos.map((t) => (
              <option key={t.id_tipo} value={t.id_tipo}>
                {t.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Estado
          <select value={form.id_estado_actual} onChange={(e) => setForm({ ...form, id_estado_actual: e.target.value })}>
            {cats.estados.map((t) => (
              <option key={t.id_estado_bici} value={t.id_estado_bici}>
                {t.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Sucursal
          <select value={form.id_sucursal_actual} onChange={(e) => setForm({ ...form, id_sucursal_actual: e.target.value })}>
            {cats.sucursales.map((t) => (
              <option key={t.id_sucursal} value={t.id_sucursal}>
                {t.nombre}
              </option>
            ))}
          </select>
        </label>
        <label>
          Marca
          <input required value={form.marca} onChange={(e) => setForm({ ...form, marca: e.target.value })} />
        </label>
        <label>
          Modelo
          <input required value={form.modelo} onChange={(e) => setForm({ ...form, modelo: e.target.value })} />
        </label>
        <label>
          Color
          <input required value={form.color} onChange={(e) => setForm({ ...form, color: e.target.value })} />
        </label>
        <button className="btn" type="submit">
          Alta de unidad
        </button>
      </form>
      <div className="grid">
        {bikes.map((bike) => (
          <BikeCard key={bike.id_bicicleta} bike={bike} />
        ))}
      </div>
    </section>
  );
}
