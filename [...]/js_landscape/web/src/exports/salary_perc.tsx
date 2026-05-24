import { atom, useAtomValue, useSetAtom } from "jotai";

export interface CSInterface{
    change: boolean,
    for: string,
    forId: number,
    fromId: number,
}

const atomP = atom<CSInterface | null>(null)

export const useChangeSalaryData = () => useAtomValue(atomP)
export const useSetChangeSalaryData = () => useSetAtom(atomP)