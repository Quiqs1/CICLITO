import StatusBadge from "./StatusBadge";

export type Bike = {
  id_bicicleta: number;
  codigo_interno: string;
  tipo_bicicleta?: string;
  tipo?: string;
  marca: string;
  modelo: string;
  color: string;
  rodada: number;
  talla_cuadro: string;
  sucursal_actual?: string;
  sucursal?: string;
  estado_actual?: string;
  estado?: string;
  precio_hora?: number | null;
  precio_dia?: number | null;
  deposito_garantia?: number;
  autonomia_km?: number | null;
  selected?: boolean;
};

export default function BikeCard({
  bike,
  onSelect,
  selected,
}: {
  bike: Bike;
  onSelect?: () => void;
  selected?: boolean;
}) {
  const tipo = bike.tipo_bicicleta || bike.tipo || "Bicicleta";
  const sucursal = bike.sucursal_actual || bike.sucursal;
  const estado = bike.estado_actual || bike.estado;
  return (
    <article className={`card bike ${selected ? "selected" : ""}`} onClick={onSelect}>
      <div className="bike-top">
        <strong>{bike.codigo_interno}</strong>
        {estado && <StatusBadge value={estado} />}
      </div>
      <h3>
        {bike.marca} {bike.modelo}
      </h3>
      <p className="muted">
        {tipo} · {bike.color} · rodada {bike.rodada} · talla {bike.talla_cuadro}
      </p>
      {sucursal && <p>Sucursal: {sucursal}</p>}
      {bike.autonomia_km ? <p>Autonomía {bike.autonomia_km} km</p> : null}
      {bike.precio_hora != null && (
        <p className="price">
          ${bike.precio_hora}/h · ${bike.precio_dia}/día
        </p>
      )}
    </article>
  );
}
