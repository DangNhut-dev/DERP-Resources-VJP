import { atom, useAtomValue, useSetAtom } from "jotai";

export interface playerData{
    name: string;
    id: number;
    citizenid?: string;
    ownage: boolean;
    level: number;
    xp: number;
}

const atomPlayer = atom<playerData | null>(null)

export const usePlayerData = () => useAtomValue(atomPlayer)
export const useSetPlayerData = () => useSetAtom(atomPlayer)

