/**
 * NUI Wrapper Utility v2
 * Simple and clean wrapper for FiveM NUI functions
 */

// Prevent multiple loads
if (typeof window._nuiWrapperLoaded !== 'undefined') {
    console.log('[NUI Wrapper] Already loaded, skipping...');
} else {
    window._nuiWrapperLoaded = true;

    // Detect FiveM environment
    const isFiveM = (function() {
        try {
            // Check if SetNuiFocus exists and is a native function
            return typeof window.SetNuiFocus === 'function' && 
                   window.SetNuiFocus.toString().indexOf('[native code]') > -1;
        } catch (e) {
            return false;
        }
    })();

    // Store originals if in FiveM
    const _nativeSetNuiFocus = isFiveM ? window.SetNuiFocus : null;
    const _nativeGetParentResourceName = isFiveM ? window.GetParentResourceName : null;

    // Wrap SetNuiFocus - only if not already native
    if (!isFiveM) {
        window.SetNuiFocus = function(hasFocus, hasCursor) {
            // Silent in test mode
        };
    }

    // Wrap GetParentResourceName
    if (!window.GetParentResourceName || !isFiveM) {
        window.GetParentResourceName = function() {
            if (_nativeGetParentResourceName) {
                return _nativeGetParentResourceName();
            }
            return 'tommy-weedplant';
        };
    }

    // Helper: Check environment
    window.isInGame = function() {
        return isFiveM;
    };

    // Helper: Safe fetch for NUI callbacks
    window.nuiFetch = function(endpoint, data = {}) {
        if (!isFiveM) {
            // Mock response in test mode
            return Promise.resolve({
                json: () => Promise.resolve({ success: false, error: 'Test mode' })
            });
        }

        const resource = window.GetParentResourceName();
        return fetch(`https://${resource}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
    };

    // Log once
    // console.log('[NUI Wrapper] Loaded -', isFiveM ? 'FiveM Mode' : 'Test Mode');
}
