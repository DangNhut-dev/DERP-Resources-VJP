import { atom, useAtomValue, useSetAtom } from "jotai";

export interface teamData {
    name: string;
    id: number;
    citizenid?: string;
    salary: number;
    owner: boolean;
}[]

const atomT = atom<teamData[]>([])

export const useTeamData = () => useAtomValue(atomT)
export const useSetTeamData = () => useSetAtom(atomT)



const atomIS = atom<boolean>(false)

export const useIsTeamCreated = () => useAtomValue(atomIS)
export const useSetIsTeamCreated = () => useSetAtom(atomIS)