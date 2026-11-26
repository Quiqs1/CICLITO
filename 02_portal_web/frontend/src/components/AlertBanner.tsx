export default function AlertBanner({
  message,
  tone = "error",
}: {
  message: string | null;
  tone?: "error" | "ok";
}) {
  if (!message) return null;
  return <div className={`banner ${tone}`}>{message}</div>;
}
