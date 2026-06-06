import { mockRequest } from './mock';

export const isNuiRuntime = typeof window !== 'undefined' && typeof window.GetParentResourceName === 'function';

export async function nuiFetch(action, data = {}) {
    if (!isNuiRuntime) {
        return mockRequest(action, data);
    }

    const resourceName = window.GetParentResourceName();
    const resp = await fetch(`https://${resourceName}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data ?? {})
    });

    const text = await resp.text();
    if (!text) return null;

    try {
        return JSON.parse(text);
    } catch (err) {
        return text;
    }
}
