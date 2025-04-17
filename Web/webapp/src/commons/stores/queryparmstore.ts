// src/stores/sportStore.ts
import { create } from 'zustand';

type SportSourceType = 'betpage' | 'mainpage';

type SportStore = {
  source: SportSourceType;
  setSource: (s: SportSourceType) => void;
};

export const useSportStore = create<SportStore>((set) => ({
  source: 'mainpage', // 기본은 외부 트리거로 가정
  setSource: (s) => set({ source: s }),
}));
