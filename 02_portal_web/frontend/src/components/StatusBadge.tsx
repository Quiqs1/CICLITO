const TONES: Record<string, string> = {
  Disponible: "ok",
  Confirmada: "ok",
  Finalizada: "ok",
  CORRECTO: "ok",
  CERRADA: "ok",
  Reservada: "warn",
  "Pendiente de pago": "warn",
  "En curso": "warn",
  ABIERTA: "warn",
  EN_PROCESO: "warn",
  "En renta": "info",
  "En mantenimiento": "info",
  Cancelada: "bad",
  FALLA: "bad",
  BLOQUEADA: "bad",
  "Fuera de servicio": "bad",
};

export default function StatusBadge({ value }: { value: string }) {
  const tone = TONES[value] ?? "muted";
  return <span className={`badge ${tone}`}>{value}</span>;
}
