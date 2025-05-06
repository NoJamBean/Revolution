// store/authStore.ts
import { create } from 'zustand';

interface AuthState {
  token: string | null;
  setToken: (token: string) => void;
  clearToken: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  setToken: (token) => {
    localStorage.setItem('auth_token', token); // localStorage에 저장
    set({ token });
  },
  clearToken: () => {
    localStorage.removeItem('auth_token');
    set({ token: null });
  },
}));
