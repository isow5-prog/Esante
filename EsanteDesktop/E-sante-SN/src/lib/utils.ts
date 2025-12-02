import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";
import { HealthCenter, fetchJson } from "./api";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
// Ajoutez cette fonction dans l'objet `api`

export const api = {
  // ... autres fonctions existantes
  createCenter: (payload: Omit<HealthCenter, 'id'>) => fetchJson<HealthCenter>("/centers/", { method: "POST", json: payload }),
};
