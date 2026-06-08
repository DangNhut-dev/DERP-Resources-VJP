import { atom, useAtomValue, useSetAtom } from "jotai";

export interface ProgressData {
    progress: boolean;
    name: string;
    time: number;
}

const atomP = atom<ProgressData | null>(null)

export const useProgressData = () => useAtomValue(atomP)
export const useSetProgressData = () => useSetAtom(atomP)

