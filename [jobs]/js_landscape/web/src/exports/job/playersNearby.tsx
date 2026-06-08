import { atom, useAtomValue, useSetAtom } from "jotai";

export interface playerNearby{
    name: string;
    id: number;
    citizenid?: string;
}[]

const atomP = atom<playerNearby[]>([])

export const usePlayersNearby = () => useAtomValue(atomP)
export const useSetPlayersNearby = () => useSetAtom(atomP)