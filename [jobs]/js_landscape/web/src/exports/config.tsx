import { atom, useAtomValue, useSetAtom } from "jotai";

export interface configDATA{
    max_players: number;
    salary: number;
    salary_multiplier: number;
}

const atomConfig = atom<configDATA | null>(null)

export const useConfigData = () => useAtomValue(atomConfig)
export const useSetConfigData = () => useSetAtom(atomConfig)
