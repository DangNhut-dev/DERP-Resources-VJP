import { atom, useAtomValue, useSetAtom } from "jotai"

export interface JobsToDo{
    job_name: string,
    job_did: number,
    job_todo: number
}[]

const atomJ = atom<JobsToDo[]>([])

export const useJobsToDoData = () => useAtomValue(atomJ)
export const useSetJobsToDoData = () => useSetAtom(atomJ)