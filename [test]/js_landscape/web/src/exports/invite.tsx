import { atom, useAtomValue, useSetAtom } from "jotai";

export interface InviteInterface{
    invite: boolean,
    from: string,
    fromId: number,
    fromCitizenid?: string,
}

const atomP = atom<InviteInterface | null>(null)

export const useInviteData = () => useAtomValue(atomP)
export const useSetInviteData = () => useSetAtom(atomP)