/* ================== ESTADOS ================== */
export const ESTADOS = {
  reviewing:           { label: "En revisión",          dot: "#EAB308", bg: "#FEF9C3", fg: "#854D0E", emoji: "🟡" },
  preselected:         { label: "Preseleccionado",      dot: "#22C55E", bg: "#DCFCE7", fg: "#166534", emoji: "🟢" },
  observation:         { label: "En observación",       dot: "#F97316", bg: "#FFEDD5", fg: "#9A3412", emoji: "🟠" },
  interview_scheduled: { label: "Entrevista programada",dot: "#3B82F6", bg: "#DBEAFE", fg: "#1E40AF", emoji: "🔵" },
  finalist:            { label: "Finalista",            dot: "#A855F7", bg: "#F3E8FF", fg: "#6B21A8", emoji: "🟣" },
  selected:            { label: "Seleccionado",         dot: "#D4A017", bg: "#FDF3D7", fg: "#7A5C00", emoji: "⭐" },
  rejected:            { label: "No continúa",          dot: "#EF4444", bg: "#FEE2E2", fg: "#991B1B", emoji: "🔴" },
};

export const ORDER = ["reviewing","preselected","observation","interview_scheduled","finalist","selected","rejected"];
