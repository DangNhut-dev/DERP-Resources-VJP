import { atom, useAtomValue, useSetAtom } from "jotai";

const atomT = atom<boolean>(false)

export const useShowTutorial = () => useAtomValue(atomT)
export const useSetShowTutorial = () => useSetAtom(atomT)