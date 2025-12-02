const getDefaultApiBaseUrl = () => {
  if (typeof window !== "undefined") {
    const { protocol, hostname } = window.location;
    return `${protocol}//${hostname}:8000/api`;
  }
  return "http://localhost:8000/api";
};

const API_BASE_URL = import.meta.env.VITE_API_URL ?? getDefaultApiBaseUrl();

type FetchOptions = RequestInit & { json?: Record<string, unknown> };

const parseError = async (response: Response) => {
  try {
    const data = await response.json();
    if (data?.detail) {
      return Array.isArray(data.detail) ? data.detail.join(", ") : data.detail;
    }
    return JSON.stringify(data);
  } catch {
    return response.statusText || "Erreur inconnue";
  }
};

export const fetchJson = async <T>(endpoint: string, options: FetchOptions = {}): Promise<T> => {
  const headers = new Headers(options.headers);
  if (options.json) {
    headers.set("Content-Type", "application/json");
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
    body: options.json ? JSON.stringify(options.json) : options.body,
  });

  if (!response.ok) {
    const message = await parseError(response);
    throw new Error(message || "Requête API échouée");
  }

  if (response.status === 204) {
    return {} as T;
  }

  return response.json() as Promise<T>;
};

export type HealthCenter = {
  id: number;
  name: string;
  code: string;
  city: string;
  address: string;
};

export type StatsResponse = {
  mothers: number;
  consultations: number;
  children_followed: number;
};

export type QRCodeCard = {
  id: number;
  code: string;
  status: string;
  center: HealthCenter;
  created_at: string;
};

export type Mother = {
  id: number;
  full_name: string;
  address: string;
  phone: string;
  birth_date: string;
  profession: string;
  center: HealthCenter;
  created_at: string;
  qr_status?: string | null;
  qr_code?: string | null;
};

export type ValidateCardPayload = {
  code: string;
  full_name: string;
  address: string;
  phone: string;
  birth_date: string;
  profession: string;
};

export type AddRecordPayload = {
  code: string;
  address: string;
  phone: string;
  birth_date: string;
  profession: string;
  father_name: string;
  pere_carnet_center: string;
  identification_code: string;
  mother_center_of_birth: string;
  allocation_info: string;
  notes?: string;
};


export const api = {
  // ... autres fonctions existantes
  getStats: () => fetchJson<StatsResponse>("/stats/overview/"),
  getCenters: () => fetchJson<HealthCenter[]>("/centers/"),
  getQrCards: () => fetchJson<QRCodeCard[]>("/qr-cards/"),
  createQrCode: (payload?: { code?: string; center_id?: number }) =>
    fetchJson<QRCodeCard>("/qr-cards/", { method: "POST", json: payload ?? {} }),
  getRecentMothers: () => fetchJson<Mother[]>("/mothers/recent/"),
  validateCard: (payload: ValidateCardPayload) =>
    fetchJson<Mother>("/qr-cards/validate/", { method: "POST", json: payload }),
  addRecord: (payload: AddRecordPayload) =>
    fetchJson("/mothers/add-record/", { method: "POST", json: payload }),
  createCenter: (payload: Omit<HealthCenter, 'id'>) => 
    fetchJson<HealthCenter>("/centers/", { method: "POST", json: payload })
};

