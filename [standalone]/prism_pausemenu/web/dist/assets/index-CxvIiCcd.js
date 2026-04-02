(function () {
    const S = document.createElement("link").relList;
    if (S && S.supports && S.supports("modulepreload")) return;
    for (const M of document.querySelectorAll('link[rel="modulepreload"]')) r(M);
    new MutationObserver((M) => {
        for (const H of M)
            if (H.type === "childList")
                for (const V of H.addedNodes) V.tagName === "LINK" && V.rel === "modulepreload" && r(V);
    }).observe(document, { childList: !0, subtree: !0 });
    function x(M) {
        const H = {};
        return (
            M.integrity && (H.integrity = M.integrity),
            M.referrerPolicy && (H.referrerPolicy = M.referrerPolicy),
            M.crossOrigin === "use-credentials"
                ? (H.credentials = "include")
                : M.crossOrigin === "anonymous"
                  ? (H.credentials = "omit")
                  : (H.credentials = "same-origin"),
            H
        );
    }
    function r(M) {
        if (M.ep) return;
        M.ep = !0;
        const H = x(M);
        fetch(M.href, H);
    }
})();
function $d(s) {
    return s && s.__esModule && Object.prototype.hasOwnProperty.call(s, "default") ? s.default : s;
}
var ui = { exports: {} },
    Su = {};
/**
 * @license React
 * react-jsx-runtime.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */ var er;
function kd() {
    if (er) return Su;
    er = 1;
    var s = Symbol.for("react.transitional.element"),
        S = Symbol.for("react.fragment");
    function x(r, M, H) {
        var V = null;
        if ((H !== void 0 && (V = "" + H), M.key !== void 0 && (V = "" + M.key), "key" in M)) {
            H = {};
            for (var W in M) W !== "key" && (H[W] = M[W]);
        } else H = M;
        return (M = H.ref), { $$typeof: s, type: r, key: V, ref: M !== void 0 ? M : null, props: H };
    }
    return (Su.Fragment = S), (Su.jsx = x), (Su.jsxs = x), Su;
}
var ur;
function Pd() {
    return ur || ((ur = 1), (ui.exports = kd())), ui.exports;
}
var b = Pd(),
    ni = { exports: {} },
    Z = {};
/**
 * @license React
 * react.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */ var nr;
function Id() {
    if (nr) return Z;
    nr = 1;
    var s = Symbol.for("react.transitional.element"),
        S = Symbol.for("react.portal"),
        x = Symbol.for("react.fragment"),
        r = Symbol.for("react.strict_mode"),
        M = Symbol.for("react.profiler"),
        H = Symbol.for("react.consumer"),
        V = Symbol.for("react.context"),
        W = Symbol.for("react.forward_ref"),
        D = Symbol.for("react.suspense"),
        z = Symbol.for("react.memo"),
        B = Symbol.for("react.lazy"),
        sl = Symbol.iterator;
    function fl(o) {
        return o === null || typeof o != "object"
            ? null
            : ((o = (sl && o[sl]) || o["@@iterator"]), typeof o == "function" ? o : null);
    }
    var Hl = {
            isMounted: function () {
                return !1;
            },
            enqueueForceUpdate: function () {},
            enqueueReplaceState: function () {},
            enqueueSetState: function () {},
        },
        Bl = Object.assign,
        vt = {};
    function Yl(o, O, j) {
        (this.props = o), (this.context = O), (this.refs = vt), (this.updater = j || Hl);
    }
    (Yl.prototype.isReactComponent = {}),
        (Yl.prototype.setState = function (o, O) {
            if (typeof o != "object" && typeof o != "function" && o != null)
                throw Error(
                    "takes an object of state variables to update or a function which returns an object of state variables."
                );
            this.updater.enqueueSetState(this, o, O, "setState");
        }),
        (Yl.prototype.forceUpdate = function (o) {
            this.updater.enqueueForceUpdate(this, o, "forceUpdate");
        });
    function va() {}
    va.prototype = Yl.prototype;
    function Ot(o, O, j) {
        (this.props = o), (this.context = O), (this.refs = vt), (this.updater = j || Hl);
    }
    var Nl = (Ot.prototype = new va());
    (Nl.constructor = Ot), Bl(Nl, Yl.prototype), (Nl.isPureReactComponent = !0);
    var yt = Array.isArray,
        $ = { H: null, A: null, T: null, S: null, V: null },
        Ll = Object.prototype.hasOwnProperty;
    function wl(o, O, j, N, C, k) {
        return (j = k.ref), { $$typeof: s, type: o, key: O, ref: j !== void 0 ? j : null, props: k };
    }
    function Kl(o, O) {
        return wl(o.type, O, void 0, void 0, void 0, o.props);
    }
    function St(o) {
        return typeof o == "object" && o !== null && o.$$typeof === s;
    }
    function Ca(o) {
        var O = { "=": "=0", ":": "=2" };
        return (
            "$" +
            o.replace(/[=:]/g, function (j) {
                return O[j];
            })
        );
    }
    var Mt = /\/+/g;
    function _l(o, O) {
        return typeof o == "object" && o !== null && o.key != null ? Ca("" + o.key) : O.toString(36);
    }
    function ya() {}
    function ma(o) {
        switch (o.status) {
            case "fulfilled":
                return o.value;
            case "rejected":
                throw o.reason;
            default:
                switch (
                    (typeof o.status == "string"
                        ? o.then(ya, ya)
                        : ((o.status = "pending"),
                          o.then(
                              function (O) {
                                  o.status === "pending" && ((o.status = "fulfilled"), (o.value = O));
                              },
                              function (O) {
                                  o.status === "pending" && ((o.status = "rejected"), (o.reason = O));
                              }
                          )),
                    o.status)
                ) {
                    case "fulfilled":
                        return o.value;
                    case "rejected":
                        throw o.reason;
                }
        }
        throw o;
    }
    function Dl(o, O, j, N, C) {
        var k = typeof o;
        (k === "undefined" || k === "boolean") && (o = null);
        var Q = !1;
        if (o === null) Q = !0;
        else
            switch (k) {
                case "bigint":
                case "string":
                case "number":
                    Q = !0;
                    break;
                case "object":
                    switch (o.$$typeof) {
                        case s:
                        case S:
                            Q = !0;
                            break;
                        case B:
                            return (Q = o._init), Dl(Q(o._payload), O, j, N, C);
                    }
            }
        if (Q)
            return (
                (C = C(o)),
                (Q = N === "" ? "." + _l(o, 0) : N),
                yt(C)
                    ? ((j = ""),
                      Q != null && (j = Q.replace(Mt, "$&/") + "/"),
                      Dl(C, O, j, "", function (Vt) {
                          return Vt;
                      }))
                    : C != null &&
                      (St(C) &&
                          (C = Kl(
                              C,
                              j +
                                  (C.key == null || (o && o.key === C.key)
                                      ? ""
                                      : ("" + C.key).replace(Mt, "$&/") + "/") +
                                  Q
                          )),
                      O.push(C)),
                1
            );
        Q = 0;
        var Jl = N === "" ? "." : N + ":";
        if (yt(o)) for (var rl = 0; rl < o.length; rl++) (N = o[rl]), (k = Jl + _l(N, rl)), (Q += Dl(N, O, j, k, C));
        else if (((rl = fl(o)), typeof rl == "function"))
            for (o = rl.call(o), rl = 0; !(N = o.next()).done; )
                (N = N.value), (k = Jl + _l(N, rl++)), (Q += Dl(N, O, j, k, C));
        else if (k === "object") {
            if (typeof o.then == "function") return Dl(ma(o), O, j, N, C);
            throw (
                ((O = String(o)),
                Error(
                    "Objects are not valid as a React child (found: " +
                        (O === "[object Object]" ? "object with keys {" + Object.keys(o).join(", ") + "}" : O) +
                        "). If you meant to render a collection of children, use an array instead."
                ))
            );
        }
        return Q;
    }
    function E(o, O, j) {
        if (o == null) return o;
        var N = [],
            C = 0;
        return (
            Dl(o, N, "", "", function (k) {
                return O.call(j, k, C++);
            }),
            N
        );
    }
    function _(o) {
        if (o._status === -1) {
            var O = o._result;
            (O = O()),
                O.then(
                    function (j) {
                        (o._status === 0 || o._status === -1) && ((o._status = 1), (o._result = j));
                    },
                    function (j) {
                        (o._status === 0 || o._status === -1) && ((o._status = 2), (o._result = j));
                    }
                ),
                o._status === -1 && ((o._status = 0), (o._result = O));
        }
        if (o._status === 1) return o._result.default;
        throw o._result;
    }
    var G =
        typeof reportError == "function"
            ? reportError
            : function (o) {
                  if (typeof window == "object" && typeof window.ErrorEvent == "function") {
                      var O = new window.ErrorEvent("error", {
                          bubbles: !0,
                          cancelable: !0,
                          message:
                              typeof o == "object" && o !== null && typeof o.message == "string"
                                  ? String(o.message)
                                  : String(o),
                          error: o,
                      });
                      if (!window.dispatchEvent(O)) return;
                  } else if (typeof process == "object" && typeof process.emit == "function") {
                      process.emit("uncaughtException", o);
                      return;
                  }
                  console.error(o);
              };
    function nl() {}
    return (
        (Z.Children = {
            map: E,
            forEach: function (o, O, j) {
                E(
                    o,
                    function () {
                        O.apply(this, arguments);
                    },
                    j
                );
            },
            count: function (o) {
                var O = 0;
                return (
                    E(o, function () {
                        O++;
                    }),
                    O
                );
            },
            toArray: function (o) {
                return (
                    E(o, function (O) {
                        return O;
                    }) || []
                );
            },
            only: function (o) {
                if (!St(o)) throw Error("React.Children.only expected to receive a single React element child.");
                return o;
            },
        }),
        (Z.Component = Yl),
        (Z.Fragment = x),
        (Z.Profiler = M),
        (Z.PureComponent = Ot),
        (Z.StrictMode = r),
        (Z.Suspense = D),
        (Z.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE = $),
        (Z.__COMPILER_RUNTIME = {
            __proto__: null,
            c: function (o) {
                return $.H.useMemoCache(o);
            },
        }),
        (Z.cache = function (o) {
            return function () {
                return o.apply(null, arguments);
            };
        }),
        (Z.cloneElement = function (o, O, j) {
            if (o == null) throw Error("The argument must be a React element, but you passed " + o + ".");
            var N = Bl({}, o.props),
                C = o.key,
                k = void 0;
            if (O != null)
                for (Q in (O.ref !== void 0 && (k = void 0), O.key !== void 0 && (C = "" + O.key), O))
                    !Ll.call(O, Q) ||
                        Q === "key" ||
                        Q === "__self" ||
                        Q === "__source" ||
                        (Q === "ref" && O.ref === void 0) ||
                        (N[Q] = O[Q]);
            var Q = arguments.length - 2;
            if (Q === 1) N.children = j;
            else if (1 < Q) {
                for (var Jl = Array(Q), rl = 0; rl < Q; rl++) Jl[rl] = arguments[rl + 2];
                N.children = Jl;
            }
            return wl(o.type, C, void 0, void 0, k, N);
        }),
        (Z.createContext = function (o) {
            return (
                (o = {
                    $$typeof: V,
                    _currentValue: o,
                    _currentValue2: o,
                    _threadCount: 0,
                    Provider: null,
                    Consumer: null,
                }),
                (o.Provider = o),
                (o.Consumer = { $$typeof: H, _context: o }),
                o
            );
        }),
        (Z.createElement = function (o, O, j) {
            var N,
                C = {},
                k = null;
            if (O != null)
                for (N in (O.key !== void 0 && (k = "" + O.key), O))
                    Ll.call(O, N) && N !== "key" && N !== "__self" && N !== "__source" && (C[N] = O[N]);
            var Q = arguments.length - 2;
            if (Q === 1) C.children = j;
            else if (1 < Q) {
                for (var Jl = Array(Q), rl = 0; rl < Q; rl++) Jl[rl] = arguments[rl + 2];
                C.children = Jl;
            }
            if (o && o.defaultProps) for (N in ((Q = o.defaultProps), Q)) C[N] === void 0 && (C[N] = Q[N]);
            return wl(o, k, void 0, void 0, null, C);
        }),
        (Z.createRef = function () {
            return { current: null };
        }),
        (Z.forwardRef = function (o) {
            return { $$typeof: W, render: o };
        }),
        (Z.isValidElement = St),
        (Z.lazy = function (o) {
            return { $$typeof: B, _payload: { _status: -1, _result: o }, _init: _ };
        }),
        (Z.memo = function (o, O) {
            return { $$typeof: z, type: o, compare: O === void 0 ? null : O };
        }),
        (Z.startTransition = function (o) {
            var O = $.T,
                j = {};
            $.T = j;
            try {
                var N = o(),
                    C = $.S;
                C !== null && C(j, N),
                    typeof N == "object" && N !== null && typeof N.then == "function" && N.then(nl, G);
            } catch (k) {
                G(k);
            } finally {
                $.T = O;
            }
        }),
        (Z.unstable_useCacheRefresh = function () {
            return $.H.useCacheRefresh();
        }),
        (Z.use = function (o) {
            return $.H.use(o);
        }),
        (Z.useActionState = function (o, O, j) {
            return $.H.useActionState(o, O, j);
        }),
        (Z.useCallback = function (o, O) {
            return $.H.useCallback(o, O);
        }),
        (Z.useContext = function (o) {
            return $.H.useContext(o);
        }),
        (Z.useDebugValue = function () {}),
        (Z.useDeferredValue = function (o, O) {
            return $.H.useDeferredValue(o, O);
        }),
        (Z.useEffect = function (o, O, j) {
            var N = $.H;
            if (typeof j == "function") throw Error("useEffect CRUD overload is not enabled in this build of React.");
            return N.useEffect(o, O);
        }),
        (Z.useId = function () {
            return $.H.useId();
        }),
        (Z.useImperativeHandle = function (o, O, j) {
            return $.H.useImperativeHandle(o, O, j);
        }),
        (Z.useInsertionEffect = function (o, O) {
            return $.H.useInsertionEffect(o, O);
        }),
        (Z.useLayoutEffect = function (o, O) {
            return $.H.useLayoutEffect(o, O);
        }),
        (Z.useMemo = function (o, O) {
            return $.H.useMemo(o, O);
        }),
        (Z.useOptimistic = function (o, O) {
            return $.H.useOptimistic(o, O);
        }),
        (Z.useReducer = function (o, O, j) {
            return $.H.useReducer(o, O, j);
        }),
        (Z.useRef = function (o) {
            return $.H.useRef(o);
        }),
        (Z.useState = function (o) {
            return $.H.useState(o);
        }),
        (Z.useSyncExternalStore = function (o, O, j) {
            return $.H.useSyncExternalStore(o, O, j);
        }),
        (Z.useTransition = function () {
            return $.H.useTransition();
        }),
        (Z.version = "19.1.0"),
        Z
    );
}
var cr;
function ri() {
    return cr || ((cr = 1), (ni.exports = Id())), ni.exports;
}
var dt = ri();
const Ba = $d(dt);
var ci = { exports: {} },
    xu = {},
    fi = { exports: {} },
    ii = {};
/**
 * @license React
 * scheduler.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */ var fr;
function lh() {
    return (
        fr ||
            ((fr = 1),
            (function (s) {
                function S(E, _) {
                    var G = E.length;
                    E.push(_);
                    l: for (; 0 < G; ) {
                        var nl = (G - 1) >>> 1,
                            o = E[nl];
                        if (0 < M(o, _)) (E[nl] = _), (E[G] = o), (G = nl);
                        else break l;
                    }
                }
                function x(E) {
                    return E.length === 0 ? null : E[0];
                }
                function r(E) {
                    if (E.length === 0) return null;
                    var _ = E[0],
                        G = E.pop();
                    if (G !== _) {
                        E[0] = G;
                        l: for (var nl = 0, o = E.length, O = o >>> 1; nl < O; ) {
                            var j = 2 * (nl + 1) - 1,
                                N = E[j],
                                C = j + 1,
                                k = E[C];
                            if (0 > M(N, G))
                                C < o && 0 > M(k, N)
                                    ? ((E[nl] = k), (E[C] = G), (nl = C))
                                    : ((E[nl] = N), (E[j] = G), (nl = j));
                            else if (C < o && 0 > M(k, G)) (E[nl] = k), (E[C] = G), (nl = C);
                            else break l;
                        }
                    }
                    return _;
                }
                function M(E, _) {
                    var G = E.sortIndex - _.sortIndex;
                    return G !== 0 ? G : E.id - _.id;
                }
                if (
                    ((s.unstable_now = void 0), typeof performance == "object" && typeof performance.now == "function")
                ) {
                    var H = performance;
                    s.unstable_now = function () {
                        return H.now();
                    };
                } else {
                    var V = Date,
                        W = V.now();
                    s.unstable_now = function () {
                        return V.now() - W;
                    };
                }
                var D = [],
                    z = [],
                    B = 1,
                    sl = null,
                    fl = 3,
                    Hl = !1,
                    Bl = !1,
                    vt = !1,
                    Yl = !1,
                    va = typeof setTimeout == "function" ? setTimeout : null,
                    Ot = typeof clearTimeout == "function" ? clearTimeout : null,
                    Nl = typeof setImmediate < "u" ? setImmediate : null;
                function yt(E) {
                    for (var _ = x(z); _ !== null; ) {
                        if (_.callback === null) r(z);
                        else if (_.startTime <= E) r(z), (_.sortIndex = _.expirationTime), S(D, _);
                        else break;
                        _ = x(z);
                    }
                }
                function $(E) {
                    if (((vt = !1), yt(E), !Bl))
                        if (x(D) !== null) (Bl = !0), Ll || ((Ll = !0), _l());
                        else {
                            var _ = x(z);
                            _ !== null && Dl($, _.startTime - E);
                        }
                }
                var Ll = !1,
                    wl = -1,
                    Kl = 5,
                    St = -1;
                function Ca() {
                    return Yl ? !0 : !(s.unstable_now() - St < Kl);
                }
                function Mt() {
                    if (((Yl = !1), Ll)) {
                        var E = s.unstable_now();
                        St = E;
                        var _ = !0;
                        try {
                            l: {
                                (Bl = !1), vt && ((vt = !1), Ot(wl), (wl = -1)), (Hl = !0);
                                var G = fl;
                                try {
                                    t: {
                                        for (yt(E), sl = x(D); sl !== null && !(sl.expirationTime > E && Ca()); ) {
                                            var nl = sl.callback;
                                            if (typeof nl == "function") {
                                                (sl.callback = null), (fl = sl.priorityLevel);
                                                var o = nl(sl.expirationTime <= E);
                                                if (((E = s.unstable_now()), typeof o == "function")) {
                                                    (sl.callback = o), yt(E), (_ = !0);
                                                    break t;
                                                }
                                                sl === x(D) && r(D), yt(E);
                                            } else r(D);
                                            sl = x(D);
                                        }
                                        if (sl !== null) _ = !0;
                                        else {
                                            var O = x(z);
                                            O !== null && Dl($, O.startTime - E), (_ = !1);
                                        }
                                    }
                                    break l;
                                } finally {
                                    (sl = null), (fl = G), (Hl = !1);
                                }
                                _ = void 0;
                            }
                        } finally {
                            _ ? _l() : (Ll = !1);
                        }
                    }
                }
                var _l;
                if (typeof Nl == "function")
                    _l = function () {
                        Nl(Mt);
                    };
                else if (typeof MessageChannel < "u") {
                    var ya = new MessageChannel(),
                        ma = ya.port2;
                    (ya.port1.onmessage = Mt),
                        (_l = function () {
                            ma.postMessage(null);
                        });
                } else
                    _l = function () {
                        va(Mt, 0);
                    };
                function Dl(E, _) {
                    wl = va(function () {
                        E(s.unstable_now());
                    }, _);
                }
                (s.unstable_IdlePriority = 5),
                    (s.unstable_ImmediatePriority = 1),
                    (s.unstable_LowPriority = 4),
                    (s.unstable_NormalPriority = 3),
                    (s.unstable_Profiling = null),
                    (s.unstable_UserBlockingPriority = 2),
                    (s.unstable_cancelCallback = function (E) {
                        E.callback = null;
                    }),
                    (s.unstable_forceFrameRate = function (E) {
                        0 > E || 125 < E
                            ? console.error(
                                  "forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported"
                              )
                            : (Kl = 0 < E ? Math.floor(1e3 / E) : 5);
                    }),
                    (s.unstable_getCurrentPriorityLevel = function () {
                        return fl;
                    }),
                    (s.unstable_next = function (E) {
                        switch (fl) {
                            case 1:
                            case 2:
                            case 3:
                                var _ = 3;
                                break;
                            default:
                                _ = fl;
                        }
                        var G = fl;
                        fl = _;
                        try {
                            return E();
                        } finally {
                            fl = G;
                        }
                    }),
                    (s.unstable_requestPaint = function () {
                        Yl = !0;
                    }),
                    (s.unstable_runWithPriority = function (E, _) {
                        switch (E) {
                            case 1:
                            case 2:
                            case 3:
                            case 4:
                            case 5:
                                break;
                            default:
                                E = 3;
                        }
                        var G = fl;
                        fl = E;
                        try {
                            return _();
                        } finally {
                            fl = G;
                        }
                    }),
                    (s.unstable_scheduleCallback = function (E, _, G) {
                        var nl = s.unstable_now();
                        switch (
                            (typeof G == "object" && G !== null
                                ? ((G = G.delay), (G = typeof G == "number" && 0 < G ? nl + G : nl))
                                : (G = nl),
                            E)
                        ) {
                            case 1:
                                var o = -1;
                                break;
                            case 2:
                                o = 250;
                                break;
                            case 5:
                                o = 1073741823;
                                break;
                            case 4:
                                o = 1e4;
                                break;
                            default:
                                o = 5e3;
                        }
                        return (
                            (o = G + o),
                            (E = {
                                id: B++,
                                callback: _,
                                priorityLevel: E,
                                startTime: G,
                                expirationTime: o,
                                sortIndex: -1,
                            }),
                            G > nl
                                ? ((E.sortIndex = G),
                                  S(z, E),
                                  x(D) === null && E === x(z) && (vt ? (Ot(wl), (wl = -1)) : (vt = !0), Dl($, G - nl)))
                                : ((E.sortIndex = o), S(D, E), Bl || Hl || ((Bl = !0), Ll || ((Ll = !0), _l()))),
                            E
                        );
                    }),
                    (s.unstable_shouldYield = Ca),
                    (s.unstable_wrapCallback = function (E) {
                        var _ = fl;
                        return function () {
                            var G = fl;
                            fl = _;
                            try {
                                return E.apply(this, arguments);
                            } finally {
                                fl = G;
                            }
                        };
                    });
            })(ii)),
        ii
    );
}
var ir;
function th() {
    return ir || ((ir = 1), (fi.exports = lh())), fi.exports;
}
var si = { exports: {} },
    Rl = {};
/**
 * @license React
 * react-dom.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */ var sr;
function ah() {
    if (sr) return Rl;
    sr = 1;
    var s = ri();
    function S(D) {
        var z = "https://react.dev/errors/" + D;
        if (1 < arguments.length) {
            z += "?args[]=" + encodeURIComponent(arguments[1]);
            for (var B = 2; B < arguments.length; B++) z += "&args[]=" + encodeURIComponent(arguments[B]);
        }
        return (
            "Minified React error #" +
            D +
            "; visit " +
            z +
            " for the full message or use the non-minified dev environment for full errors and additional helpful warnings."
        );
    }
    function x() {}
    var r = {
            d: {
                f: x,
                r: function () {
                    throw Error(S(522));
                },
                D: x,
                C: x,
                L: x,
                m: x,
                X: x,
                S: x,
                M: x,
            },
            p: 0,
            findDOMNode: null,
        },
        M = Symbol.for("react.portal");
    function H(D, z, B) {
        var sl = 3 < arguments.length && arguments[3] !== void 0 ? arguments[3] : null;
        return { $$typeof: M, key: sl == null ? null : "" + sl, children: D, containerInfo: z, implementation: B };
    }
    var V = s.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE;
    function W(D, z) {
        if (D === "font") return "";
        if (typeof z == "string") return z === "use-credentials" ? z : "";
    }
    return (
        (Rl.__DOM_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE = r),
        (Rl.createPortal = function (D, z) {
            var B = 2 < arguments.length && arguments[2] !== void 0 ? arguments[2] : null;
            if (!z || (z.nodeType !== 1 && z.nodeType !== 9 && z.nodeType !== 11)) throw Error(S(299));
            return H(D, z, null, B);
        }),
        (Rl.flushSync = function (D) {
            var z = V.T,
                B = r.p;
            try {
                if (((V.T = null), (r.p = 2), D)) return D();
            } finally {
                (V.T = z), (r.p = B), r.d.f();
            }
        }),
        (Rl.preconnect = function (D, z) {
            typeof D == "string" &&
                (z
                    ? ((z = z.crossOrigin), (z = typeof z == "string" ? (z === "use-credentials" ? z : "") : void 0))
                    : (z = null),
                r.d.C(D, z));
        }),
        (Rl.prefetchDNS = function (D) {
            typeof D == "string" && r.d.D(D);
        }),
        (Rl.preinit = function (D, z) {
            if (typeof D == "string" && z && typeof z.as == "string") {
                var B = z.as,
                    sl = W(B, z.crossOrigin),
                    fl = typeof z.integrity == "string" ? z.integrity : void 0,
                    Hl = typeof z.fetchPriority == "string" ? z.fetchPriority : void 0;
                B === "style"
                    ? r.d.S(D, typeof z.precedence == "string" ? z.precedence : void 0, {
                          crossOrigin: sl,
                          integrity: fl,
                          fetchPriority: Hl,
                      })
                    : B === "script" &&
                      r.d.X(D, {
                          crossOrigin: sl,
                          integrity: fl,
                          fetchPriority: Hl,
                          nonce: typeof z.nonce == "string" ? z.nonce : void 0,
                      });
            }
        }),
        (Rl.preinitModule = function (D, z) {
            if (typeof D == "string")
                if (typeof z == "object" && z !== null) {
                    if (z.as == null || z.as === "script") {
                        var B = W(z.as, z.crossOrigin);
                        r.d.M(D, {
                            crossOrigin: B,
                            integrity: typeof z.integrity == "string" ? z.integrity : void 0,
                            nonce: typeof z.nonce == "string" ? z.nonce : void 0,
                        });
                    }
                } else z == null && r.d.M(D);
        }),
        (Rl.preload = function (D, z) {
            if (typeof D == "string" && typeof z == "object" && z !== null && typeof z.as == "string") {
                var B = z.as,
                    sl = W(B, z.crossOrigin);
                r.d.L(D, B, {
                    crossOrigin: sl,
                    integrity: typeof z.integrity == "string" ? z.integrity : void 0,
                    nonce: typeof z.nonce == "string" ? z.nonce : void 0,
                    type: typeof z.type == "string" ? z.type : void 0,
                    fetchPriority: typeof z.fetchPriority == "string" ? z.fetchPriority : void 0,
                    referrerPolicy: typeof z.referrerPolicy == "string" ? z.referrerPolicy : void 0,
                    imageSrcSet: typeof z.imageSrcSet == "string" ? z.imageSrcSet : void 0,
                    imageSizes: typeof z.imageSizes == "string" ? z.imageSizes : void 0,
                    media: typeof z.media == "string" ? z.media : void 0,
                });
            }
        }),
        (Rl.preloadModule = function (D, z) {
            if (typeof D == "string")
                if (z) {
                    var B = W(z.as, z.crossOrigin);
                    r.d.m(D, {
                        as: typeof z.as == "string" && z.as !== "script" ? z.as : void 0,
                        crossOrigin: B,
                        integrity: typeof z.integrity == "string" ? z.integrity : void 0,
                    });
                } else r.d.m(D);
        }),
        (Rl.requestFormReset = function (D) {
            r.d.r(D);
        }),
        (Rl.unstable_batchedUpdates = function (D, z) {
            return D(z);
        }),
        (Rl.useFormState = function (D, z, B) {
            return V.H.useFormState(D, z, B);
        }),
        (Rl.useFormStatus = function () {
            return V.H.useHostTransitionStatus();
        }),
        (Rl.version = "19.1.0"),
        Rl
    );
}
var rr;
function eh() {
    if (rr) return si.exports;
    rr = 1;
    function s() {
        if (
            !(
                typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ > "u" ||
                typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE != "function"
            )
        )
            try {
                __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(s);
            } catch (S) {
                console.error(S);
            }
    }
    return s(), (si.exports = ah()), si.exports;
}
/**
 * @license React
 * react-dom-client.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */ var or;
function uh() {
    if (or) return xu;
    or = 1;
    var s = th(),
        S = ri(),
        x = eh();
    function r(l) {
        var t = "https://react.dev/errors/" + l;
        if (1 < arguments.length) {
            t += "?args[]=" + encodeURIComponent(arguments[1]);
            for (var a = 2; a < arguments.length; a++) t += "&args[]=" + encodeURIComponent(arguments[a]);
        }
        return (
            "Minified React error #" +
            l +
            "; visit " +
            t +
            " for the full message or use the non-minified dev environment for full errors and additional helpful warnings."
        );
    }
    function M(l) {
        return !(!l || (l.nodeType !== 1 && l.nodeType !== 9 && l.nodeType !== 11));
    }
    function H(l) {
        var t = l,
            a = l;
        if (l.alternate) for (; t.return; ) t = t.return;
        else {
            l = t;
            do (t = l), (t.flags & 4098) !== 0 && (a = t.return), (l = t.return);
            while (l);
        }
        return t.tag === 3 ? a : null;
    }
    function V(l) {
        if (l.tag === 13) {
            var t = l.memoizedState;
            if ((t === null && ((l = l.alternate), l !== null && (t = l.memoizedState)), t !== null))
                return t.dehydrated;
        }
        return null;
    }
    function W(l) {
        if (H(l) !== l) throw Error(r(188));
    }
    function D(l) {
        var t = l.alternate;
        if (!t) {
            if (((t = H(l)), t === null)) throw Error(r(188));
            return t !== l ? null : l;
        }
        for (var a = l, e = t; ; ) {
            var u = a.return;
            if (u === null) break;
            var n = u.alternate;
            if (n === null) {
                if (((e = u.return), e !== null)) {
                    a = e;
                    continue;
                }
                break;
            }
            if (u.child === n.child) {
                for (n = u.child; n; ) {
                    if (n === a) return W(u), l;
                    if (n === e) return W(u), t;
                    n = n.sibling;
                }
                throw Error(r(188));
            }
            if (a.return !== e.return) (a = u), (e = n);
            else {
                for (var c = !1, f = u.child; f; ) {
                    if (f === a) {
                        (c = !0), (a = u), (e = n);
                        break;
                    }
                    if (f === e) {
                        (c = !0), (e = u), (a = n);
                        break;
                    }
                    f = f.sibling;
                }
                if (!c) {
                    for (f = n.child; f; ) {
                        if (f === a) {
                            (c = !0), (a = n), (e = u);
                            break;
                        }
                        if (f === e) {
                            (c = !0), (e = n), (a = u);
                            break;
                        }
                        f = f.sibling;
                    }
                    if (!c) throw Error(r(189));
                }
            }
            if (a.alternate !== e) throw Error(r(190));
        }
        if (a.tag !== 3) throw Error(r(188));
        return a.stateNode.current === a ? l : t;
    }
    function z(l) {
        var t = l.tag;
        if (t === 5 || t === 26 || t === 27 || t === 6) return l;
        for (l = l.child; l !== null; ) {
            if (((t = z(l)), t !== null)) return t;
            l = l.sibling;
        }
        return null;
    }
    var B = Object.assign,
        sl = Symbol.for("react.element"),
        fl = Symbol.for("react.transitional.element"),
        Hl = Symbol.for("react.portal"),
        Bl = Symbol.for("react.fragment"),
        vt = Symbol.for("react.strict_mode"),
        Yl = Symbol.for("react.profiler"),
        va = Symbol.for("react.provider"),
        Ot = Symbol.for("react.consumer"),
        Nl = Symbol.for("react.context"),
        yt = Symbol.for("react.forward_ref"),
        $ = Symbol.for("react.suspense"),
        Ll = Symbol.for("react.suspense_list"),
        wl = Symbol.for("react.memo"),
        Kl = Symbol.for("react.lazy"),
        St = Symbol.for("react.activity"),
        Ca = Symbol.for("react.memo_cache_sentinel"),
        Mt = Symbol.iterator;
    function _l(l) {
        return l === null || typeof l != "object"
            ? null
            : ((l = (Mt && l[Mt]) || l["@@iterator"]), typeof l == "function" ? l : null);
    }
    var ya = Symbol.for("react.client.reference");
    function ma(l) {
        if (l == null) return null;
        if (typeof l == "function") return l.$$typeof === ya ? null : l.displayName || l.name || null;
        if (typeof l == "string") return l;
        switch (l) {
            case Bl:
                return "Fragment";
            case Yl:
                return "Profiler";
            case vt:
                return "StrictMode";
            case $:
                return "Suspense";
            case Ll:
                return "SuspenseList";
            case St:
                return "Activity";
        }
        if (typeof l == "object")
            switch (l.$$typeof) {
                case Hl:
                    return "Portal";
                case Nl:
                    return (l.displayName || "Context") + ".Provider";
                case Ot:
                    return (l._context.displayName || "Context") + ".Consumer";
                case yt:
                    var t = l.render;
                    return (
                        (l = l.displayName),
                        l ||
                            ((l = t.displayName || t.name || ""),
                            (l = l !== "" ? "ForwardRef(" + l + ")" : "ForwardRef")),
                        l
                    );
                case wl:
                    return (t = l.displayName || null), t !== null ? t : ma(l.type) || "Memo";
                case Kl:
                    (t = l._payload), (l = l._init);
                    try {
                        return ma(l(t));
                    } catch {}
            }
        return null;
    }
    var Dl = Array.isArray,
        E = S.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE,
        _ = x.__DOM_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE,
        G = { pending: !1, data: null, method: null, action: null },
        nl = [],
        o = -1;
    function O(l) {
        return { current: l };
    }
    function j(l) {
        0 > o || ((l.current = nl[o]), (nl[o] = null), o--);
    }
    function N(l, t) {
        o++, (nl[o] = l.current), (l.current = t);
    }
    var C = O(null),
        k = O(null),
        Q = O(null),
        Jl = O(null);
    function rl(l, t) {
        switch ((N(Q, t), N(k, l), N(C, null), t.nodeType)) {
            case 9:
            case 11:
                l = (l = t.documentElement) && (l = l.namespaceURI) ? j1(l) : 0;
                break;
            default:
                if (((l = t.tagName), (t = t.namespaceURI))) (t = j1(t)), (l = U1(t, l));
                else
                    switch (l) {
                        case "svg":
                            l = 1;
                            break;
                        case "math":
                            l = 2;
                            break;
                        default:
                            l = 0;
                    }
        }
        j(C), N(C, l);
    }
    function Vt() {
        j(C), j(k), j(Q);
    }
    function Zn(l) {
        l.memoizedState !== null && N(Jl, l);
        var t = C.current,
            a = U1(t, l.type);
        t !== a && (N(k, l), N(C, a));
    }
    function Eu(l) {
        k.current === l && (j(C), j(k)), Jl.current === l && (j(Jl), (vu._currentValue = G));
    }
    var Vn = Object.prototype.hasOwnProperty,
        Ln = s.unstable_scheduleCallback,
        wn = s.unstable_cancelCallback,
        Mr = s.unstable_shouldYield,
        Nr = s.unstable_requestPaint,
        xt = s.unstable_now,
        _r = s.unstable_getCurrentPriorityLevel,
        oi = s.unstable_ImmediatePriority,
        di = s.unstable_UserBlockingPriority,
        pu = s.unstable_NormalPriority,
        Dr = s.unstable_LowPriority,
        hi = s.unstable_IdlePriority,
        jr = s.log,
        Ur = s.unstable_setDisableYieldValue,
        Ee = null,
        Fl = null;
    function Lt(l) {
        if ((typeof jr == "function" && Ur(l), Fl && typeof Fl.setStrictMode == "function"))
            try {
                Fl.setStrictMode(Ee, l);
            } catch {}
    }
    var Wl = Math.clz32 ? Math.clz32 : Br,
        Rr = Math.log,
        Hr = Math.LN2;
    function Br(l) {
        return (l >>>= 0), l === 0 ? 32 : (31 - ((Rr(l) / Hr) | 0)) | 0;
    }
    var Au = 256,
        zu = 4194304;
    function ga(l) {
        var t = l & 42;
        if (t !== 0) return t;
        switch (l & -l) {
            case 1:
                return 1;
            case 2:
                return 2;
            case 4:
                return 4;
            case 8:
                return 8;
            case 16:
                return 16;
            case 32:
                return 32;
            case 64:
                return 64;
            case 128:
                return 128;
            case 256:
            case 512:
            case 1024:
            case 2048:
            case 4096:
            case 8192:
            case 16384:
            case 32768:
            case 65536:
            case 131072:
            case 262144:
            case 524288:
            case 1048576:
            case 2097152:
                return l & 4194048;
            case 4194304:
            case 8388608:
            case 16777216:
            case 33554432:
                return l & 62914560;
            case 67108864:
                return 67108864;
            case 134217728:
                return 134217728;
            case 268435456:
                return 268435456;
            case 536870912:
                return 536870912;
            case 1073741824:
                return 0;
            default:
                return l;
        }
    }
    function Ou(l, t, a) {
        var e = l.pendingLanes;
        if (e === 0) return 0;
        var u = 0,
            n = l.suspendedLanes,
            c = l.pingedLanes;
        l = l.warmLanes;
        var f = e & 134217727;
        return (
            f !== 0
                ? ((e = f & ~n),
                  e !== 0
                      ? (u = ga(e))
                      : ((c &= f), c !== 0 ? (u = ga(c)) : a || ((a = f & ~l), a !== 0 && (u = ga(a)))))
                : ((f = e & ~n),
                  f !== 0 ? (u = ga(f)) : c !== 0 ? (u = ga(c)) : a || ((a = e & ~l), a !== 0 && (u = ga(a)))),
            u === 0
                ? 0
                : t !== 0 &&
                    t !== u &&
                    (t & n) === 0 &&
                    ((n = u & -u), (a = t & -t), n >= a || (n === 32 && (a & 4194048) !== 0))
                  ? t
                  : u
        );
    }
    function pe(l, t) {
        return (l.pendingLanes & ~(l.suspendedLanes & ~l.pingedLanes) & t) === 0;
    }
    function Cr(l, t) {
        switch (l) {
            case 1:
            case 2:
            case 4:
            case 8:
            case 64:
                return t + 250;
            case 16:
            case 32:
            case 128:
            case 256:
            case 512:
            case 1024:
            case 2048:
            case 4096:
            case 8192:
            case 16384:
            case 32768:
            case 65536:
            case 131072:
            case 262144:
            case 524288:
            case 1048576:
            case 2097152:
                return t + 5e3;
            case 4194304:
            case 8388608:
            case 16777216:
            case 33554432:
                return -1;
            case 67108864:
            case 134217728:
            case 268435456:
            case 536870912:
            case 1073741824:
                return -1;
            default:
                return -1;
        }
    }
    function vi() {
        var l = Au;
        return (Au <<= 1), (Au & 4194048) === 0 && (Au = 256), l;
    }
    function yi() {
        var l = zu;
        return (zu <<= 1), (zu & 62914560) === 0 && (zu = 4194304), l;
    }
    function Kn(l) {
        for (var t = [], a = 0; 31 > a; a++) t.push(l);
        return t;
    }
    function Ae(l, t) {
        (l.pendingLanes |= t), t !== 268435456 && ((l.suspendedLanes = 0), (l.pingedLanes = 0), (l.warmLanes = 0));
    }
    function qr(l, t, a, e, u, n) {
        var c = l.pendingLanes;
        (l.pendingLanes = a),
            (l.suspendedLanes = 0),
            (l.pingedLanes = 0),
            (l.warmLanes = 0),
            (l.expiredLanes &= a),
            (l.entangledLanes &= a),
            (l.errorRecoveryDisabledLanes &= a),
            (l.shellSuspendCounter = 0);
        var f = l.entanglements,
            i = l.expirationTimes,
            y = l.hiddenUpdates;
        for (a = c & ~a; 0 < a; ) {
            var T = 31 - Wl(a),
                A = 1 << T;
            (f[T] = 0), (i[T] = -1);
            var m = y[T];
            if (m !== null)
                for (y[T] = null, T = 0; T < m.length; T++) {
                    var g = m[T];
                    g !== null && (g.lane &= -536870913);
                }
            a &= ~A;
        }
        e !== 0 && mi(l, e, 0), n !== 0 && u === 0 && l.tag !== 0 && (l.suspendedLanes |= n & ~(c & ~t));
    }
    function mi(l, t, a) {
        (l.pendingLanes |= t), (l.suspendedLanes &= ~t);
        var e = 31 - Wl(t);
        (l.entangledLanes |= t), (l.entanglements[e] = l.entanglements[e] | 1073741824 | (a & 4194090));
    }
    function gi(l, t) {
        var a = (l.entangledLanes |= t);
        for (l = l.entanglements; a; ) {
            var e = 31 - Wl(a),
                u = 1 << e;
            (u & t) | (l[e] & t) && (l[e] |= t), (a &= ~u);
        }
    }
    function Jn(l) {
        switch (l) {
            case 2:
                l = 1;
                break;
            case 8:
                l = 4;
                break;
            case 32:
                l = 16;
                break;
            case 256:
            case 512:
            case 1024:
            case 2048:
            case 4096:
            case 8192:
            case 16384:
            case 32768:
            case 65536:
            case 131072:
            case 262144:
            case 524288:
            case 1048576:
            case 2097152:
            case 4194304:
            case 8388608:
            case 16777216:
            case 33554432:
                l = 128;
                break;
            case 268435456:
                l = 134217728;
                break;
            default:
                l = 0;
        }
        return l;
    }
    function Fn(l) {
        return (l &= -l), 2 < l ? (8 < l ? ((l & 134217727) !== 0 ? 32 : 268435456) : 8) : 2;
    }
    function bi() {
        var l = _.p;
        return l !== 0 ? l : ((l = window.event), l === void 0 ? 32 : k1(l.type));
    }
    function Yr(l, t) {
        var a = _.p;
        try {
            return (_.p = l), t();
        } finally {
            _.p = a;
        }
    }
    var wt = Math.random().toString(36).slice(2),
        jl = "__reactFiber$" + wt,
        Gl = "__reactProps$" + wt,
        qa = "__reactContainer$" + wt,
        Wn = "__reactEvents$" + wt,
        Gr = "__reactListeners$" + wt,
        Xr = "__reactHandles$" + wt,
        Si = "__reactResources$" + wt,
        ze = "__reactMarker$" + wt;
    function $n(l) {
        delete l[jl], delete l[Gl], delete l[Wn], delete l[Gr], delete l[Xr];
    }
    function Ya(l) {
        var t = l[jl];
        if (t) return t;
        for (var a = l.parentNode; a; ) {
            if ((t = a[qa] || a[jl])) {
                if (((a = t.alternate), t.child !== null || (a !== null && a.child !== null)))
                    for (l = C1(l); l !== null; ) {
                        if ((a = l[jl])) return a;
                        l = C1(l);
                    }
                return t;
            }
            (l = a), (a = l.parentNode);
        }
        return null;
    }
    function Ga(l) {
        if ((l = l[jl] || l[qa])) {
            var t = l.tag;
            if (t === 5 || t === 6 || t === 13 || t === 26 || t === 27 || t === 3) return l;
        }
        return null;
    }
    function Oe(l) {
        var t = l.tag;
        if (t === 5 || t === 26 || t === 27 || t === 6) return l.stateNode;
        throw Error(r(33));
    }
    function Xa(l) {
        var t = l[Si];
        return t || (t = l[Si] = { hoistableStyles: new Map(), hoistableScripts: new Map() }), t;
    }
    function Tl(l) {
        l[ze] = !0;
    }
    var xi = new Set(),
        Ti = {};
    function ba(l, t) {
        Qa(l, t), Qa(l + "Capture", t);
    }
    function Qa(l, t) {
        for (Ti[l] = t, l = 0; l < t.length; l++) xi.add(t[l]);
    }
    var Qr = RegExp(
            "^[:A-Z_a-z\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u02FF\\u0370-\\u037D\\u037F-\\u1FFF\\u200C-\\u200D\\u2070-\\u218F\\u2C00-\\u2FEF\\u3001-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFFD][:A-Z_a-z\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u02FF\\u0370-\\u037D\\u037F-\\u1FFF\\u200C-\\u200D\\u2070-\\u218F\\u2C00-\\u2FEF\\u3001-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFFD\\-.0-9\\u00B7\\u0300-\\u036F\\u203F-\\u2040]*$"
        ),
        Ei = {},
        pi = {};
    function Zr(l) {
        return Vn.call(pi, l) ? !0 : Vn.call(Ei, l) ? !1 : Qr.test(l) ? (pi[l] = !0) : ((Ei[l] = !0), !1);
    }
    function Mu(l, t, a) {
        if (Zr(t))
            if (a === null) l.removeAttribute(t);
            else {
                switch (typeof a) {
                    case "undefined":
                    case "function":
                    case "symbol":
                        l.removeAttribute(t);
                        return;
                    case "boolean":
                        var e = t.toLowerCase().slice(0, 5);
                        if (e !== "data-" && e !== "aria-") {
                            l.removeAttribute(t);
                            return;
                        }
                }
                l.setAttribute(t, "" + a);
            }
    }
    function Nu(l, t, a) {
        if (a === null) l.removeAttribute(t);
        else {
            switch (typeof a) {
                case "undefined":
                case "function":
                case "symbol":
                case "boolean":
                    l.removeAttribute(t);
                    return;
            }
            l.setAttribute(t, "" + a);
        }
    }
    function Nt(l, t, a, e) {
        if (e === null) l.removeAttribute(a);
        else {
            switch (typeof e) {
                case "undefined":
                case "function":
                case "symbol":
                case "boolean":
                    l.removeAttribute(a);
                    return;
            }
            l.setAttributeNS(t, a, "" + e);
        }
    }
    var kn, Ai;
    function Za(l) {
        if (kn === void 0)
            try {
                throw Error();
            } catch (a) {
                var t = a.stack.trim().match(/\n( *(at )?)/);
                (kn = (t && t[1]) || ""),
                    (Ai =
                        -1 <
                        a.stack.indexOf(`
    at`)
                            ? " (<anonymous>)"
                            : -1 < a.stack.indexOf("@")
                              ? "@unknown:0:0"
                              : "");
            }
        return (
            `
` +
            kn +
            l +
            Ai
        );
    }
    var Pn = !1;
    function In(l, t) {
        if (!l || Pn) return "";
        Pn = !0;
        var a = Error.prepareStackTrace;
        Error.prepareStackTrace = void 0;
        try {
            var e = {
                DetermineComponentFrameRoot: function () {
                    try {
                        if (t) {
                            var A = function () {
                                throw Error();
                            };
                            if (
                                (Object.defineProperty(A.prototype, "props", {
                                    set: function () {
                                        throw Error();
                                    },
                                }),
                                typeof Reflect == "object" && Reflect.construct)
                            ) {
                                try {
                                    Reflect.construct(A, []);
                                } catch (g) {
                                    var m = g;
                                }
                                Reflect.construct(l, [], A);
                            } else {
                                try {
                                    A.call();
                                } catch (g) {
                                    m = g;
                                }
                                l.call(A.prototype);
                            }
                        } else {
                            try {
                                throw Error();
                            } catch (g) {
                                m = g;
                            }
                            (A = l()) && typeof A.catch == "function" && A.catch(function () {});
                        }
                    } catch (g) {
                        if (g && m && typeof g.stack == "string") return [g.stack, m.stack];
                    }
                    return [null, null];
                },
            };
            e.DetermineComponentFrameRoot.displayName = "DetermineComponentFrameRoot";
            var u = Object.getOwnPropertyDescriptor(e.DetermineComponentFrameRoot, "name");
            u &&
                u.configurable &&
                Object.defineProperty(e.DetermineComponentFrameRoot, "name", { value: "DetermineComponentFrameRoot" });
            var n = e.DetermineComponentFrameRoot(),
                c = n[0],
                f = n[1];
            if (c && f) {
                var i = c.split(`
`),
                    y = f.split(`
`);
                for (u = e = 0; e < i.length && !i[e].includes("DetermineComponentFrameRoot"); ) e++;
                for (; u < y.length && !y[u].includes("DetermineComponentFrameRoot"); ) u++;
                if (e === i.length || u === y.length)
                    for (e = i.length - 1, u = y.length - 1; 1 <= e && 0 <= u && i[e] !== y[u]; ) u--;
                for (; 1 <= e && 0 <= u; e--, u--)
                    if (i[e] !== y[u]) {
                        if (e !== 1 || u !== 1)
                            do
                                if ((e--, u--, 0 > u || i[e] !== y[u])) {
                                    var T =
                                        `
` + i[e].replace(" at new ", " at ");
                                    return (
                                        l.displayName &&
                                            T.includes("<anonymous>") &&
                                            (T = T.replace("<anonymous>", l.displayName)),
                                        T
                                    );
                                }
                            while (1 <= e && 0 <= u);
                        break;
                    }
            }
        } finally {
            (Pn = !1), (Error.prepareStackTrace = a);
        }
        return (a = l ? l.displayName || l.name : "") ? Za(a) : "";
    }
    function Vr(l) {
        switch (l.tag) {
            case 26:
            case 27:
            case 5:
                return Za(l.type);
            case 16:
                return Za("Lazy");
            case 13:
                return Za("Suspense");
            case 19:
                return Za("SuspenseList");
            case 0:
            case 15:
                return In(l.type, !1);
            case 11:
                return In(l.type.render, !1);
            case 1:
                return In(l.type, !0);
            case 31:
                return Za("Activity");
            default:
                return "";
        }
    }
    function zi(l) {
        try {
            var t = "";
            do (t += Vr(l)), (l = l.return);
            while (l);
            return t;
        } catch (a) {
            return (
                `
Error generating stack: ` +
                a.message +
                `
` +
                a.stack
            );
        }
    }
    function et(l) {
        switch (typeof l) {
            case "bigint":
            case "boolean":
            case "number":
            case "string":
            case "undefined":
                return l;
            case "object":
                return l;
            default:
                return "";
        }
    }
    function Oi(l) {
        var t = l.type;
        return (l = l.nodeName) && l.toLowerCase() === "input" && (t === "checkbox" || t === "radio");
    }
    function Lr(l) {
        var t = Oi(l) ? "checked" : "value",
            a = Object.getOwnPropertyDescriptor(l.constructor.prototype, t),
            e = "" + l[t];
        if (!l.hasOwnProperty(t) && typeof a < "u" && typeof a.get == "function" && typeof a.set == "function") {
            var u = a.get,
                n = a.set;
            return (
                Object.defineProperty(l, t, {
                    configurable: !0,
                    get: function () {
                        return u.call(this);
                    },
                    set: function (c) {
                        (e = "" + c), n.call(this, c);
                    },
                }),
                Object.defineProperty(l, t, { enumerable: a.enumerable }),
                {
                    getValue: function () {
                        return e;
                    },
                    setValue: function (c) {
                        e = "" + c;
                    },
                    stopTracking: function () {
                        (l._valueTracker = null), delete l[t];
                    },
                }
            );
        }
    }
    function _u(l) {
        l._valueTracker || (l._valueTracker = Lr(l));
    }
    function Mi(l) {
        if (!l) return !1;
        var t = l._valueTracker;
        if (!t) return !0;
        var a = t.getValue(),
            e = "";
        return l && (e = Oi(l) ? (l.checked ? "true" : "false") : l.value), (l = e), l !== a ? (t.setValue(l), !0) : !1;
    }
    function Du(l) {
        if (((l = l || (typeof document < "u" ? document : void 0)), typeof l > "u")) return null;
        try {
            return l.activeElement || l.body;
        } catch {
            return l.body;
        }
    }
    var wr = /[\n"\\]/g;
    function ut(l) {
        return l.replace(wr, function (t) {
            return "\\" + t.charCodeAt(0).toString(16) + " ";
        });
    }
    function lc(l, t, a, e, u, n, c, f) {
        (l.name = ""),
            c != null && typeof c != "function" && typeof c != "symbol" && typeof c != "boolean"
                ? (l.type = c)
                : l.removeAttribute("type"),
            t != null
                ? c === "number"
                    ? ((t === 0 && l.value === "") || l.value != t) && (l.value = "" + et(t))
                    : l.value !== "" + et(t) && (l.value = "" + et(t))
                : (c !== "submit" && c !== "reset") || l.removeAttribute("value"),
            t != null ? tc(l, c, et(t)) : a != null ? tc(l, c, et(a)) : e != null && l.removeAttribute("value"),
            u == null && n != null && (l.defaultChecked = !!n),
            u != null && (l.checked = u && typeof u != "function" && typeof u != "symbol"),
            f != null && typeof f != "function" && typeof f != "symbol" && typeof f != "boolean"
                ? (l.name = "" + et(f))
                : l.removeAttribute("name");
    }
    function Ni(l, t, a, e, u, n, c, f) {
        if (
            (n != null && typeof n != "function" && typeof n != "symbol" && typeof n != "boolean" && (l.type = n),
            t != null || a != null)
        ) {
            if (!((n !== "submit" && n !== "reset") || t != null)) return;
            (a = a != null ? "" + et(a) : ""),
                (t = t != null ? "" + et(t) : a),
                f || t === l.value || (l.value = t),
                (l.defaultValue = t);
        }
        (e = e ?? u),
            (e = typeof e != "function" && typeof e != "symbol" && !!e),
            (l.checked = f ? l.checked : !!e),
            (l.defaultChecked = !!e),
            c != null && typeof c != "function" && typeof c != "symbol" && typeof c != "boolean" && (l.name = c);
    }
    function tc(l, t, a) {
        (t === "number" && Du(l.ownerDocument) === l) || l.defaultValue === "" + a || (l.defaultValue = "" + a);
    }
    function Va(l, t, a, e) {
        if (((l = l.options), t)) {
            t = {};
            for (var u = 0; u < a.length; u++) t["$" + a[u]] = !0;
            for (a = 0; a < l.length; a++)
                (u = t.hasOwnProperty("$" + l[a].value)),
                    l[a].selected !== u && (l[a].selected = u),
                    u && e && (l[a].defaultSelected = !0);
        } else {
            for (a = "" + et(a), t = null, u = 0; u < l.length; u++) {
                if (l[u].value === a) {
                    (l[u].selected = !0), e && (l[u].defaultSelected = !0);
                    return;
                }
                t !== null || l[u].disabled || (t = l[u]);
            }
            t !== null && (t.selected = !0);
        }
    }
    function _i(l, t, a) {
        if (t != null && ((t = "" + et(t)), t !== l.value && (l.value = t), a == null)) {
            l.defaultValue !== t && (l.defaultValue = t);
            return;
        }
        l.defaultValue = a != null ? "" + et(a) : "";
    }
    function Di(l, t, a, e) {
        if (t == null) {
            if (e != null) {
                if (a != null) throw Error(r(92));
                if (Dl(e)) {
                    if (1 < e.length) throw Error(r(93));
                    e = e[0];
                }
                a = e;
            }
            a == null && (a = ""), (t = a);
        }
        (a = et(t)), (l.defaultValue = a), (e = l.textContent), e === a && e !== "" && e !== null && (l.value = e);
    }
    function La(l, t) {
        if (t) {
            var a = l.firstChild;
            if (a && a === l.lastChild && a.nodeType === 3) {
                a.nodeValue = t;
                return;
            }
        }
        l.textContent = t;
    }
    var Kr = new Set(
        "animationIterationCount aspectRatio borderImageOutset borderImageSlice borderImageWidth boxFlex boxFlexGroup boxOrdinalGroup columnCount columns flex flexGrow flexPositive flexShrink flexNegative flexOrder gridArea gridRow gridRowEnd gridRowSpan gridRowStart gridColumn gridColumnEnd gridColumnSpan gridColumnStart fontWeight lineClamp lineHeight opacity order orphans scale tabSize widows zIndex zoom fillOpacity floodOpacity stopOpacity strokeDasharray strokeDashoffset strokeMiterlimit strokeOpacity strokeWidth MozAnimationIterationCount MozBoxFlex MozBoxFlexGroup MozLineClamp msAnimationIterationCount msFlex msZoom msFlexGrow msFlexNegative msFlexOrder msFlexPositive msFlexShrink msGridColumn msGridColumnSpan msGridRow msGridRowSpan WebkitAnimationIterationCount WebkitBoxFlex WebKitBoxFlexGroup WebkitBoxOrdinalGroup WebkitColumnCount WebkitColumns WebkitFlex WebkitFlexGrow WebkitFlexPositive WebkitFlexShrink WebkitLineClamp".split(
            " "
        )
    );
    function ji(l, t, a) {
        var e = t.indexOf("--") === 0;
        a == null || typeof a == "boolean" || a === ""
            ? e
                ? l.setProperty(t, "")
                : t === "float"
                  ? (l.cssFloat = "")
                  : (l[t] = "")
            : e
              ? l.setProperty(t, a)
              : typeof a != "number" || a === 0 || Kr.has(t)
                ? t === "float"
                    ? (l.cssFloat = a)
                    : (l[t] = ("" + a).trim())
                : (l[t] = a + "px");
    }
    function Ui(l, t, a) {
        if (t != null && typeof t != "object") throw Error(r(62));
        if (((l = l.style), a != null)) {
            for (var e in a)
                !a.hasOwnProperty(e) ||
                    (t != null && t.hasOwnProperty(e)) ||
                    (e.indexOf("--") === 0 ? l.setProperty(e, "") : e === "float" ? (l.cssFloat = "") : (l[e] = ""));
            for (var u in t) (e = t[u]), t.hasOwnProperty(u) && a[u] !== e && ji(l, u, e);
        } else for (var n in t) t.hasOwnProperty(n) && ji(l, n, t[n]);
    }
    function ac(l) {
        if (l.indexOf("-") === -1) return !1;
        switch (l) {
            case "annotation-xml":
            case "color-profile":
            case "font-face":
            case "font-face-src":
            case "font-face-uri":
            case "font-face-format":
            case "font-face-name":
            case "missing-glyph":
                return !1;
            default:
                return !0;
        }
    }
    var Jr = new Map([
            ["acceptCharset", "accept-charset"],
            ["htmlFor", "for"],
            ["httpEquiv", "http-equiv"],
            ["crossOrigin", "crossorigin"],
            ["accentHeight", "accent-height"],
            ["alignmentBaseline", "alignment-baseline"],
            ["arabicForm", "arabic-form"],
            ["baselineShift", "baseline-shift"],
            ["capHeight", "cap-height"],
            ["clipPath", "clip-path"],
            ["clipRule", "clip-rule"],
            ["colorInterpolation", "color-interpolation"],
            ["colorInterpolationFilters", "color-interpolation-filters"],
            ["colorProfile", "color-profile"],
            ["colorRendering", "color-rendering"],
            ["dominantBaseline", "dominant-baseline"],
            ["enableBackground", "enable-background"],
            ["fillOpacity", "fill-opacity"],
            ["fillRule", "fill-rule"],
            ["floodColor", "flood-color"],
            ["floodOpacity", "flood-opacity"],
            ["fontFamily", "font-family"],
            ["fontSize", "font-size"],
            ["fontSizeAdjust", "font-size-adjust"],
            ["fontStretch", "font-stretch"],
            ["fontStyle", "font-style"],
            ["fontVariant", "font-variant"],
            ["fontWeight", "font-weight"],
            ["glyphName", "glyph-name"],
            ["glyphOrientationHorizontal", "glyph-orientation-horizontal"],
            ["glyphOrientationVertical", "glyph-orientation-vertical"],
            ["horizAdvX", "horiz-adv-x"],
            ["horizOriginX", "horiz-origin-x"],
            ["imageRendering", "image-rendering"],
            ["letterSpacing", "letter-spacing"],
            ["lightingColor", "lighting-color"],
            ["markerEnd", "marker-end"],
            ["markerMid", "marker-mid"],
            ["markerStart", "marker-start"],
            ["overlinePosition", "overline-position"],
            ["overlineThickness", "overline-thickness"],
            ["paintOrder", "paint-order"],
            ["panose-1", "panose-1"],
            ["pointerEvents", "pointer-events"],
            ["renderingIntent", "rendering-intent"],
            ["shapeRendering", "shape-rendering"],
            ["stopColor", "stop-color"],
            ["stopOpacity", "stop-opacity"],
            ["strikethroughPosition", "strikethrough-position"],
            ["strikethroughThickness", "strikethrough-thickness"],
            ["strokeDasharray", "stroke-dasharray"],
            ["strokeDashoffset", "stroke-dashoffset"],
            ["strokeLinecap", "stroke-linecap"],
            ["strokeLinejoin", "stroke-linejoin"],
            ["strokeMiterlimit", "stroke-miterlimit"],
            ["strokeOpacity", "stroke-opacity"],
            ["strokeWidth", "stroke-width"],
            ["textAnchor", "text-anchor"],
            ["textDecoration", "text-decoration"],
            ["textRendering", "text-rendering"],
            ["transformOrigin", "transform-origin"],
            ["underlinePosition", "underline-position"],
            ["underlineThickness", "underline-thickness"],
            ["unicodeBidi", "unicode-bidi"],
            ["unicodeRange", "unicode-range"],
            ["unitsPerEm", "units-per-em"],
            ["vAlphabetic", "v-alphabetic"],
            ["vHanging", "v-hanging"],
            ["vIdeographic", "v-ideographic"],
            ["vMathematical", "v-mathematical"],
            ["vectorEffect", "vector-effect"],
            ["vertAdvY", "vert-adv-y"],
            ["vertOriginX", "vert-origin-x"],
            ["vertOriginY", "vert-origin-y"],
            ["wordSpacing", "word-spacing"],
            ["writingMode", "writing-mode"],
            ["xmlnsXlink", "xmlns:xlink"],
            ["xHeight", "x-height"],
        ]),
        Fr =
            /^[\u0000-\u001F ]*j[\r\n\t]*a[\r\n\t]*v[\r\n\t]*a[\r\n\t]*s[\r\n\t]*c[\r\n\t]*r[\r\n\t]*i[\r\n\t]*p[\r\n\t]*t[\r\n\t]*:/i;
    function ju(l) {
        return Fr.test("" + l)
            ? "javascript:throw new Error('React has blocked a javascript: URL as a security precaution.')"
            : l;
    }
    var ec = null;
    function uc(l) {
        return (
            (l = l.target || l.srcElement || window),
            l.correspondingUseElement && (l = l.correspondingUseElement),
            l.nodeType === 3 ? l.parentNode : l
        );
    }
    var wa = null,
        Ka = null;
    function Ri(l) {
        var t = Ga(l);
        if (t && (l = t.stateNode)) {
            var a = l[Gl] || null;
            l: switch (((l = t.stateNode), t.type)) {
                case "input":
                    if (
                        (lc(l, a.value, a.defaultValue, a.defaultValue, a.checked, a.defaultChecked, a.type, a.name),
                        (t = a.name),
                        a.type === "radio" && t != null)
                    ) {
                        for (a = l; a.parentNode; ) a = a.parentNode;
                        for (
                            a = a.querySelectorAll('input[name="' + ut("" + t) + '"][type="radio"]'), t = 0;
                            t < a.length;
                            t++
                        ) {
                            var e = a[t];
                            if (e !== l && e.form === l.form) {
                                var u = e[Gl] || null;
                                if (!u) throw Error(r(90));
                                lc(
                                    e,
                                    u.value,
                                    u.defaultValue,
                                    u.defaultValue,
                                    u.checked,
                                    u.defaultChecked,
                                    u.type,
                                    u.name
                                );
                            }
                        }
                        for (t = 0; t < a.length; t++) (e = a[t]), e.form === l.form && Mi(e);
                    }
                    break l;
                case "textarea":
                    _i(l, a.value, a.defaultValue);
                    break l;
                case "select":
                    (t = a.value), t != null && Va(l, !!a.multiple, t, !1);
            }
        }
    }
    var nc = !1;
    function Hi(l, t, a) {
        if (nc) return l(t, a);
        nc = !0;
        try {
            var e = l(t);
            return e;
        } finally {
            if (
                ((nc = !1),
                (wa !== null || Ka !== null) && (gn(), wa && ((t = wa), (l = Ka), (Ka = wa = null), Ri(t), l)))
            )
                for (t = 0; t < l.length; t++) Ri(l[t]);
        }
    }
    function Me(l, t) {
        var a = l.stateNode;
        if (a === null) return null;
        var e = a[Gl] || null;
        if (e === null) return null;
        a = e[t];
        l: switch (t) {
            case "onClick":
            case "onClickCapture":
            case "onDoubleClick":
            case "onDoubleClickCapture":
            case "onMouseDown":
            case "onMouseDownCapture":
            case "onMouseMove":
            case "onMouseMoveCapture":
            case "onMouseUp":
            case "onMouseUpCapture":
            case "onMouseEnter":
                (e = !e.disabled) ||
                    ((l = l.type), (e = !(l === "button" || l === "input" || l === "select" || l === "textarea"))),
                    (l = !e);
                break l;
            default:
                l = !1;
        }
        if (l) return null;
        if (a && typeof a != "function") throw Error(r(231, t, typeof a));
        return a;
    }
    var _t = !(typeof window > "u" || typeof window.document > "u" || typeof window.document.createElement > "u"),
        cc = !1;
    if (_t)
        try {
            var Ne = {};
            Object.defineProperty(Ne, "passive", {
                get: function () {
                    cc = !0;
                },
            }),
                window.addEventListener("test", Ne, Ne),
                window.removeEventListener("test", Ne, Ne);
        } catch {
            cc = !1;
        }
    var Kt = null,
        fc = null,
        Uu = null;
    function Bi() {
        if (Uu) return Uu;
        var l,
            t = fc,
            a = t.length,
            e,
            u = "value" in Kt ? Kt.value : Kt.textContent,
            n = u.length;
        for (l = 0; l < a && t[l] === u[l]; l++);
        var c = a - l;
        for (e = 1; e <= c && t[a - e] === u[n - e]; e++);
        return (Uu = u.slice(l, 1 < e ? 1 - e : void 0));
    }
    function Ru(l) {
        var t = l.keyCode;
        return (
            "charCode" in l ? ((l = l.charCode), l === 0 && t === 13 && (l = 13)) : (l = t),
            l === 10 && (l = 13),
            32 <= l || l === 13 ? l : 0
        );
    }
    function Hu() {
        return !0;
    }
    function Ci() {
        return !1;
    }
    function Xl(l) {
        function t(a, e, u, n, c) {
            (this._reactName = a),
                (this._targetInst = u),
                (this.type = e),
                (this.nativeEvent = n),
                (this.target = c),
                (this.currentTarget = null);
            for (var f in l) l.hasOwnProperty(f) && ((a = l[f]), (this[f] = a ? a(n) : n[f]));
            return (
                (this.isDefaultPrevented = (n.defaultPrevented != null ? n.defaultPrevented : n.returnValue === !1)
                    ? Hu
                    : Ci),
                (this.isPropagationStopped = Ci),
                this
            );
        }
        return (
            B(t.prototype, {
                preventDefault: function () {
                    this.defaultPrevented = !0;
                    var a = this.nativeEvent;
                    a &&
                        (a.preventDefault
                            ? a.preventDefault()
                            : typeof a.returnValue != "unknown" && (a.returnValue = !1),
                        (this.isDefaultPrevented = Hu));
                },
                stopPropagation: function () {
                    var a = this.nativeEvent;
                    a &&
                        (a.stopPropagation
                            ? a.stopPropagation()
                            : typeof a.cancelBubble != "unknown" && (a.cancelBubble = !0),
                        (this.isPropagationStopped = Hu));
                },
                persist: function () {},
                isPersistent: Hu,
            }),
            t
        );
    }
    var Sa = {
            eventPhase: 0,
            bubbles: 0,
            cancelable: 0,
            timeStamp: function (l) {
                return l.timeStamp || Date.now();
            },
            defaultPrevented: 0,
            isTrusted: 0,
        },
        Bu = Xl(Sa),
        _e = B({}, Sa, { view: 0, detail: 0 }),
        Wr = Xl(_e),
        ic,
        sc,
        De,
        Cu = B({}, _e, {
            screenX: 0,
            screenY: 0,
            clientX: 0,
            clientY: 0,
            pageX: 0,
            pageY: 0,
            ctrlKey: 0,
            shiftKey: 0,
            altKey: 0,
            metaKey: 0,
            getModifierState: oc,
            button: 0,
            buttons: 0,
            relatedTarget: function (l) {
                return l.relatedTarget === void 0
                    ? l.fromElement === l.srcElement
                        ? l.toElement
                        : l.fromElement
                    : l.relatedTarget;
            },
            movementX: function (l) {
                return "movementX" in l
                    ? l.movementX
                    : (l !== De &&
                          (De && l.type === "mousemove"
                              ? ((ic = l.screenX - De.screenX), (sc = l.screenY - De.screenY))
                              : (sc = ic = 0),
                          (De = l)),
                      ic);
            },
            movementY: function (l) {
                return "movementY" in l ? l.movementY : sc;
            },
        }),
        qi = Xl(Cu),
        $r = B({}, Cu, { dataTransfer: 0 }),
        kr = Xl($r),
        Pr = B({}, _e, { relatedTarget: 0 }),
        rc = Xl(Pr),
        Ir = B({}, Sa, { animationName: 0, elapsedTime: 0, pseudoElement: 0 }),
        lo = Xl(Ir),
        to = B({}, Sa, {
            clipboardData: function (l) {
                return "clipboardData" in l ? l.clipboardData : window.clipboardData;
            },
        }),
        ao = Xl(to),
        eo = B({}, Sa, { data: 0 }),
        Yi = Xl(eo),
        uo = {
            Esc: "Escape",
            Spacebar: " ",
            Left: "ArrowLeft",
            Up: "ArrowUp",
            Right: "ArrowRight",
            Down: "ArrowDown",
            Del: "Delete",
            Win: "OS",
            Menu: "ContextMenu",
            Apps: "ContextMenu",
            Scroll: "ScrollLock",
            MozPrintableKey: "Unidentified",
        },
        no = {
            8: "Backspace",
            9: "Tab",
            12: "Clear",
            13: "Enter",
            16: "Shift",
            17: "Control",
            18: "Alt",
            19: "Pause",
            20: "CapsLock",
            27: "Escape",
            32: " ",
            33: "PageUp",
            34: "PageDown",
            35: "End",
            36: "Home",
            37: "ArrowLeft",
            38: "ArrowUp",
            39: "ArrowRight",
            40: "ArrowDown",
            45: "Insert",
            46: "Delete",
            112: "F1",
            113: "F2",
            114: "F3",
            115: "F4",
            116: "F5",
            117: "F6",
            118: "F7",
            119: "F8",
            120: "F9",
            121: "F10",
            122: "F11",
            123: "F12",
            144: "NumLock",
            145: "ScrollLock",
            224: "Meta",
        },
        co = { Alt: "altKey", Control: "ctrlKey", Meta: "metaKey", Shift: "shiftKey" };
    function fo(l) {
        var t = this.nativeEvent;
        return t.getModifierState ? t.getModifierState(l) : (l = co[l]) ? !!t[l] : !1;
    }
    function oc() {
        return fo;
    }
    var io = B({}, _e, {
            key: function (l) {
                if (l.key) {
                    var t = uo[l.key] || l.key;
                    if (t !== "Unidentified") return t;
                }
                return l.type === "keypress"
                    ? ((l = Ru(l)), l === 13 ? "Enter" : String.fromCharCode(l))
                    : l.type === "keydown" || l.type === "keyup"
                      ? no[l.keyCode] || "Unidentified"
                      : "";
            },
            code: 0,
            location: 0,
            ctrlKey: 0,
            shiftKey: 0,
            altKey: 0,
            metaKey: 0,
            repeat: 0,
            locale: 0,
            getModifierState: oc,
            charCode: function (l) {
                return l.type === "keypress" ? Ru(l) : 0;
            },
            keyCode: function (l) {
                return l.type === "keydown" || l.type === "keyup" ? l.keyCode : 0;
            },
            which: function (l) {
                return l.type === "keypress" ? Ru(l) : l.type === "keydown" || l.type === "keyup" ? l.keyCode : 0;
            },
        }),
        so = Xl(io),
        ro = B({}, Cu, {
            pointerId: 0,
            width: 0,
            height: 0,
            pressure: 0,
            tangentialPressure: 0,
            tiltX: 0,
            tiltY: 0,
            twist: 0,
            pointerType: 0,
            isPrimary: 0,
        }),
        Gi = Xl(ro),
        oo = B({}, _e, {
            touches: 0,
            targetTouches: 0,
            changedTouches: 0,
            altKey: 0,
            metaKey: 0,
            ctrlKey: 0,
            shiftKey: 0,
            getModifierState: oc,
        }),
        ho = Xl(oo),
        vo = B({}, Sa, { propertyName: 0, elapsedTime: 0, pseudoElement: 0 }),
        yo = Xl(vo),
        mo = B({}, Cu, {
            deltaX: function (l) {
                return "deltaX" in l ? l.deltaX : "wheelDeltaX" in l ? -l.wheelDeltaX : 0;
            },
            deltaY: function (l) {
                return "deltaY" in l
                    ? l.deltaY
                    : "wheelDeltaY" in l
                      ? -l.wheelDeltaY
                      : "wheelDelta" in l
                        ? -l.wheelDelta
                        : 0;
            },
            deltaZ: 0,
            deltaMode: 0,
        }),
        go = Xl(mo),
        bo = B({}, Sa, { newState: 0, oldState: 0 }),
        So = Xl(bo),
        xo = [9, 13, 27, 32],
        dc = _t && "CompositionEvent" in window,
        je = null;
    _t && "documentMode" in document && (je = document.documentMode);
    var To = _t && "TextEvent" in window && !je,
        Xi = _t && (!dc || (je && 8 < je && 11 >= je)),
        Qi = " ",
        Zi = !1;
    function Vi(l, t) {
        switch (l) {
            case "keyup":
                return xo.indexOf(t.keyCode) !== -1;
            case "keydown":
                return t.keyCode !== 229;
            case "keypress":
            case "mousedown":
            case "focusout":
                return !0;
            default:
                return !1;
        }
    }
    function Li(l) {
        return (l = l.detail), typeof l == "object" && "data" in l ? l.data : null;
    }
    var Ja = !1;
    function Eo(l, t) {
        switch (l) {
            case "compositionend":
                return Li(t);
            case "keypress":
                return t.which !== 32 ? null : ((Zi = !0), Qi);
            case "textInput":
                return (l = t.data), l === Qi && Zi ? null : l;
            default:
                return null;
        }
    }
    function po(l, t) {
        if (Ja)
            return l === "compositionend" || (!dc && Vi(l, t))
                ? ((l = Bi()), (Uu = fc = Kt = null), (Ja = !1), l)
                : null;
        switch (l) {
            case "paste":
                return null;
            case "keypress":
                if (!(t.ctrlKey || t.altKey || t.metaKey) || (t.ctrlKey && t.altKey)) {
                    if (t.char && 1 < t.char.length) return t.char;
                    if (t.which) return String.fromCharCode(t.which);
                }
                return null;
            case "compositionend":
                return Xi && t.locale !== "ko" ? null : t.data;
            default:
                return null;
        }
    }
    var Ao = {
        color: !0,
        date: !0,
        datetime: !0,
        "datetime-local": !0,
        email: !0,
        month: !0,
        number: !0,
        password: !0,
        range: !0,
        search: !0,
        tel: !0,
        text: !0,
        time: !0,
        url: !0,
        week: !0,
    };
    function wi(l) {
        var t = l && l.nodeName && l.nodeName.toLowerCase();
        return t === "input" ? !!Ao[l.type] : t === "textarea";
    }
    function Ki(l, t, a, e) {
        wa ? (Ka ? Ka.push(e) : (Ka = [e])) : (wa = e),
            (t = pn(t, "onChange")),
            0 < t.length && ((a = new Bu("onChange", "change", null, a, e)), l.push({ event: a, listeners: t }));
    }
    var Ue = null,
        Re = null;
    function zo(l) {
        O1(l, 0);
    }
    function qu(l) {
        var t = Oe(l);
        if (Mi(t)) return l;
    }
    function Ji(l, t) {
        if (l === "change") return t;
    }
    var Fi = !1;
    if (_t) {
        var hc;
        if (_t) {
            var vc = "oninput" in document;
            if (!vc) {
                var Wi = document.createElement("div");
                Wi.setAttribute("oninput", "return;"), (vc = typeof Wi.oninput == "function");
            }
            hc = vc;
        } else hc = !1;
        Fi = hc && (!document.documentMode || 9 < document.documentMode);
    }
    function $i() {
        Ue && (Ue.detachEvent("onpropertychange", ki), (Re = Ue = null));
    }
    function ki(l) {
        if (l.propertyName === "value" && qu(Re)) {
            var t = [];
            Ki(t, Re, l, uc(l)), Hi(zo, t);
        }
    }
    function Oo(l, t, a) {
        l === "focusin" ? ($i(), (Ue = t), (Re = a), Ue.attachEvent("onpropertychange", ki)) : l === "focusout" && $i();
    }
    function Mo(l) {
        if (l === "selectionchange" || l === "keyup" || l === "keydown") return qu(Re);
    }
    function No(l, t) {
        if (l === "click") return qu(t);
    }
    function _o(l, t) {
        if (l === "input" || l === "change") return qu(t);
    }
    function Do(l, t) {
        return (l === t && (l !== 0 || 1 / l === 1 / t)) || (l !== l && t !== t);
    }
    var $l = typeof Object.is == "function" ? Object.is : Do;
    function He(l, t) {
        if ($l(l, t)) return !0;
        if (typeof l != "object" || l === null || typeof t != "object" || t === null) return !1;
        var a = Object.keys(l),
            e = Object.keys(t);
        if (a.length !== e.length) return !1;
        for (e = 0; e < a.length; e++) {
            var u = a[e];
            if (!Vn.call(t, u) || !$l(l[u], t[u])) return !1;
        }
        return !0;
    }
    function Pi(l) {
        for (; l && l.firstChild; ) l = l.firstChild;
        return l;
    }
    function Ii(l, t) {
        var a = Pi(l);
        l = 0;
        for (var e; a; ) {
            if (a.nodeType === 3) {
                if (((e = l + a.textContent.length), l <= t && e >= t)) return { node: a, offset: t - l };
                l = e;
            }
            l: {
                for (; a; ) {
                    if (a.nextSibling) {
                        a = a.nextSibling;
                        break l;
                    }
                    a = a.parentNode;
                }
                a = void 0;
            }
            a = Pi(a);
        }
    }
    function l0(l, t) {
        return l && t
            ? l === t
                ? !0
                : l && l.nodeType === 3
                  ? !1
                  : t && t.nodeType === 3
                    ? l0(l, t.parentNode)
                    : "contains" in l
                      ? l.contains(t)
                      : l.compareDocumentPosition
                        ? !!(l.compareDocumentPosition(t) & 16)
                        : !1
            : !1;
    }
    function t0(l) {
        l =
            l != null && l.ownerDocument != null && l.ownerDocument.defaultView != null
                ? l.ownerDocument.defaultView
                : window;
        for (var t = Du(l.document); t instanceof l.HTMLIFrameElement; ) {
            try {
                var a = typeof t.contentWindow.location.href == "string";
            } catch {
                a = !1;
            }
            if (a) l = t.contentWindow;
            else break;
            t = Du(l.document);
        }
        return t;
    }
    function yc(l) {
        var t = l && l.nodeName && l.nodeName.toLowerCase();
        return (
            t &&
            ((t === "input" &&
                (l.type === "text" ||
                    l.type === "search" ||
                    l.type === "tel" ||
                    l.type === "url" ||
                    l.type === "password")) ||
                t === "textarea" ||
                l.contentEditable === "true")
        );
    }
    var jo = _t && "documentMode" in document && 11 >= document.documentMode,
        Fa = null,
        mc = null,
        Be = null,
        gc = !1;
    function a0(l, t, a) {
        var e = a.window === a ? a.document : a.nodeType === 9 ? a : a.ownerDocument;
        gc ||
            Fa == null ||
            Fa !== Du(e) ||
            ((e = Fa),
            "selectionStart" in e && yc(e)
                ? (e = { start: e.selectionStart, end: e.selectionEnd })
                : ((e = ((e.ownerDocument && e.ownerDocument.defaultView) || window).getSelection()),
                  (e = {
                      anchorNode: e.anchorNode,
                      anchorOffset: e.anchorOffset,
                      focusNode: e.focusNode,
                      focusOffset: e.focusOffset,
                  })),
            (Be && He(Be, e)) ||
                ((Be = e),
                (e = pn(mc, "onSelect")),
                0 < e.length &&
                    ((t = new Bu("onSelect", "select", null, t, a)),
                    l.push({ event: t, listeners: e }),
                    (t.target = Fa))));
    }
    function xa(l, t) {
        var a = {};
        return (a[l.toLowerCase()] = t.toLowerCase()), (a["Webkit" + l] = "webkit" + t), (a["Moz" + l] = "moz" + t), a;
    }
    var Wa = {
            animationend: xa("Animation", "AnimationEnd"),
            animationiteration: xa("Animation", "AnimationIteration"),
            animationstart: xa("Animation", "AnimationStart"),
            transitionrun: xa("Transition", "TransitionRun"),
            transitionstart: xa("Transition", "TransitionStart"),
            transitioncancel: xa("Transition", "TransitionCancel"),
            transitionend: xa("Transition", "TransitionEnd"),
        },
        bc = {},
        e0 = {};
    _t &&
        ((e0 = document.createElement("div").style),
        "AnimationEvent" in window ||
            (delete Wa.animationend.animation,
            delete Wa.animationiteration.animation,
            delete Wa.animationstart.animation),
        "TransitionEvent" in window || delete Wa.transitionend.transition);
    function Ta(l) {
        if (bc[l]) return bc[l];
        if (!Wa[l]) return l;
        var t = Wa[l],
            a;
        for (a in t) if (t.hasOwnProperty(a) && a in e0) return (bc[l] = t[a]);
        return l;
    }
    var u0 = Ta("animationend"),
        n0 = Ta("animationiteration"),
        c0 = Ta("animationstart"),
        Uo = Ta("transitionrun"),
        Ro = Ta("transitionstart"),
        Ho = Ta("transitioncancel"),
        f0 = Ta("transitionend"),
        i0 = new Map(),
        Sc =
            "abort auxClick beforeToggle cancel canPlay canPlayThrough click close contextMenu copy cut drag dragEnd dragEnter dragExit dragLeave dragOver dragStart drop durationChange emptied encrypted ended error gotPointerCapture input invalid keyDown keyPress keyUp load loadedData loadedMetadata loadStart lostPointerCapture mouseDown mouseMove mouseOut mouseOver mouseUp paste pause play playing pointerCancel pointerDown pointerMove pointerOut pointerOver pointerUp progress rateChange reset resize seeked seeking stalled submit suspend timeUpdate touchCancel touchEnd touchStart volumeChange scroll toggle touchMove waiting wheel".split(
                " "
            );
    Sc.push("scrollEnd");
    function mt(l, t) {
        i0.set(l, t), ba(t, [l]);
    }
    var s0 = new WeakMap();
    function nt(l, t) {
        if (typeof l == "object" && l !== null) {
            var a = s0.get(l);
            return a !== void 0 ? a : ((t = { value: l, source: t, stack: zi(t) }), s0.set(l, t), t);
        }
        return { value: l, source: t, stack: zi(t) };
    }
    var ct = [],
        $a = 0,
        xc = 0;
    function Yu() {
        for (var l = $a, t = (xc = $a = 0); t < l; ) {
            var a = ct[t];
            ct[t++] = null;
            var e = ct[t];
            ct[t++] = null;
            var u = ct[t];
            ct[t++] = null;
            var n = ct[t];
            if (((ct[t++] = null), e !== null && u !== null)) {
                var c = e.pending;
                c === null ? (u.next = u) : ((u.next = c.next), (c.next = u)), (e.pending = u);
            }
            n !== 0 && r0(a, u, n);
        }
    }
    function Gu(l, t, a, e) {
        (ct[$a++] = l),
            (ct[$a++] = t),
            (ct[$a++] = a),
            (ct[$a++] = e),
            (xc |= e),
            (l.lanes |= e),
            (l = l.alternate),
            l !== null && (l.lanes |= e);
    }
    function Tc(l, t, a, e) {
        return Gu(l, t, a, e), Xu(l);
    }
    function ka(l, t) {
        return Gu(l, null, null, t), Xu(l);
    }
    function r0(l, t, a) {
        l.lanes |= a;
        var e = l.alternate;
        e !== null && (e.lanes |= a);
        for (var u = !1, n = l.return; n !== null; )
            (n.childLanes |= a),
                (e = n.alternate),
                e !== null && (e.childLanes |= a),
                n.tag === 22 && ((l = n.stateNode), l === null || l._visibility & 1 || (u = !0)),
                (l = n),
                (n = n.return);
        return l.tag === 3
            ? ((n = l.stateNode),
              u &&
                  t !== null &&
                  ((u = 31 - Wl(a)),
                  (l = n.hiddenUpdates),
                  (e = l[u]),
                  e === null ? (l[u] = [t]) : e.push(t),
                  (t.lane = a | 536870912)),
              n)
            : null;
    }
    function Xu(l) {
        if (50 < cu) throw ((cu = 0), (Nf = null), Error(r(185)));
        for (var t = l.return; t !== null; ) (l = t), (t = l.return);
        return l.tag === 3 ? l.stateNode : null;
    }
    var Pa = {};
    function Bo(l, t, a, e) {
        (this.tag = l),
            (this.key = a),
            (this.sibling = this.child = this.return = this.stateNode = this.type = this.elementType = null),
            (this.index = 0),
            (this.refCleanup = this.ref = null),
            (this.pendingProps = t),
            (this.dependencies = this.memoizedState = this.updateQueue = this.memoizedProps = null),
            (this.mode = e),
            (this.subtreeFlags = this.flags = 0),
            (this.deletions = null),
            (this.childLanes = this.lanes = 0),
            (this.alternate = null);
    }
    function kl(l, t, a, e) {
        return new Bo(l, t, a, e);
    }
    function Ec(l) {
        return (l = l.prototype), !(!l || !l.isReactComponent);
    }
    function Dt(l, t) {
        var a = l.alternate;
        return (
            a === null
                ? ((a = kl(l.tag, t, l.key, l.mode)),
                  (a.elementType = l.elementType),
                  (a.type = l.type),
                  (a.stateNode = l.stateNode),
                  (a.alternate = l),
                  (l.alternate = a))
                : ((a.pendingProps = t), (a.type = l.type), (a.flags = 0), (a.subtreeFlags = 0), (a.deletions = null)),
            (a.flags = l.flags & 65011712),
            (a.childLanes = l.childLanes),
            (a.lanes = l.lanes),
            (a.child = l.child),
            (a.memoizedProps = l.memoizedProps),
            (a.memoizedState = l.memoizedState),
            (a.updateQueue = l.updateQueue),
            (t = l.dependencies),
            (a.dependencies = t === null ? null : { lanes: t.lanes, firstContext: t.firstContext }),
            (a.sibling = l.sibling),
            (a.index = l.index),
            (a.ref = l.ref),
            (a.refCleanup = l.refCleanup),
            a
        );
    }
    function o0(l, t) {
        l.flags &= 65011714;
        var a = l.alternate;
        return (
            a === null
                ? ((l.childLanes = 0),
                  (l.lanes = t),
                  (l.child = null),
                  (l.subtreeFlags = 0),
                  (l.memoizedProps = null),
                  (l.memoizedState = null),
                  (l.updateQueue = null),
                  (l.dependencies = null),
                  (l.stateNode = null))
                : ((l.childLanes = a.childLanes),
                  (l.lanes = a.lanes),
                  (l.child = a.child),
                  (l.subtreeFlags = 0),
                  (l.deletions = null),
                  (l.memoizedProps = a.memoizedProps),
                  (l.memoizedState = a.memoizedState),
                  (l.updateQueue = a.updateQueue),
                  (l.type = a.type),
                  (t = a.dependencies),
                  (l.dependencies = t === null ? null : { lanes: t.lanes, firstContext: t.firstContext })),
            l
        );
    }
    function Qu(l, t, a, e, u, n) {
        var c = 0;
        if (((e = l), typeof l == "function")) Ec(l) && (c = 1);
        else if (typeof l == "string")
            c = qd(l, a, C.current) ? 26 : l === "html" || l === "head" || l === "body" ? 27 : 5;
        else
            l: switch (l) {
                case St:
                    return (l = kl(31, a, t, u)), (l.elementType = St), (l.lanes = n), l;
                case Bl:
                    return Ea(a.children, u, n, t);
                case vt:
                    (c = 8), (u |= 24);
                    break;
                case Yl:
                    return (l = kl(12, a, t, u | 2)), (l.elementType = Yl), (l.lanes = n), l;
                case $:
                    return (l = kl(13, a, t, u)), (l.elementType = $), (l.lanes = n), l;
                case Ll:
                    return (l = kl(19, a, t, u)), (l.elementType = Ll), (l.lanes = n), l;
                default:
                    if (typeof l == "object" && l !== null)
                        switch (l.$$typeof) {
                            case va:
                            case Nl:
                                c = 10;
                                break l;
                            case Ot:
                                c = 9;
                                break l;
                            case yt:
                                c = 11;
                                break l;
                            case wl:
                                c = 14;
                                break l;
                            case Kl:
                                (c = 16), (e = null);
                                break l;
                        }
                    (c = 29), (a = Error(r(130, l === null ? "null" : typeof l, ""))), (e = null);
            }
        return (t = kl(c, a, t, u)), (t.elementType = l), (t.type = e), (t.lanes = n), t;
    }
    function Ea(l, t, a, e) {
        return (l = kl(7, l, e, t)), (l.lanes = a), l;
    }
    function pc(l, t, a) {
        return (l = kl(6, l, null, t)), (l.lanes = a), l;
    }
    function Ac(l, t, a) {
        return (
            (t = kl(4, l.children !== null ? l.children : [], l.key, t)),
            (t.lanes = a),
            (t.stateNode = { containerInfo: l.containerInfo, pendingChildren: null, implementation: l.implementation }),
            t
        );
    }
    var Ia = [],
        le = 0,
        Zu = null,
        Vu = 0,
        ft = [],
        it = 0,
        pa = null,
        jt = 1,
        Ut = "";
    function Aa(l, t) {
        (Ia[le++] = Vu), (Ia[le++] = Zu), (Zu = l), (Vu = t);
    }
    function d0(l, t, a) {
        (ft[it++] = jt), (ft[it++] = Ut), (ft[it++] = pa), (pa = l);
        var e = jt;
        l = Ut;
        var u = 32 - Wl(e) - 1;
        (e &= ~(1 << u)), (a += 1);
        var n = 32 - Wl(t) + u;
        if (30 < n) {
            var c = u - (u % 5);
            (n = (e & ((1 << c) - 1)).toString(32)),
                (e >>= c),
                (u -= c),
                (jt = (1 << (32 - Wl(t) + u)) | (a << u) | e),
                (Ut = n + l);
        } else (jt = (1 << n) | (a << u) | e), (Ut = l);
    }
    function zc(l) {
        l.return !== null && (Aa(l, 1), d0(l, 1, 0));
    }
    function Oc(l) {
        for (; l === Zu; ) (Zu = Ia[--le]), (Ia[le] = null), (Vu = Ia[--le]), (Ia[le] = null);
        for (; l === pa; )
            (pa = ft[--it]), (ft[it] = null), (Ut = ft[--it]), (ft[it] = null), (jt = ft[--it]), (ft[it] = null);
    }
    var Cl = null,
        hl = null,
        I = !1,
        za = null,
        Tt = !1,
        Mc = Error(r(519));
    function Oa(l) {
        var t = Error(r(418, ""));
        throw (Ye(nt(t, l)), Mc);
    }
    function h0(l) {
        var t = l.stateNode,
            a = l.type,
            e = l.memoizedProps;
        switch (((t[jl] = l), (t[Gl] = e), a)) {
            case "dialog":
                J("cancel", t), J("close", t);
                break;
            case "iframe":
            case "object":
            case "embed":
                J("load", t);
                break;
            case "video":
            case "audio":
                for (a = 0; a < iu.length; a++) J(iu[a], t);
                break;
            case "source":
                J("error", t);
                break;
            case "img":
            case "image":
            case "link":
                J("error", t), J("load", t);
                break;
            case "details":
                J("toggle", t);
                break;
            case "input":
                J("invalid", t), Ni(t, e.value, e.defaultValue, e.checked, e.defaultChecked, e.type, e.name, !0), _u(t);
                break;
            case "select":
                J("invalid", t);
                break;
            case "textarea":
                J("invalid", t), Di(t, e.value, e.defaultValue, e.children), _u(t);
        }
        (a = e.children),
            (typeof a != "string" && typeof a != "number" && typeof a != "bigint") ||
            t.textContent === "" + a ||
            e.suppressHydrationWarning === !0 ||
            D1(t.textContent, a)
                ? (e.popover != null && (J("beforetoggle", t), J("toggle", t)),
                  e.onScroll != null && J("scroll", t),
                  e.onScrollEnd != null && J("scrollend", t),
                  e.onClick != null && (t.onclick = An),
                  (t = !0))
                : (t = !1),
            t || Oa(l);
    }
    function v0(l) {
        for (Cl = l.return; Cl; )
            switch (Cl.tag) {
                case 5:
                case 13:
                    Tt = !1;
                    return;
                case 27:
                case 3:
                    Tt = !0;
                    return;
                default:
                    Cl = Cl.return;
            }
    }
    function Ce(l) {
        if (l !== Cl) return !1;
        if (!I) return v0(l), (I = !0), !1;
        var t = l.tag,
            a;
        if (
            ((a = t !== 3 && t !== 27) &&
                ((a = t === 5) &&
                    ((a = l.type), (a = !(a !== "form" && a !== "button") || Lf(l.type, l.memoizedProps))),
                (a = !a)),
            a && hl && Oa(l),
            v0(l),
            t === 13)
        ) {
            if (((l = l.memoizedState), (l = l !== null ? l.dehydrated : null), !l)) throw Error(r(317));
            l: {
                for (l = l.nextSibling, t = 0; l; ) {
                    if (l.nodeType === 8)
                        if (((a = l.data), a === "/$")) {
                            if (t === 0) {
                                hl = bt(l.nextSibling);
                                break l;
                            }
                            t--;
                        } else (a !== "$" && a !== "$!" && a !== "$?") || t++;
                    l = l.nextSibling;
                }
                hl = null;
            }
        } else
            t === 27
                ? ((t = hl), ia(l.type) ? ((l = Ff), (Ff = null), (hl = l)) : (hl = t))
                : (hl = Cl ? bt(l.stateNode.nextSibling) : null);
        return !0;
    }
    function qe() {
        (hl = Cl = null), (I = !1);
    }
    function y0() {
        var l = za;
        return l !== null && (Vl === null ? (Vl = l) : Vl.push.apply(Vl, l), (za = null)), l;
    }
    function Ye(l) {
        za === null ? (za = [l]) : za.push(l);
    }
    var Nc = O(null),
        Ma = null,
        Rt = null;
    function Jt(l, t, a) {
        N(Nc, t._currentValue), (t._currentValue = a);
    }
    function Ht(l) {
        (l._currentValue = Nc.current), j(Nc);
    }
    function _c(l, t, a) {
        for (; l !== null; ) {
            var e = l.alternate;
            if (
                ((l.childLanes & t) !== t
                    ? ((l.childLanes |= t), e !== null && (e.childLanes |= t))
                    : e !== null && (e.childLanes & t) !== t && (e.childLanes |= t),
                l === a)
            )
                break;
            l = l.return;
        }
    }
    function Dc(l, t, a, e) {
        var u = l.child;
        for (u !== null && (u.return = l); u !== null; ) {
            var n = u.dependencies;
            if (n !== null) {
                var c = u.child;
                n = n.firstContext;
                l: for (; n !== null; ) {
                    var f = n;
                    n = u;
                    for (var i = 0; i < t.length; i++)
                        if (f.context === t[i]) {
                            (n.lanes |= a),
                                (f = n.alternate),
                                f !== null && (f.lanes |= a),
                                _c(n.return, a, l),
                                e || (c = null);
                            break l;
                        }
                    n = f.next;
                }
            } else if (u.tag === 18) {
                if (((c = u.return), c === null)) throw Error(r(341));
                (c.lanes |= a), (n = c.alternate), n !== null && (n.lanes |= a), _c(c, a, l), (c = null);
            } else c = u.child;
            if (c !== null) c.return = u;
            else
                for (c = u; c !== null; ) {
                    if (c === l) {
                        c = null;
                        break;
                    }
                    if (((u = c.sibling), u !== null)) {
                        (u.return = c.return), (c = u);
                        break;
                    }
                    c = c.return;
                }
            u = c;
        }
    }
    function Ge(l, t, a, e) {
        l = null;
        for (var u = t, n = !1; u !== null; ) {
            if (!n) {
                if ((u.flags & 524288) !== 0) n = !0;
                else if ((u.flags & 262144) !== 0) break;
            }
            if (u.tag === 10) {
                var c = u.alternate;
                if (c === null) throw Error(r(387));
                if (((c = c.memoizedProps), c !== null)) {
                    var f = u.type;
                    $l(u.pendingProps.value, c.value) || (l !== null ? l.push(f) : (l = [f]));
                }
            } else if (u === Jl.current) {
                if (((c = u.alternate), c === null)) throw Error(r(387));
                c.memoizedState.memoizedState !== u.memoizedState.memoizedState &&
                    (l !== null ? l.push(vu) : (l = [vu]));
            }
            u = u.return;
        }
        l !== null && Dc(t, l, a, e), (t.flags |= 262144);
    }
    function Lu(l) {
        for (l = l.firstContext; l !== null; ) {
            if (!$l(l.context._currentValue, l.memoizedValue)) return !0;
            l = l.next;
        }
        return !1;
    }
    function Na(l) {
        (Ma = l), (Rt = null), (l = l.dependencies), l !== null && (l.firstContext = null);
    }
    function Ul(l) {
        return m0(Ma, l);
    }
    function wu(l, t) {
        return Ma === null && Na(l), m0(l, t);
    }
    function m0(l, t) {
        var a = t._currentValue;
        if (((t = { context: t, memoizedValue: a, next: null }), Rt === null)) {
            if (l === null) throw Error(r(308));
            (Rt = t), (l.dependencies = { lanes: 0, firstContext: t }), (l.flags |= 524288);
        } else Rt = Rt.next = t;
        return a;
    }
    var Co =
            typeof AbortController < "u"
                ? AbortController
                : function () {
                      var l = [],
                          t = (this.signal = {
                              aborted: !1,
                              addEventListener: function (a, e) {
                                  l.push(e);
                              },
                          });
                      this.abort = function () {
                          (t.aborted = !0),
                              l.forEach(function (a) {
                                  return a();
                              });
                      };
                  },
        qo = s.unstable_scheduleCallback,
        Yo = s.unstable_NormalPriority,
        Sl = {
            $$typeof: Nl,
            Consumer: null,
            Provider: null,
            _currentValue: null,
            _currentValue2: null,
            _threadCount: 0,
        };
    function jc() {
        return { controller: new Co(), data: new Map(), refCount: 0 };
    }
    function Xe(l) {
        l.refCount--,
            l.refCount === 0 &&
                qo(Yo, function () {
                    l.controller.abort();
                });
    }
    var Qe = null,
        Uc = 0,
        te = 0,
        ae = null;
    function Go(l, t) {
        if (Qe === null) {
            var a = (Qe = []);
            (Uc = 0),
                (te = Bf()),
                (ae = {
                    status: "pending",
                    value: void 0,
                    then: function (e) {
                        a.push(e);
                    },
                });
        }
        return Uc++, t.then(g0, g0), t;
    }
    function g0() {
        if (--Uc === 0 && Qe !== null) {
            ae !== null && (ae.status = "fulfilled");
            var l = Qe;
            (Qe = null), (te = 0), (ae = null);
            for (var t = 0; t < l.length; t++) (0, l[t])();
        }
    }
    function Xo(l, t) {
        var a = [],
            e = {
                status: "pending",
                value: null,
                reason: null,
                then: function (u) {
                    a.push(u);
                },
            };
        return (
            l.then(
                function () {
                    (e.status = "fulfilled"), (e.value = t);
                    for (var u = 0; u < a.length; u++) (0, a[u])(t);
                },
                function (u) {
                    for (e.status = "rejected", e.reason = u, u = 0; u < a.length; u++) (0, a[u])(void 0);
                }
            ),
            e
        );
    }
    var b0 = E.S;
    E.S = function (l, t) {
        typeof t == "object" && t !== null && typeof t.then == "function" && Go(l, t), b0 !== null && b0(l, t);
    };
    var _a = O(null);
    function Rc() {
        var l = _a.current;
        return l !== null ? l : il.pooledCache;
    }
    function Ku(l, t) {
        t === null ? N(_a, _a.current) : N(_a, t.pool);
    }
    function S0() {
        var l = Rc();
        return l === null ? null : { parent: Sl._currentValue, pool: l };
    }
    var Ze = Error(r(460)),
        x0 = Error(r(474)),
        Ju = Error(r(542)),
        Hc = { then: function () {} };
    function T0(l) {
        return (l = l.status), l === "fulfilled" || l === "rejected";
    }
    function Fu() {}
    function E0(l, t, a) {
        switch (((a = l[a]), a === void 0 ? l.push(t) : a !== t && (t.then(Fu, Fu), (t = a)), t.status)) {
            case "fulfilled":
                return t.value;
            case "rejected":
                throw ((l = t.reason), A0(l), l);
            default:
                if (typeof t.status == "string") t.then(Fu, Fu);
                else {
                    if (((l = il), l !== null && 100 < l.shellSuspendCounter)) throw Error(r(482));
                    (l = t),
                        (l.status = "pending"),
                        l.then(
                            function (e) {
                                if (t.status === "pending") {
                                    var u = t;
                                    (u.status = "fulfilled"), (u.value = e);
                                }
                            },
                            function (e) {
                                if (t.status === "pending") {
                                    var u = t;
                                    (u.status = "rejected"), (u.reason = e);
                                }
                            }
                        );
                }
                switch (t.status) {
                    case "fulfilled":
                        return t.value;
                    case "rejected":
                        throw ((l = t.reason), A0(l), l);
                }
                throw ((Ve = t), Ze);
        }
    }
    var Ve = null;
    function p0() {
        if (Ve === null) throw Error(r(459));
        var l = Ve;
        return (Ve = null), l;
    }
    function A0(l) {
        if (l === Ze || l === Ju) throw Error(r(483));
    }
    var Ft = !1;
    function Bc(l) {
        l.updateQueue = {
            baseState: l.memoizedState,
            firstBaseUpdate: null,
            lastBaseUpdate: null,
            shared: { pending: null, lanes: 0, hiddenCallbacks: null },
            callbacks: null,
        };
    }
    function Cc(l, t) {
        (l = l.updateQueue),
            t.updateQueue === l &&
                (t.updateQueue = {
                    baseState: l.baseState,
                    firstBaseUpdate: l.firstBaseUpdate,
                    lastBaseUpdate: l.lastBaseUpdate,
                    shared: l.shared,
                    callbacks: null,
                });
    }
    function Wt(l) {
        return { lane: l, tag: 0, payload: null, callback: null, next: null };
    }
    function $t(l, t, a) {
        var e = l.updateQueue;
        if (e === null) return null;
        if (((e = e.shared), (ll & 2) !== 0)) {
            var u = e.pending;
            return (
                u === null ? (t.next = t) : ((t.next = u.next), (u.next = t)),
                (e.pending = t),
                (t = Xu(l)),
                r0(l, null, a),
                t
            );
        }
        return Gu(l, e, t, a), Xu(l);
    }
    function Le(l, t, a) {
        if (((t = t.updateQueue), t !== null && ((t = t.shared), (a & 4194048) !== 0))) {
            var e = t.lanes;
            (e &= l.pendingLanes), (a |= e), (t.lanes = a), gi(l, a);
        }
    }
    function qc(l, t) {
        var a = l.updateQueue,
            e = l.alternate;
        if (e !== null && ((e = e.updateQueue), a === e)) {
            var u = null,
                n = null;
            if (((a = a.firstBaseUpdate), a !== null)) {
                do {
                    var c = { lane: a.lane, tag: a.tag, payload: a.payload, callback: null, next: null };
                    n === null ? (u = n = c) : (n = n.next = c), (a = a.next);
                } while (a !== null);
                n === null ? (u = n = t) : (n = n.next = t);
            } else u = n = t;
            (a = {
                baseState: e.baseState,
                firstBaseUpdate: u,
                lastBaseUpdate: n,
                shared: e.shared,
                callbacks: e.callbacks,
            }),
                (l.updateQueue = a);
            return;
        }
        (l = a.lastBaseUpdate), l === null ? (a.firstBaseUpdate = t) : (l.next = t), (a.lastBaseUpdate = t);
    }
    var Yc = !1;
    function we() {
        if (Yc) {
            var l = ae;
            if (l !== null) throw l;
        }
    }
    function Ke(l, t, a, e) {
        Yc = !1;
        var u = l.updateQueue;
        Ft = !1;
        var n = u.firstBaseUpdate,
            c = u.lastBaseUpdate,
            f = u.shared.pending;
        if (f !== null) {
            u.shared.pending = null;
            var i = f,
                y = i.next;
            (i.next = null), c === null ? (n = y) : (c.next = y), (c = i);
            var T = l.alternate;
            T !== null &&
                ((T = T.updateQueue),
                (f = T.lastBaseUpdate),
                f !== c && (f === null ? (T.firstBaseUpdate = y) : (f.next = y), (T.lastBaseUpdate = i)));
        }
        if (n !== null) {
            var A = u.baseState;
            (c = 0), (T = y = i = null), (f = n);
            do {
                var m = f.lane & -536870913,
                    g = m !== f.lane;
                if (g ? (F & m) === m : (e & m) === m) {
                    m !== 0 && m === te && (Yc = !0),
                        T !== null &&
                            (T = T.next = { lane: 0, tag: f.tag, payload: f.payload, callback: null, next: null });
                    l: {
                        var X = l,
                            q = f;
                        m = t;
                        var ul = a;
                        switch (q.tag) {
                            case 1:
                                if (((X = q.payload), typeof X == "function")) {
                                    A = X.call(ul, A, m);
                                    break l;
                                }
                                A = X;
                                break l;
                            case 3:
                                X.flags = (X.flags & -65537) | 128;
                            case 0:
                                if (((X = q.payload), (m = typeof X == "function" ? X.call(ul, A, m) : X), m == null))
                                    break l;
                                A = B({}, A, m);
                                break l;
                            case 2:
                                Ft = !0;
                        }
                    }
                    (m = f.callback),
                        m !== null &&
                            ((l.flags |= 64),
                            g && (l.flags |= 8192),
                            (g = u.callbacks),
                            g === null ? (u.callbacks = [m]) : g.push(m));
                } else
                    (g = { lane: m, tag: f.tag, payload: f.payload, callback: f.callback, next: null }),
                        T === null ? ((y = T = g), (i = A)) : (T = T.next = g),
                        (c |= m);
                if (((f = f.next), f === null)) {
                    if (((f = u.shared.pending), f === null)) break;
                    (g = f), (f = g.next), (g.next = null), (u.lastBaseUpdate = g), (u.shared.pending = null);
                }
            } while (!0);
            T === null && (i = A),
                (u.baseState = i),
                (u.firstBaseUpdate = y),
                (u.lastBaseUpdate = T),
                n === null && (u.shared.lanes = 0),
                (ua |= c),
                (l.lanes = c),
                (l.memoizedState = A);
        }
    }
    function z0(l, t) {
        if (typeof l != "function") throw Error(r(191, l));
        l.call(t);
    }
    function O0(l, t) {
        var a = l.callbacks;
        if (a !== null) for (l.callbacks = null, l = 0; l < a.length; l++) z0(a[l], t);
    }
    var ee = O(null),
        Wu = O(0);
    function M0(l, t) {
        (l = Qt), N(Wu, l), N(ee, t), (Qt = l | t.baseLanes);
    }
    function Gc() {
        N(Wu, Qt), N(ee, ee.current);
    }
    function Xc() {
        (Qt = Wu.current), j(ee), j(Wu);
    }
    var kt = 0,
        L = null,
        al = null,
        gl = null,
        $u = !1,
        ue = !1,
        Da = !1,
        ku = 0,
        Je = 0,
        ne = null,
        Qo = 0;
    function yl() {
        throw Error(r(321));
    }
    function Qc(l, t) {
        if (t === null) return !1;
        for (var a = 0; a < t.length && a < l.length; a++) if (!$l(l[a], t[a])) return !1;
        return !0;
    }
    function Zc(l, t, a, e, u, n) {
        return (
            (kt = n),
            (L = t),
            (t.memoizedState = null),
            (t.updateQueue = null),
            (t.lanes = 0),
            (E.H = l === null || l.memoizedState === null ? rs : os),
            (Da = !1),
            (n = a(e, u)),
            (Da = !1),
            ue && (n = _0(t, a, e, u)),
            N0(l),
            n
        );
    }
    function N0(l) {
        E.H = en;
        var t = al !== null && al.next !== null;
        if (((kt = 0), (gl = al = L = null), ($u = !1), (Je = 0), (ne = null), t)) throw Error(r(300));
        l === null || El || ((l = l.dependencies), l !== null && Lu(l) && (El = !0));
    }
    function _0(l, t, a, e) {
        L = l;
        var u = 0;
        do {
            if ((ue && (ne = null), (Je = 0), (ue = !1), 25 <= u)) throw Error(r(301));
            if (((u += 1), (gl = al = null), l.updateQueue != null)) {
                var n = l.updateQueue;
                (n.lastEffect = null),
                    (n.events = null),
                    (n.stores = null),
                    n.memoCache != null && (n.memoCache.index = 0);
            }
            (E.H = Fo), (n = t(a, e));
        } while (ue);
        return n;
    }
    function Zo() {
        var l = E.H,
            t = l.useState()[0];
        return (
            (t = typeof t.then == "function" ? Fe(t) : t),
            (l = l.useState()[0]),
            (al !== null ? al.memoizedState : null) !== l && (L.flags |= 1024),
            t
        );
    }
    function Vc() {
        var l = ku !== 0;
        return (ku = 0), l;
    }
    function Lc(l, t, a) {
        (t.updateQueue = l.updateQueue), (t.flags &= -2053), (l.lanes &= ~a);
    }
    function wc(l) {
        if ($u) {
            for (l = l.memoizedState; l !== null; ) {
                var t = l.queue;
                t !== null && (t.pending = null), (l = l.next);
            }
            $u = !1;
        }
        (kt = 0), (gl = al = L = null), (ue = !1), (Je = ku = 0), (ne = null);
    }
    function Ql() {
        var l = { memoizedState: null, baseState: null, baseQueue: null, queue: null, next: null };
        return gl === null ? (L.memoizedState = gl = l) : (gl = gl.next = l), gl;
    }
    function bl() {
        if (al === null) {
            var l = L.alternate;
            l = l !== null ? l.memoizedState : null;
        } else l = al.next;
        var t = gl === null ? L.memoizedState : gl.next;
        if (t !== null) (gl = t), (al = l);
        else {
            if (l === null) throw L.alternate === null ? Error(r(467)) : Error(r(310));
            (al = l),
                (l = {
                    memoizedState: al.memoizedState,
                    baseState: al.baseState,
                    baseQueue: al.baseQueue,
                    queue: al.queue,
                    next: null,
                }),
                gl === null ? (L.memoizedState = gl = l) : (gl = gl.next = l);
        }
        return gl;
    }
    function Kc() {
        return { lastEffect: null, events: null, stores: null, memoCache: null };
    }
    function Fe(l) {
        var t = Je;
        return (
            (Je += 1),
            ne === null && (ne = []),
            (l = E0(ne, l, t)),
            (t = L),
            (gl === null ? t.memoizedState : gl.next) === null &&
                ((t = t.alternate), (E.H = t === null || t.memoizedState === null ? rs : os)),
            l
        );
    }
    function Pu(l) {
        if (l !== null && typeof l == "object") {
            if (typeof l.then == "function") return Fe(l);
            if (l.$$typeof === Nl) return Ul(l);
        }
        throw Error(r(438, String(l)));
    }
    function Jc(l) {
        var t = null,
            a = L.updateQueue;
        if ((a !== null && (t = a.memoCache), t == null)) {
            var e = L.alternate;
            e !== null &&
                ((e = e.updateQueue),
                e !== null &&
                    ((e = e.memoCache),
                    e != null &&
                        (t = {
                            data: e.data.map(function (u) {
                                return u.slice();
                            }),
                            index: 0,
                        })));
        }
        if (
            (t == null && (t = { data: [], index: 0 }),
            a === null && ((a = Kc()), (L.updateQueue = a)),
            (a.memoCache = t),
            (a = t.data[t.index]),
            a === void 0)
        )
            for (a = t.data[t.index] = Array(l), e = 0; e < l; e++) a[e] = Ca;
        return t.index++, a;
    }
    function Bt(l, t) {
        return typeof t == "function" ? t(l) : t;
    }
    function Iu(l) {
        var t = bl();
        return Fc(t, al, l);
    }
    function Fc(l, t, a) {
        var e = l.queue;
        if (e === null) throw Error(r(311));
        e.lastRenderedReducer = a;
        var u = l.baseQueue,
            n = e.pending;
        if (n !== null) {
            if (u !== null) {
                var c = u.next;
                (u.next = n.next), (n.next = c);
            }
            (t.baseQueue = u = n), (e.pending = null);
        }
        if (((n = l.baseState), u === null)) l.memoizedState = n;
        else {
            t = u.next;
            var f = (c = null),
                i = null,
                y = t,
                T = !1;
            do {
                var A = y.lane & -536870913;
                if (A !== y.lane ? (F & A) === A : (kt & A) === A) {
                    var m = y.revertLane;
                    if (m === 0)
                        i !== null &&
                            (i = i.next =
                                {
                                    lane: 0,
                                    revertLane: 0,
                                    action: y.action,
                                    hasEagerState: y.hasEagerState,
                                    eagerState: y.eagerState,
                                    next: null,
                                }),
                            A === te && (T = !0);
                    else if ((kt & m) === m) {
                        (y = y.next), m === te && (T = !0);
                        continue;
                    } else
                        (A = {
                            lane: 0,
                            revertLane: y.revertLane,
                            action: y.action,
                            hasEagerState: y.hasEagerState,
                            eagerState: y.eagerState,
                            next: null,
                        }),
                            i === null ? ((f = i = A), (c = n)) : (i = i.next = A),
                            (L.lanes |= m),
                            (ua |= m);
                    (A = y.action), Da && a(n, A), (n = y.hasEagerState ? y.eagerState : a(n, A));
                } else
                    (m = {
                        lane: A,
                        revertLane: y.revertLane,
                        action: y.action,
                        hasEagerState: y.hasEagerState,
                        eagerState: y.eagerState,
                        next: null,
                    }),
                        i === null ? ((f = i = m), (c = n)) : (i = i.next = m),
                        (L.lanes |= A),
                        (ua |= A);
                y = y.next;
            } while (y !== null && y !== t);
            if (
                (i === null ? (c = n) : (i.next = f),
                !$l(n, l.memoizedState) && ((El = !0), T && ((a = ae), a !== null)))
            )
                throw a;
            (l.memoizedState = n), (l.baseState = c), (l.baseQueue = i), (e.lastRenderedState = n);
        }
        return u === null && (e.lanes = 0), [l.memoizedState, e.dispatch];
    }
    function Wc(l) {
        var t = bl(),
            a = t.queue;
        if (a === null) throw Error(r(311));
        a.lastRenderedReducer = l;
        var e = a.dispatch,
            u = a.pending,
            n = t.memoizedState;
        if (u !== null) {
            a.pending = null;
            var c = (u = u.next);
            do (n = l(n, c.action)), (c = c.next);
            while (c !== u);
            $l(n, t.memoizedState) || (El = !0),
                (t.memoizedState = n),
                t.baseQueue === null && (t.baseState = n),
                (a.lastRenderedState = n);
        }
        return [n, e];
    }
    function D0(l, t, a) {
        var e = L,
            u = bl(),
            n = I;
        if (n) {
            if (a === void 0) throw Error(r(407));
            a = a();
        } else a = t();
        var c = !$l((al || u).memoizedState, a);
        c && ((u.memoizedState = a), (El = !0)), (u = u.queue);
        var f = R0.bind(null, e, u, l);
        if ((We(2048, 8, f, [l]), u.getSnapshot !== t || c || (gl !== null && gl.memoizedState.tag & 1))) {
            if (((e.flags |= 2048), ce(9, ln(), U0.bind(null, e, u, a, t), null), il === null)) throw Error(r(349));
            n || (kt & 124) !== 0 || j0(e, t, a);
        }
        return a;
    }
    function j0(l, t, a) {
        (l.flags |= 16384),
            (l = { getSnapshot: t, value: a }),
            (t = L.updateQueue),
            t === null
                ? ((t = Kc()), (L.updateQueue = t), (t.stores = [l]))
                : ((a = t.stores), a === null ? (t.stores = [l]) : a.push(l));
    }
    function U0(l, t, a, e) {
        (t.value = a), (t.getSnapshot = e), H0(t) && B0(l);
    }
    function R0(l, t, a) {
        return a(function () {
            H0(t) && B0(l);
        });
    }
    function H0(l) {
        var t = l.getSnapshot;
        l = l.value;
        try {
            var a = t();
            return !$l(l, a);
        } catch {
            return !0;
        }
    }
    function B0(l) {
        var t = ka(l, 2);
        t !== null && at(t, l, 2);
    }
    function $c(l) {
        var t = Ql();
        if (typeof l == "function") {
            var a = l;
            if (((l = a()), Da)) {
                Lt(!0);
                try {
                    a();
                } finally {
                    Lt(!1);
                }
            }
        }
        return (
            (t.memoizedState = t.baseState = l),
            (t.queue = { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: Bt, lastRenderedState: l }),
            t
        );
    }
    function C0(l, t, a, e) {
        return (l.baseState = a), Fc(l, al, typeof e == "function" ? e : Bt);
    }
    function Vo(l, t, a, e, u) {
        if (an(l)) throw Error(r(485));
        if (((l = t.action), l !== null)) {
            var n = {
                payload: u,
                action: l,
                next: null,
                isTransition: !0,
                status: "pending",
                value: null,
                reason: null,
                listeners: [],
                then: function (c) {
                    n.listeners.push(c);
                },
            };
            E.T !== null ? a(!0) : (n.isTransition = !1),
                e(n),
                (a = t.pending),
                a === null ? ((n.next = t.pending = n), q0(t, n)) : ((n.next = a.next), (t.pending = a.next = n));
        }
    }
    function q0(l, t) {
        var a = t.action,
            e = t.payload,
            u = l.state;
        if (t.isTransition) {
            var n = E.T,
                c = {};
            E.T = c;
            try {
                var f = a(u, e),
                    i = E.S;
                i !== null && i(c, f), Y0(l, t, f);
            } catch (y) {
                kc(l, t, y);
            } finally {
                E.T = n;
            }
        } else
            try {
                (n = a(u, e)), Y0(l, t, n);
            } catch (y) {
                kc(l, t, y);
            }
    }
    function Y0(l, t, a) {
        a !== null && typeof a == "object" && typeof a.then == "function"
            ? a.then(
                  function (e) {
                      G0(l, t, e);
                  },
                  function (e) {
                      return kc(l, t, e);
                  }
              )
            : G0(l, t, a);
    }
    function G0(l, t, a) {
        (t.status = "fulfilled"),
            (t.value = a),
            X0(t),
            (l.state = a),
            (t = l.pending),
            t !== null && ((a = t.next), a === t ? (l.pending = null) : ((a = a.next), (t.next = a), q0(l, a)));
    }
    function kc(l, t, a) {
        var e = l.pending;
        if (((l.pending = null), e !== null)) {
            e = e.next;
            do (t.status = "rejected"), (t.reason = a), X0(t), (t = t.next);
            while (t !== e);
        }
        l.action = null;
    }
    function X0(l) {
        l = l.listeners;
        for (var t = 0; t < l.length; t++) (0, l[t])();
    }
    function Q0(l, t) {
        return t;
    }
    function Z0(l, t) {
        if (I) {
            var a = il.formState;
            if (a !== null) {
                l: {
                    var e = L;
                    if (I) {
                        if (hl) {
                            t: {
                                for (var u = hl, n = Tt; u.nodeType !== 8; ) {
                                    if (!n) {
                                        u = null;
                                        break t;
                                    }
                                    if (((u = bt(u.nextSibling)), u === null)) {
                                        u = null;
                                        break t;
                                    }
                                }
                                (n = u.data), (u = n === "F!" || n === "F" ? u : null);
                            }
                            if (u) {
                                (hl = bt(u.nextSibling)), (e = u.data === "F!");
                                break l;
                            }
                        }
                        Oa(e);
                    }
                    e = !1;
                }
                e && (t = a[0]);
            }
        }
        return (
            (a = Ql()),
            (a.memoizedState = a.baseState = t),
            (e = { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: Q0, lastRenderedState: t }),
            (a.queue = e),
            (a = fs.bind(null, L, e)),
            (e.dispatch = a),
            (e = $c(!1)),
            (n = af.bind(null, L, !1, e.queue)),
            (e = Ql()),
            (u = { state: t, dispatch: null, action: l, pending: null }),
            (e.queue = u),
            (a = Vo.bind(null, L, u, n, a)),
            (u.dispatch = a),
            (e.memoizedState = l),
            [t, a, !1]
        );
    }
    function V0(l) {
        var t = bl();
        return L0(t, al, l);
    }
    function L0(l, t, a) {
        if (((t = Fc(l, t, Q0)[0]), (l = Iu(Bt)[0]), typeof t == "object" && t !== null && typeof t.then == "function"))
            try {
                var e = Fe(t);
            } catch (c) {
                throw c === Ze ? Ju : c;
            }
        else e = t;
        t = bl();
        var u = t.queue,
            n = u.dispatch;
        return a !== t.memoizedState && ((L.flags |= 2048), ce(9, ln(), Lo.bind(null, u, a), null)), [e, n, l];
    }
    function Lo(l, t) {
        l.action = t;
    }
    function w0(l) {
        var t = bl(),
            a = al;
        if (a !== null) return L0(t, a, l);
        bl(), (t = t.memoizedState), (a = bl());
        var e = a.queue.dispatch;
        return (a.memoizedState = l), [t, e, !1];
    }
    function ce(l, t, a, e) {
        return (
            (l = { tag: l, create: a, deps: e, inst: t, next: null }),
            (t = L.updateQueue),
            t === null && ((t = Kc()), (L.updateQueue = t)),
            (a = t.lastEffect),
            a === null ? (t.lastEffect = l.next = l) : ((e = a.next), (a.next = l), (l.next = e), (t.lastEffect = l)),
            l
        );
    }
    function ln() {
        return { destroy: void 0, resource: void 0 };
    }
    function K0() {
        return bl().memoizedState;
    }
    function tn(l, t, a, e) {
        var u = Ql();
        (e = e === void 0 ? null : e), (L.flags |= l), (u.memoizedState = ce(1 | t, ln(), a, e));
    }
    function We(l, t, a, e) {
        var u = bl();
        e = e === void 0 ? null : e;
        var n = u.memoizedState.inst;
        al !== null && e !== null && Qc(e, al.memoizedState.deps)
            ? (u.memoizedState = ce(t, n, a, e))
            : ((L.flags |= l), (u.memoizedState = ce(1 | t, n, a, e)));
    }
    function J0(l, t) {
        tn(8390656, 8, l, t);
    }
    function F0(l, t) {
        We(2048, 8, l, t);
    }
    function W0(l, t) {
        return We(4, 2, l, t);
    }
    function $0(l, t) {
        return We(4, 4, l, t);
    }
    function k0(l, t) {
        if (typeof t == "function") {
            l = l();
            var a = t(l);
            return function () {
                typeof a == "function" ? a() : t(null);
            };
        }
        if (t != null)
            return (
                (l = l()),
                (t.current = l),
                function () {
                    t.current = null;
                }
            );
    }
    function P0(l, t, a) {
        (a = a != null ? a.concat([l]) : null), We(4, 4, k0.bind(null, t, l), a);
    }
    function Pc() {}
    function I0(l, t) {
        var a = bl();
        t = t === void 0 ? null : t;
        var e = a.memoizedState;
        return t !== null && Qc(t, e[1]) ? e[0] : ((a.memoizedState = [l, t]), l);
    }
    function ls(l, t) {
        var a = bl();
        t = t === void 0 ? null : t;
        var e = a.memoizedState;
        if (t !== null && Qc(t, e[1])) return e[0];
        if (((e = l()), Da)) {
            Lt(!0);
            try {
                l();
            } finally {
                Lt(!1);
            }
        }
        return (a.memoizedState = [e, t]), e;
    }
    function Ic(l, t, a) {
        return a === void 0 || (kt & 1073741824) !== 0
            ? (l.memoizedState = t)
            : ((l.memoizedState = a), (l = e1()), (L.lanes |= l), (ua |= l), a);
    }
    function ts(l, t, a, e) {
        return $l(a, t)
            ? a
            : ee.current !== null
              ? ((l = Ic(l, a, e)), $l(l, t) || (El = !0), l)
              : (kt & 42) === 0
                ? ((El = !0), (l.memoizedState = a))
                : ((l = e1()), (L.lanes |= l), (ua |= l), t);
    }
    function as(l, t, a, e, u) {
        var n = _.p;
        _.p = n !== 0 && 8 > n ? n : 8;
        var c = E.T,
            f = {};
        (E.T = f), af(l, !1, t, a);
        try {
            var i = u(),
                y = E.S;
            if ((y !== null && y(f, i), i !== null && typeof i == "object" && typeof i.then == "function")) {
                var T = Xo(i, e);
                $e(l, t, T, tt(l));
            } else $e(l, t, e, tt(l));
        } catch (A) {
            $e(l, t, { then: function () {}, status: "rejected", reason: A }, tt());
        } finally {
            (_.p = n), (E.T = c);
        }
    }
    function wo() {}
    function lf(l, t, a, e) {
        if (l.tag !== 5) throw Error(r(476));
        var u = es(l).queue;
        as(
            l,
            u,
            t,
            G,
            a === null
                ? wo
                : function () {
                      return us(l), a(e);
                  }
        );
    }
    function es(l) {
        var t = l.memoizedState;
        if (t !== null) return t;
        t = {
            memoizedState: G,
            baseState: G,
            baseQueue: null,
            queue: { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: Bt, lastRenderedState: G },
            next: null,
        };
        var a = {};
        return (
            (t.next = {
                memoizedState: a,
                baseState: a,
                baseQueue: null,
                queue: { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: Bt, lastRenderedState: a },
                next: null,
            }),
            (l.memoizedState = t),
            (l = l.alternate),
            l !== null && (l.memoizedState = t),
            t
        );
    }
    function us(l) {
        var t = es(l).next.queue;
        $e(l, t, {}, tt());
    }
    function tf() {
        return Ul(vu);
    }
    function ns() {
        return bl().memoizedState;
    }
    function cs() {
        return bl().memoizedState;
    }
    function Ko(l) {
        for (var t = l.return; t !== null; ) {
            switch (t.tag) {
                case 24:
                case 3:
                    var a = tt();
                    l = Wt(a);
                    var e = $t(t, l, a);
                    e !== null && (at(e, t, a), Le(e, t, a)), (t = { cache: jc() }), (l.payload = t);
                    return;
            }
            t = t.return;
        }
    }
    function Jo(l, t, a) {
        var e = tt();
        (a = { lane: e, revertLane: 0, action: a, hasEagerState: !1, eagerState: null, next: null }),
            an(l) ? is(t, a) : ((a = Tc(l, t, a, e)), a !== null && (at(a, l, e), ss(a, t, e)));
    }
    function fs(l, t, a) {
        var e = tt();
        $e(l, t, a, e);
    }
    function $e(l, t, a, e) {
        var u = { lane: e, revertLane: 0, action: a, hasEagerState: !1, eagerState: null, next: null };
        if (an(l)) is(t, u);
        else {
            var n = l.alternate;
            if (l.lanes === 0 && (n === null || n.lanes === 0) && ((n = t.lastRenderedReducer), n !== null))
                try {
                    var c = t.lastRenderedState,
                        f = n(c, a);
                    if (((u.hasEagerState = !0), (u.eagerState = f), $l(f, c)))
                        return Gu(l, t, u, 0), il === null && Yu(), !1;
                } catch {
                } finally {
                }
            if (((a = Tc(l, t, u, e)), a !== null)) return at(a, l, e), ss(a, t, e), !0;
        }
        return !1;
    }
    function af(l, t, a, e) {
        if (((e = { lane: 2, revertLane: Bf(), action: e, hasEagerState: !1, eagerState: null, next: null }), an(l))) {
            if (t) throw Error(r(479));
        } else (t = Tc(l, a, e, 2)), t !== null && at(t, l, 2);
    }
    function an(l) {
        var t = l.alternate;
        return l === L || (t !== null && t === L);
    }
    function is(l, t) {
        ue = $u = !0;
        var a = l.pending;
        a === null ? (t.next = t) : ((t.next = a.next), (a.next = t)), (l.pending = t);
    }
    function ss(l, t, a) {
        if ((a & 4194048) !== 0) {
            var e = t.lanes;
            (e &= l.pendingLanes), (a |= e), (t.lanes = a), gi(l, a);
        }
    }
    var en = {
            readContext: Ul,
            use: Pu,
            useCallback: yl,
            useContext: yl,
            useEffect: yl,
            useImperativeHandle: yl,
            useLayoutEffect: yl,
            useInsertionEffect: yl,
            useMemo: yl,
            useReducer: yl,
            useRef: yl,
            useState: yl,
            useDebugValue: yl,
            useDeferredValue: yl,
            useTransition: yl,
            useSyncExternalStore: yl,
            useId: yl,
            useHostTransitionStatus: yl,
            useFormState: yl,
            useActionState: yl,
            useOptimistic: yl,
            useMemoCache: yl,
            useCacheRefresh: yl,
        },
        rs = {
            readContext: Ul,
            use: Pu,
            useCallback: function (l, t) {
                return (Ql().memoizedState = [l, t === void 0 ? null : t]), l;
            },
            useContext: Ul,
            useEffect: J0,
            useImperativeHandle: function (l, t, a) {
                (a = a != null ? a.concat([l]) : null), tn(4194308, 4, k0.bind(null, t, l), a);
            },
            useLayoutEffect: function (l, t) {
                return tn(4194308, 4, l, t);
            },
            useInsertionEffect: function (l, t) {
                tn(4, 2, l, t);
            },
            useMemo: function (l, t) {
                var a = Ql();
                t = t === void 0 ? null : t;
                var e = l();
                if (Da) {
                    Lt(!0);
                    try {
                        l();
                    } finally {
                        Lt(!1);
                    }
                }
                return (a.memoizedState = [e, t]), e;
            },
            useReducer: function (l, t, a) {
                var e = Ql();
                if (a !== void 0) {
                    var u = a(t);
                    if (Da) {
                        Lt(!0);
                        try {
                            a(t);
                        } finally {
                            Lt(!1);
                        }
                    }
                } else u = t;
                return (
                    (e.memoizedState = e.baseState = u),
                    (l = { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: l, lastRenderedState: u }),
                    (e.queue = l),
                    (l = l.dispatch = Jo.bind(null, L, l)),
                    [e.memoizedState, l]
                );
            },
            useRef: function (l) {
                var t = Ql();
                return (l = { current: l }), (t.memoizedState = l);
            },
            useState: function (l) {
                l = $c(l);
                var t = l.queue,
                    a = fs.bind(null, L, t);
                return (t.dispatch = a), [l.memoizedState, a];
            },
            useDebugValue: Pc,
            useDeferredValue: function (l, t) {
                var a = Ql();
                return Ic(a, l, t);
            },
            useTransition: function () {
                var l = $c(!1);
                return (l = as.bind(null, L, l.queue, !0, !1)), (Ql().memoizedState = l), [!1, l];
            },
            useSyncExternalStore: function (l, t, a) {
                var e = L,
                    u = Ql();
                if (I) {
                    if (a === void 0) throw Error(r(407));
                    a = a();
                } else {
                    if (((a = t()), il === null)) throw Error(r(349));
                    (F & 124) !== 0 || j0(e, t, a);
                }
                u.memoizedState = a;
                var n = { value: a, getSnapshot: t };
                return (
                    (u.queue = n),
                    J0(R0.bind(null, e, n, l), [l]),
                    (e.flags |= 2048),
                    ce(9, ln(), U0.bind(null, e, n, a, t), null),
                    a
                );
            },
            useId: function () {
                var l = Ql(),
                    t = il.identifierPrefix;
                if (I) {
                    var a = Ut,
                        e = jt;
                    (a = (e & ~(1 << (32 - Wl(e) - 1))).toString(32) + a),
                        (t = "«" + t + "R" + a),
                        (a = ku++),
                        0 < a && (t += "H" + a.toString(32)),
                        (t += "»");
                } else (a = Qo++), (t = "«" + t + "r" + a.toString(32) + "»");
                return (l.memoizedState = t);
            },
            useHostTransitionStatus: tf,
            useFormState: Z0,
            useActionState: Z0,
            useOptimistic: function (l) {
                var t = Ql();
                t.memoizedState = t.baseState = l;
                var a = { pending: null, lanes: 0, dispatch: null, lastRenderedReducer: null, lastRenderedState: null };
                return (t.queue = a), (t = af.bind(null, L, !0, a)), (a.dispatch = t), [l, t];
            },
            useMemoCache: Jc,
            useCacheRefresh: function () {
                return (Ql().memoizedState = Ko.bind(null, L));
            },
        },
        os = {
            readContext: Ul,
            use: Pu,
            useCallback: I0,
            useContext: Ul,
            useEffect: F0,
            useImperativeHandle: P0,
            useInsertionEffect: W0,
            useLayoutEffect: $0,
            useMemo: ls,
            useReducer: Iu,
            useRef: K0,
            useState: function () {
                return Iu(Bt);
            },
            useDebugValue: Pc,
            useDeferredValue: function (l, t) {
                var a = bl();
                return ts(a, al.memoizedState, l, t);
            },
            useTransition: function () {
                var l = Iu(Bt)[0],
                    t = bl().memoizedState;
                return [typeof l == "boolean" ? l : Fe(l), t];
            },
            useSyncExternalStore: D0,
            useId: ns,
            useHostTransitionStatus: tf,
            useFormState: V0,
            useActionState: V0,
            useOptimistic: function (l, t) {
                var a = bl();
                return C0(a, al, l, t);
            },
            useMemoCache: Jc,
            useCacheRefresh: cs,
        },
        Fo = {
            readContext: Ul,
            use: Pu,
            useCallback: I0,
            useContext: Ul,
            useEffect: F0,
            useImperativeHandle: P0,
            useInsertionEffect: W0,
            useLayoutEffect: $0,
            useMemo: ls,
            useReducer: Wc,
            useRef: K0,
            useState: function () {
                return Wc(Bt);
            },
            useDebugValue: Pc,
            useDeferredValue: function (l, t) {
                var a = bl();
                return al === null ? Ic(a, l, t) : ts(a, al.memoizedState, l, t);
            },
            useTransition: function () {
                var l = Wc(Bt)[0],
                    t = bl().memoizedState;
                return [typeof l == "boolean" ? l : Fe(l), t];
            },
            useSyncExternalStore: D0,
            useId: ns,
            useHostTransitionStatus: tf,
            useFormState: w0,
            useActionState: w0,
            useOptimistic: function (l, t) {
                var a = bl();
                return al !== null ? C0(a, al, l, t) : ((a.baseState = l), [l, a.queue.dispatch]);
            },
            useMemoCache: Jc,
            useCacheRefresh: cs,
        },
        fe = null,
        ke = 0;
    function un(l) {
        var t = ke;
        return (ke += 1), fe === null && (fe = []), E0(fe, l, t);
    }
    function Pe(l, t) {
        (t = t.props.ref), (l.ref = t !== void 0 ? t : null);
    }
    function nn(l, t) {
        throw t.$$typeof === sl
            ? Error(r(525))
            : ((l = Object.prototype.toString.call(t)),
              Error(r(31, l === "[object Object]" ? "object with keys {" + Object.keys(t).join(", ") + "}" : l)));
    }
    function ds(l) {
        var t = l._init;
        return t(l._payload);
    }
    function hs(l) {
        function t(h, d) {
            if (l) {
                var v = h.deletions;
                v === null ? ((h.deletions = [d]), (h.flags |= 16)) : v.push(d);
            }
        }
        function a(h, d) {
            if (!l) return null;
            for (; d !== null; ) t(h, d), (d = d.sibling);
            return null;
        }
        function e(h) {
            for (var d = new Map(); h !== null; ) h.key !== null ? d.set(h.key, h) : d.set(h.index, h), (h = h.sibling);
            return d;
        }
        function u(h, d) {
            return (h = Dt(h, d)), (h.index = 0), (h.sibling = null), h;
        }
        function n(h, d, v) {
            return (
                (h.index = v),
                l
                    ? ((v = h.alternate),
                      v !== null ? ((v = v.index), v < d ? ((h.flags |= 67108866), d) : v) : ((h.flags |= 67108866), d))
                    : ((h.flags |= 1048576), d)
            );
        }
        function c(h) {
            return l && h.alternate === null && (h.flags |= 67108866), h;
        }
        function f(h, d, v, p) {
            return d === null || d.tag !== 6
                ? ((d = pc(v, h.mode, p)), (d.return = h), d)
                : ((d = u(d, v)), (d.return = h), d);
        }
        function i(h, d, v, p) {
            var U = v.type;
            return U === Bl
                ? T(h, d, v.props.children, p, v.key)
                : d !== null &&
                    (d.elementType === U ||
                        (typeof U == "object" && U !== null && U.$$typeof === Kl && ds(U) === d.type))
                  ? ((d = u(d, v.props)), Pe(d, v), (d.return = h), d)
                  : ((d = Qu(v.type, v.key, v.props, null, h.mode, p)), Pe(d, v), (d.return = h), d);
        }
        function y(h, d, v, p) {
            return d === null ||
                d.tag !== 4 ||
                d.stateNode.containerInfo !== v.containerInfo ||
                d.stateNode.implementation !== v.implementation
                ? ((d = Ac(v, h.mode, p)), (d.return = h), d)
                : ((d = u(d, v.children || [])), (d.return = h), d);
        }
        function T(h, d, v, p, U) {
            return d === null || d.tag !== 7
                ? ((d = Ea(v, h.mode, p, U)), (d.return = h), d)
                : ((d = u(d, v)), (d.return = h), d);
        }
        function A(h, d, v) {
            if ((typeof d == "string" && d !== "") || typeof d == "number" || typeof d == "bigint")
                return (d = pc("" + d, h.mode, v)), (d.return = h), d;
            if (typeof d == "object" && d !== null) {
                switch (d.$$typeof) {
                    case fl:
                        return (v = Qu(d.type, d.key, d.props, null, h.mode, v)), Pe(v, d), (v.return = h), v;
                    case Hl:
                        return (d = Ac(d, h.mode, v)), (d.return = h), d;
                    case Kl:
                        var p = d._init;
                        return (d = p(d._payload)), A(h, d, v);
                }
                if (Dl(d) || _l(d)) return (d = Ea(d, h.mode, v, null)), (d.return = h), d;
                if (typeof d.then == "function") return A(h, un(d), v);
                if (d.$$typeof === Nl) return A(h, wu(h, d), v);
                nn(h, d);
            }
            return null;
        }
        function m(h, d, v, p) {
            var U = d !== null ? d.key : null;
            if ((typeof v == "string" && v !== "") || typeof v == "number" || typeof v == "bigint")
                return U !== null ? null : f(h, d, "" + v, p);
            if (typeof v == "object" && v !== null) {
                switch (v.$$typeof) {
                    case fl:
                        return v.key === U ? i(h, d, v, p) : null;
                    case Hl:
                        return v.key === U ? y(h, d, v, p) : null;
                    case Kl:
                        return (U = v._init), (v = U(v._payload)), m(h, d, v, p);
                }
                if (Dl(v) || _l(v)) return U !== null ? null : T(h, d, v, p, null);
                if (typeof v.then == "function") return m(h, d, un(v), p);
                if (v.$$typeof === Nl) return m(h, d, wu(h, v), p);
                nn(h, v);
            }
            return null;
        }
        function g(h, d, v, p, U) {
            if ((typeof p == "string" && p !== "") || typeof p == "number" || typeof p == "bigint")
                return (h = h.get(v) || null), f(d, h, "" + p, U);
            if (typeof p == "object" && p !== null) {
                switch (p.$$typeof) {
                    case fl:
                        return (h = h.get(p.key === null ? v : p.key) || null), i(d, h, p, U);
                    case Hl:
                        return (h = h.get(p.key === null ? v : p.key) || null), y(d, h, p, U);
                    case Kl:
                        var w = p._init;
                        return (p = w(p._payload)), g(h, d, v, p, U);
                }
                if (Dl(p) || _l(p)) return (h = h.get(v) || null), T(d, h, p, U, null);
                if (typeof p.then == "function") return g(h, d, v, un(p), U);
                if (p.$$typeof === Nl) return g(h, d, v, wu(d, p), U);
                nn(d, p);
            }
            return null;
        }
        function X(h, d, v, p) {
            for (var U = null, w = null, R = d, Y = (d = 0), Al = null; R !== null && Y < v.length; Y++) {
                R.index > Y ? ((Al = R), (R = null)) : (Al = R.sibling);
                var P = m(h, R, v[Y], p);
                if (P === null) {
                    R === null && (R = Al);
                    break;
                }
                l && R && P.alternate === null && t(h, R),
                    (d = n(P, d, Y)),
                    w === null ? (U = P) : (w.sibling = P),
                    (w = P),
                    (R = Al);
            }
            if (Y === v.length) return a(h, R), I && Aa(h, Y), U;
            if (R === null) {
                for (; Y < v.length; Y++)
                    (R = A(h, v[Y], p)),
                        R !== null && ((d = n(R, d, Y)), w === null ? (U = R) : (w.sibling = R), (w = R));
                return I && Aa(h, Y), U;
            }
            for (R = e(R); Y < v.length; Y++)
                (Al = g(R, h, Y, v[Y], p)),
                    Al !== null &&
                        (l && Al.alternate !== null && R.delete(Al.key === null ? Y : Al.key),
                        (d = n(Al, d, Y)),
                        w === null ? (U = Al) : (w.sibling = Al),
                        (w = Al));
            return (
                l &&
                    R.forEach(function (ha) {
                        return t(h, ha);
                    }),
                I && Aa(h, Y),
                U
            );
        }
        function q(h, d, v, p) {
            if (v == null) throw Error(r(151));
            for (
                var U = null, w = null, R = d, Y = (d = 0), Al = null, P = v.next();
                R !== null && !P.done;
                Y++, P = v.next()
            ) {
                R.index > Y ? ((Al = R), (R = null)) : (Al = R.sibling);
                var ha = m(h, R, P.value, p);
                if (ha === null) {
                    R === null && (R = Al);
                    break;
                }
                l && R && ha.alternate === null && t(h, R),
                    (d = n(ha, d, Y)),
                    w === null ? (U = ha) : (w.sibling = ha),
                    (w = ha),
                    (R = Al);
            }
            if (P.done) return a(h, R), I && Aa(h, Y), U;
            if (R === null) {
                for (; !P.done; Y++, P = v.next())
                    (P = A(h, P.value, p)),
                        P !== null && ((d = n(P, d, Y)), w === null ? (U = P) : (w.sibling = P), (w = P));
                return I && Aa(h, Y), U;
            }
            for (R = e(R); !P.done; Y++, P = v.next())
                (P = g(R, h, Y, P.value, p)),
                    P !== null &&
                        (l && P.alternate !== null && R.delete(P.key === null ? Y : P.key),
                        (d = n(P, d, Y)),
                        w === null ? (U = P) : (w.sibling = P),
                        (w = P));
            return (
                l &&
                    R.forEach(function (Wd) {
                        return t(h, Wd);
                    }),
                I && Aa(h, Y),
                U
            );
        }
        function ul(h, d, v, p) {
            if (
                (typeof v == "object" && v !== null && v.type === Bl && v.key === null && (v = v.props.children),
                typeof v == "object" && v !== null)
            ) {
                switch (v.$$typeof) {
                    case fl:
                        l: {
                            for (var U = v.key; d !== null; ) {
                                if (d.key === U) {
                                    if (((U = v.type), U === Bl)) {
                                        if (d.tag === 7) {
                                            a(h, d.sibling), (p = u(d, v.props.children)), (p.return = h), (h = p);
                                            break l;
                                        }
                                    } else if (
                                        d.elementType === U ||
                                        (typeof U == "object" && U !== null && U.$$typeof === Kl && ds(U) === d.type)
                                    ) {
                                        a(h, d.sibling), (p = u(d, v.props)), Pe(p, v), (p.return = h), (h = p);
                                        break l;
                                    }
                                    a(h, d);
                                    break;
                                } else t(h, d);
                                d = d.sibling;
                            }
                            v.type === Bl
                                ? ((p = Ea(v.props.children, h.mode, p, v.key)), (p.return = h), (h = p))
                                : ((p = Qu(v.type, v.key, v.props, null, h.mode, p)),
                                  Pe(p, v),
                                  (p.return = h),
                                  (h = p));
                        }
                        return c(h);
                    case Hl:
                        l: {
                            for (U = v.key; d !== null; ) {
                                if (d.key === U)
                                    if (
                                        d.tag === 4 &&
                                        d.stateNode.containerInfo === v.containerInfo &&
                                        d.stateNode.implementation === v.implementation
                                    ) {
                                        a(h, d.sibling), (p = u(d, v.children || [])), (p.return = h), (h = p);
                                        break l;
                                    } else {
                                        a(h, d);
                                        break;
                                    }
                                else t(h, d);
                                d = d.sibling;
                            }
                            (p = Ac(v, h.mode, p)), (p.return = h), (h = p);
                        }
                        return c(h);
                    case Kl:
                        return (U = v._init), (v = U(v._payload)), ul(h, d, v, p);
                }
                if (Dl(v)) return X(h, d, v, p);
                if (_l(v)) {
                    if (((U = _l(v)), typeof U != "function")) throw Error(r(150));
                    return (v = U.call(v)), q(h, d, v, p);
                }
                if (typeof v.then == "function") return ul(h, d, un(v), p);
                if (v.$$typeof === Nl) return ul(h, d, wu(h, v), p);
                nn(h, v);
            }
            return (typeof v == "string" && v !== "") || typeof v == "number" || typeof v == "bigint"
                ? ((v = "" + v),
                  d !== null && d.tag === 6
                      ? (a(h, d.sibling), (p = u(d, v)), (p.return = h), (h = p))
                      : (a(h, d), (p = pc(v, h.mode, p)), (p.return = h), (h = p)),
                  c(h))
                : a(h, d);
        }
        return function (h, d, v, p) {
            try {
                ke = 0;
                var U = ul(h, d, v, p);
                return (fe = null), U;
            } catch (R) {
                if (R === Ze || R === Ju) throw R;
                var w = kl(29, R, null, h.mode);
                return (w.lanes = p), (w.return = h), w;
            } finally {
            }
        };
    }
    var ie = hs(!0),
        vs = hs(!1),
        st = O(null),
        Et = null;
    function Pt(l) {
        var t = l.alternate;
        N(xl, xl.current & 1),
            N(st, l),
            Et === null && (t === null || ee.current !== null || t.memoizedState !== null) && (Et = l);
    }
    function ys(l) {
        if (l.tag === 22) {
            if ((N(xl, xl.current), N(st, l), Et === null)) {
                var t = l.alternate;
                t !== null && t.memoizedState !== null && (Et = l);
            }
        } else It();
    }
    function It() {
        N(xl, xl.current), N(st, st.current);
    }
    function Ct(l) {
        j(st), Et === l && (Et = null), j(xl);
    }
    var xl = O(0);
    function cn(l) {
        for (var t = l; t !== null; ) {
            if (t.tag === 13) {
                var a = t.memoizedState;
                if (a !== null && ((a = a.dehydrated), a === null || a.data === "$?" || Jf(a))) return t;
            } else if (t.tag === 19 && t.memoizedProps.revealOrder !== void 0) {
                if ((t.flags & 128) !== 0) return t;
            } else if (t.child !== null) {
                (t.child.return = t), (t = t.child);
                continue;
            }
            if (t === l) break;
            for (; t.sibling === null; ) {
                if (t.return === null || t.return === l) return null;
                t = t.return;
            }
            (t.sibling.return = t.return), (t = t.sibling);
        }
        return null;
    }
    function ef(l, t, a, e) {
        (t = l.memoizedState),
            (a = a(e, t)),
            (a = a == null ? t : B({}, t, a)),
            (l.memoizedState = a),
            l.lanes === 0 && (l.updateQueue.baseState = a);
    }
    var uf = {
        enqueueSetState: function (l, t, a) {
            l = l._reactInternals;
            var e = tt(),
                u = Wt(e);
            (u.payload = t), a != null && (u.callback = a), (t = $t(l, u, e)), t !== null && (at(t, l, e), Le(t, l, e));
        },
        enqueueReplaceState: function (l, t, a) {
            l = l._reactInternals;
            var e = tt(),
                u = Wt(e);
            (u.tag = 1),
                (u.payload = t),
                a != null && (u.callback = a),
                (t = $t(l, u, e)),
                t !== null && (at(t, l, e), Le(t, l, e));
        },
        enqueueForceUpdate: function (l, t) {
            l = l._reactInternals;
            var a = tt(),
                e = Wt(a);
            (e.tag = 2), t != null && (e.callback = t), (t = $t(l, e, a)), t !== null && (at(t, l, a), Le(t, l, a));
        },
    };
    function ms(l, t, a, e, u, n, c) {
        return (
            (l = l.stateNode),
            typeof l.shouldComponentUpdate == "function"
                ? l.shouldComponentUpdate(e, n, c)
                : t.prototype && t.prototype.isPureReactComponent
                  ? !He(a, e) || !He(u, n)
                  : !0
        );
    }
    function gs(l, t, a, e) {
        (l = t.state),
            typeof t.componentWillReceiveProps == "function" && t.componentWillReceiveProps(a, e),
            typeof t.UNSAFE_componentWillReceiveProps == "function" && t.UNSAFE_componentWillReceiveProps(a, e),
            t.state !== l && uf.enqueueReplaceState(t, t.state, null);
    }
    function ja(l, t) {
        var a = t;
        if ("ref" in t) {
            a = {};
            for (var e in t) e !== "ref" && (a[e] = t[e]);
        }
        if ((l = l.defaultProps)) {
            a === t && (a = B({}, a));
            for (var u in l) a[u] === void 0 && (a[u] = l[u]);
        }
        return a;
    }
    var fn =
        typeof reportError == "function"
            ? reportError
            : function (l) {
                  if (typeof window == "object" && typeof window.ErrorEvent == "function") {
                      var t = new window.ErrorEvent("error", {
                          bubbles: !0,
                          cancelable: !0,
                          message:
                              typeof l == "object" && l !== null && typeof l.message == "string"
                                  ? String(l.message)
                                  : String(l),
                          error: l,
                      });
                      if (!window.dispatchEvent(t)) return;
                  } else if (typeof process == "object" && typeof process.emit == "function") {
                      process.emit("uncaughtException", l);
                      return;
                  }
                  console.error(l);
              };
    function bs(l) {
        fn(l);
    }
    function Ss(l) {
        console.error(l);
    }
    function xs(l) {
        fn(l);
    }
    function sn(l, t) {
        try {
            var a = l.onUncaughtError;
            a(t.value, { componentStack: t.stack });
        } catch (e) {
            setTimeout(function () {
                throw e;
            });
        }
    }
    function Ts(l, t, a) {
        try {
            var e = l.onCaughtError;
            e(a.value, { componentStack: a.stack, errorBoundary: t.tag === 1 ? t.stateNode : null });
        } catch (u) {
            setTimeout(function () {
                throw u;
            });
        }
    }
    function nf(l, t, a) {
        return (
            (a = Wt(a)),
            (a.tag = 3),
            (a.payload = { element: null }),
            (a.callback = function () {
                sn(l, t);
            }),
            a
        );
    }
    function Es(l) {
        return (l = Wt(l)), (l.tag = 3), l;
    }
    function ps(l, t, a, e) {
        var u = a.type.getDerivedStateFromError;
        if (typeof u == "function") {
            var n = e.value;
            (l.payload = function () {
                return u(n);
            }),
                (l.callback = function () {
                    Ts(t, a, e);
                });
        }
        var c = a.stateNode;
        c !== null &&
            typeof c.componentDidCatch == "function" &&
            (l.callback = function () {
                Ts(t, a, e), typeof u != "function" && (na === null ? (na = new Set([this])) : na.add(this));
                var f = e.stack;
                this.componentDidCatch(e.value, { componentStack: f !== null ? f : "" });
            });
    }
    function Wo(l, t, a, e, u) {
        if (((a.flags |= 32768), e !== null && typeof e == "object" && typeof e.then == "function")) {
            if (((t = a.alternate), t !== null && Ge(t, a, u, !0), (a = st.current), a !== null)) {
                switch (a.tag) {
                    case 13:
                        return (
                            Et === null ? Df() : a.alternate === null && vl === 0 && (vl = 3),
                            (a.flags &= -257),
                            (a.flags |= 65536),
                            (a.lanes = u),
                            e === Hc
                                ? (a.flags |= 16384)
                                : ((t = a.updateQueue),
                                  t === null ? (a.updateQueue = new Set([e])) : t.add(e),
                                  Uf(l, e, u)),
                            !1
                        );
                    case 22:
                        return (
                            (a.flags |= 65536),
                            e === Hc
                                ? (a.flags |= 16384)
                                : ((t = a.updateQueue),
                                  t === null
                                      ? ((t = { transitions: null, markerInstances: null, retryQueue: new Set([e]) }),
                                        (a.updateQueue = t))
                                      : ((a = t.retryQueue), a === null ? (t.retryQueue = new Set([e])) : a.add(e)),
                                  Uf(l, e, u)),
                            !1
                        );
                }
                throw Error(r(435, a.tag));
            }
            return Uf(l, e, u), Df(), !1;
        }
        if (I)
            return (
                (t = st.current),
                t !== null
                    ? ((t.flags & 65536) === 0 && (t.flags |= 256),
                      (t.flags |= 65536),
                      (t.lanes = u),
                      e !== Mc && ((l = Error(r(422), { cause: e })), Ye(nt(l, a))))
                    : (e !== Mc && ((t = Error(r(423), { cause: e })), Ye(nt(t, a))),
                      (l = l.current.alternate),
                      (l.flags |= 65536),
                      (u &= -u),
                      (l.lanes |= u),
                      (e = nt(e, a)),
                      (u = nf(l.stateNode, e, u)),
                      qc(l, u),
                      vl !== 4 && (vl = 2)),
                !1
            );
        var n = Error(r(520), { cause: e });
        if (((n = nt(n, a)), nu === null ? (nu = [n]) : nu.push(n), vl !== 4 && (vl = 2), t === null)) return !0;
        (e = nt(e, a)), (a = t);
        do {
            switch (a.tag) {
                case 3:
                    return (a.flags |= 65536), (l = u & -u), (a.lanes |= l), (l = nf(a.stateNode, e, l)), qc(a, l), !1;
                case 1:
                    if (
                        ((t = a.type),
                        (n = a.stateNode),
                        (a.flags & 128) === 0 &&
                            (typeof t.getDerivedStateFromError == "function" ||
                                (n !== null &&
                                    typeof n.componentDidCatch == "function" &&
                                    (na === null || !na.has(n)))))
                    )
                        return (a.flags |= 65536), (u &= -u), (a.lanes |= u), (u = Es(u)), ps(u, l, a, e), qc(a, u), !1;
            }
            a = a.return;
        } while (a !== null);
        return !1;
    }
    var As = Error(r(461)),
        El = !1;
    function zl(l, t, a, e) {
        t.child = l === null ? vs(t, null, a, e) : ie(t, l.child, a, e);
    }
    function zs(l, t, a, e, u) {
        a = a.render;
        var n = t.ref;
        if ("ref" in e) {
            var c = {};
            for (var f in e) f !== "ref" && (c[f] = e[f]);
        } else c = e;
        return (
            Na(t),
            (e = Zc(l, t, a, c, n, u)),
            (f = Vc()),
            l !== null && !El ? (Lc(l, t, u), qt(l, t, u)) : (I && f && zc(t), (t.flags |= 1), zl(l, t, e, u), t.child)
        );
    }
    function Os(l, t, a, e, u) {
        if (l === null) {
            var n = a.type;
            return typeof n == "function" && !Ec(n) && n.defaultProps === void 0 && a.compare === null
                ? ((t.tag = 15), (t.type = n), Ms(l, t, n, e, u))
                : ((l = Qu(a.type, null, e, t, t.mode, u)), (l.ref = t.ref), (l.return = t), (t.child = l));
        }
        if (((n = l.child), !vf(l, u))) {
            var c = n.memoizedProps;
            if (((a = a.compare), (a = a !== null ? a : He), a(c, e) && l.ref === t.ref)) return qt(l, t, u);
        }
        return (t.flags |= 1), (l = Dt(n, e)), (l.ref = t.ref), (l.return = t), (t.child = l);
    }
    function Ms(l, t, a, e, u) {
        if (l !== null) {
            var n = l.memoizedProps;
            if (He(n, e) && l.ref === t.ref)
                if (((El = !1), (t.pendingProps = e = n), vf(l, u))) (l.flags & 131072) !== 0 && (El = !0);
                else return (t.lanes = l.lanes), qt(l, t, u);
        }
        return cf(l, t, a, e, u);
    }
    function Ns(l, t, a) {
        var e = t.pendingProps,
            u = e.children,
            n = l !== null ? l.memoizedState : null;
        if (e.mode === "hidden") {
            if ((t.flags & 128) !== 0) {
                if (((e = n !== null ? n.baseLanes | a : a), l !== null)) {
                    for (u = t.child = l.child, n = 0; u !== null; ) (n = n | u.lanes | u.childLanes), (u = u.sibling);
                    t.childLanes = n & ~e;
                } else (t.childLanes = 0), (t.child = null);
                return _s(l, t, e, a);
            }
            if ((a & 536870912) !== 0)
                (t.memoizedState = { baseLanes: 0, cachePool: null }),
                    l !== null && Ku(t, n !== null ? n.cachePool : null),
                    n !== null ? M0(t, n) : Gc(),
                    ys(t);
            else return (t.lanes = t.childLanes = 536870912), _s(l, t, n !== null ? n.baseLanes | a : a, a);
        } else
            n !== null
                ? (Ku(t, n.cachePool), M0(t, n), It(), (t.memoizedState = null))
                : (l !== null && Ku(t, null), Gc(), It());
        return zl(l, t, u, a), t.child;
    }
    function _s(l, t, a, e) {
        var u = Rc();
        return (
            (u = u === null ? null : { parent: Sl._currentValue, pool: u }),
            (t.memoizedState = { baseLanes: a, cachePool: u }),
            l !== null && Ku(t, null),
            Gc(),
            ys(t),
            l !== null && Ge(l, t, e, !0),
            null
        );
    }
    function rn(l, t) {
        var a = t.ref;
        if (a === null) l !== null && l.ref !== null && (t.flags |= 4194816);
        else {
            if (typeof a != "function" && typeof a != "object") throw Error(r(284));
            (l === null || l.ref !== a) && (t.flags |= 4194816);
        }
    }
    function cf(l, t, a, e, u) {
        return (
            Na(t),
            (a = Zc(l, t, a, e, void 0, u)),
            (e = Vc()),
            l !== null && !El ? (Lc(l, t, u), qt(l, t, u)) : (I && e && zc(t), (t.flags |= 1), zl(l, t, a, u), t.child)
        );
    }
    function Ds(l, t, a, e, u, n) {
        return (
            Na(t),
            (t.updateQueue = null),
            (a = _0(t, e, a, u)),
            N0(l),
            (e = Vc()),
            l !== null && !El ? (Lc(l, t, n), qt(l, t, n)) : (I && e && zc(t), (t.flags |= 1), zl(l, t, a, n), t.child)
        );
    }
    function js(l, t, a, e, u) {
        if ((Na(t), t.stateNode === null)) {
            var n = Pa,
                c = a.contextType;
            typeof c == "object" && c !== null && (n = Ul(c)),
                (n = new a(e, n)),
                (t.memoizedState = n.state !== null && n.state !== void 0 ? n.state : null),
                (n.updater = uf),
                (t.stateNode = n),
                (n._reactInternals = t),
                (n = t.stateNode),
                (n.props = e),
                (n.state = t.memoizedState),
                (n.refs = {}),
                Bc(t),
                (c = a.contextType),
                (n.context = typeof c == "object" && c !== null ? Ul(c) : Pa),
                (n.state = t.memoizedState),
                (c = a.getDerivedStateFromProps),
                typeof c == "function" && (ef(t, a, c, e), (n.state = t.memoizedState)),
                typeof a.getDerivedStateFromProps == "function" ||
                    typeof n.getSnapshotBeforeUpdate == "function" ||
                    (typeof n.UNSAFE_componentWillMount != "function" && typeof n.componentWillMount != "function") ||
                    ((c = n.state),
                    typeof n.componentWillMount == "function" && n.componentWillMount(),
                    typeof n.UNSAFE_componentWillMount == "function" && n.UNSAFE_componentWillMount(),
                    c !== n.state && uf.enqueueReplaceState(n, n.state, null),
                    Ke(t, e, n, u),
                    we(),
                    (n.state = t.memoizedState)),
                typeof n.componentDidMount == "function" && (t.flags |= 4194308),
                (e = !0);
        } else if (l === null) {
            n = t.stateNode;
            var f = t.memoizedProps,
                i = ja(a, f);
            n.props = i;
            var y = n.context,
                T = a.contextType;
            (c = Pa), typeof T == "object" && T !== null && (c = Ul(T));
            var A = a.getDerivedStateFromProps;
            (T = typeof A == "function" || typeof n.getSnapshotBeforeUpdate == "function"),
                (f = t.pendingProps !== f),
                T ||
                    (typeof n.UNSAFE_componentWillReceiveProps != "function" &&
                        typeof n.componentWillReceiveProps != "function") ||
                    ((f || y !== c) && gs(t, n, e, c)),
                (Ft = !1);
            var m = t.memoizedState;
            (n.state = m),
                Ke(t, e, n, u),
                we(),
                (y = t.memoizedState),
                f || m !== y || Ft
                    ? (typeof A == "function" && (ef(t, a, A, e), (y = t.memoizedState)),
                      (i = Ft || ms(t, a, i, e, m, y, c))
                          ? (T ||
                                (typeof n.UNSAFE_componentWillMount != "function" &&
                                    typeof n.componentWillMount != "function") ||
                                (typeof n.componentWillMount == "function" && n.componentWillMount(),
                                typeof n.UNSAFE_componentWillMount == "function" && n.UNSAFE_componentWillMount()),
                            typeof n.componentDidMount == "function" && (t.flags |= 4194308))
                          : (typeof n.componentDidMount == "function" && (t.flags |= 4194308),
                            (t.memoizedProps = e),
                            (t.memoizedState = y)),
                      (n.props = e),
                      (n.state = y),
                      (n.context = c),
                      (e = i))
                    : (typeof n.componentDidMount == "function" && (t.flags |= 4194308), (e = !1));
        } else {
            (n = t.stateNode),
                Cc(l, t),
                (c = t.memoizedProps),
                (T = ja(a, c)),
                (n.props = T),
                (A = t.pendingProps),
                (m = n.context),
                (y = a.contextType),
                (i = Pa),
                typeof y == "object" && y !== null && (i = Ul(y)),
                (f = a.getDerivedStateFromProps),
                (y = typeof f == "function" || typeof n.getSnapshotBeforeUpdate == "function") ||
                    (typeof n.UNSAFE_componentWillReceiveProps != "function" &&
                        typeof n.componentWillReceiveProps != "function") ||
                    ((c !== A || m !== i) && gs(t, n, e, i)),
                (Ft = !1),
                (m = t.memoizedState),
                (n.state = m),
                Ke(t, e, n, u),
                we();
            var g = t.memoizedState;
            c !== A || m !== g || Ft || (l !== null && l.dependencies !== null && Lu(l.dependencies))
                ? (typeof f == "function" && (ef(t, a, f, e), (g = t.memoizedState)),
                  (T = Ft || ms(t, a, T, e, m, g, i) || (l !== null && l.dependencies !== null && Lu(l.dependencies)))
                      ? (y ||
                            (typeof n.UNSAFE_componentWillUpdate != "function" &&
                                typeof n.componentWillUpdate != "function") ||
                            (typeof n.componentWillUpdate == "function" && n.componentWillUpdate(e, g, i),
                            typeof n.UNSAFE_componentWillUpdate == "function" && n.UNSAFE_componentWillUpdate(e, g, i)),
                        typeof n.componentDidUpdate == "function" && (t.flags |= 4),
                        typeof n.getSnapshotBeforeUpdate == "function" && (t.flags |= 1024))
                      : (typeof n.componentDidUpdate != "function" ||
                            (c === l.memoizedProps && m === l.memoizedState) ||
                            (t.flags |= 4),
                        typeof n.getSnapshotBeforeUpdate != "function" ||
                            (c === l.memoizedProps && m === l.memoizedState) ||
                            (t.flags |= 1024),
                        (t.memoizedProps = e),
                        (t.memoizedState = g)),
                  (n.props = e),
                  (n.state = g),
                  (n.context = i),
                  (e = T))
                : (typeof n.componentDidUpdate != "function" ||
                      (c === l.memoizedProps && m === l.memoizedState) ||
                      (t.flags |= 4),
                  typeof n.getSnapshotBeforeUpdate != "function" ||
                      (c === l.memoizedProps && m === l.memoizedState) ||
                      (t.flags |= 1024),
                  (e = !1));
        }
        return (
            (n = e),
            rn(l, t),
            (e = (t.flags & 128) !== 0),
            n || e
                ? ((n = t.stateNode),
                  (a = e && typeof a.getDerivedStateFromError != "function" ? null : n.render()),
                  (t.flags |= 1),
                  l !== null && e
                      ? ((t.child = ie(t, l.child, null, u)), (t.child = ie(t, null, a, u)))
                      : zl(l, t, a, u),
                  (t.memoizedState = n.state),
                  (l = t.child))
                : (l = qt(l, t, u)),
            l
        );
    }
    function Us(l, t, a, e) {
        return qe(), (t.flags |= 256), zl(l, t, a, e), t.child;
    }
    var ff = { dehydrated: null, treeContext: null, retryLane: 0, hydrationErrors: null };
    function sf(l) {
        return { baseLanes: l, cachePool: S0() };
    }
    function rf(l, t, a) {
        return (l = l !== null ? l.childLanes & ~a : 0), t && (l |= rt), l;
    }
    function Rs(l, t, a) {
        var e = t.pendingProps,
            u = !1,
            n = (t.flags & 128) !== 0,
            c;
        if (
            ((c = n) || (c = l !== null && l.memoizedState === null ? !1 : (xl.current & 2) !== 0),
            c && ((u = !0), (t.flags &= -129)),
            (c = (t.flags & 32) !== 0),
            (t.flags &= -33),
            l === null)
        ) {
            if (I) {
                if ((u ? Pt(t) : It(), I)) {
                    var f = hl,
                        i;
                    if ((i = f)) {
                        l: {
                            for (i = f, f = Tt; i.nodeType !== 8; ) {
                                if (!f) {
                                    f = null;
                                    break l;
                                }
                                if (((i = bt(i.nextSibling)), i === null)) {
                                    f = null;
                                    break l;
                                }
                            }
                            f = i;
                        }
                        f !== null
                            ? ((t.memoizedState = {
                                  dehydrated: f,
                                  treeContext: pa !== null ? { id: jt, overflow: Ut } : null,
                                  retryLane: 536870912,
                                  hydrationErrors: null,
                              }),
                              (i = kl(18, null, null, 0)),
                              (i.stateNode = f),
                              (i.return = t),
                              (t.child = i),
                              (Cl = t),
                              (hl = null),
                              (i = !0))
                            : (i = !1);
                    }
                    i || Oa(t);
                }
                if (((f = t.memoizedState), f !== null && ((f = f.dehydrated), f !== null)))
                    return Jf(f) ? (t.lanes = 32) : (t.lanes = 536870912), null;
                Ct(t);
            }
            return (
                (f = e.children),
                (e = e.fallback),
                u
                    ? (It(),
                      (u = t.mode),
                      (f = on({ mode: "hidden", children: f }, u)),
                      (e = Ea(e, u, a, null)),
                      (f.return = t),
                      (e.return = t),
                      (f.sibling = e),
                      (t.child = f),
                      (u = t.child),
                      (u.memoizedState = sf(a)),
                      (u.childLanes = rf(l, c, a)),
                      (t.memoizedState = ff),
                      e)
                    : (Pt(t), of(t, f))
            );
        }
        if (((i = l.memoizedState), i !== null && ((f = i.dehydrated), f !== null))) {
            if (n)
                t.flags & 256
                    ? (Pt(t), (t.flags &= -257), (t = df(l, t, a)))
                    : t.memoizedState !== null
                      ? (It(), (t.child = l.child), (t.flags |= 128), (t = null))
                      : (It(),
                        (u = e.fallback),
                        (f = t.mode),
                        (e = on({ mode: "visible", children: e.children }, f)),
                        (u = Ea(u, f, a, null)),
                        (u.flags |= 2),
                        (e.return = t),
                        (u.return = t),
                        (e.sibling = u),
                        (t.child = e),
                        ie(t, l.child, null, a),
                        (e = t.child),
                        (e.memoizedState = sf(a)),
                        (e.childLanes = rf(l, c, a)),
                        (t.memoizedState = ff),
                        (t = u));
            else if ((Pt(t), Jf(f))) {
                if (((c = f.nextSibling && f.nextSibling.dataset), c)) var y = c.dgst;
                (c = y),
                    (e = Error(r(419))),
                    (e.stack = ""),
                    (e.digest = c),
                    Ye({ value: e, source: null, stack: null }),
                    (t = df(l, t, a));
            } else if ((El || Ge(l, t, a, !1), (c = (a & l.childLanes) !== 0), El || c)) {
                if (
                    ((c = il),
                    c !== null &&
                        ((e = a & -a),
                        (e = (e & 42) !== 0 ? 1 : Jn(e)),
                        (e = (e & (c.suspendedLanes | a)) !== 0 ? 0 : e),
                        e !== 0 && e !== i.retryLane))
                )
                    throw ((i.retryLane = e), ka(l, e), at(c, l, e), As);
                f.data === "$?" || Df(), (t = df(l, t, a));
            } else
                f.data === "$?"
                    ? ((t.flags |= 192), (t.child = l.child), (t = null))
                    : ((l = i.treeContext),
                      (hl = bt(f.nextSibling)),
                      (Cl = t),
                      (I = !0),
                      (za = null),
                      (Tt = !1),
                      l !== null &&
                          ((ft[it++] = jt), (ft[it++] = Ut), (ft[it++] = pa), (jt = l.id), (Ut = l.overflow), (pa = t)),
                      (t = of(t, e.children)),
                      (t.flags |= 4096));
            return t;
        }
        return u
            ? (It(),
              (u = e.fallback),
              (f = t.mode),
              (i = l.child),
              (y = i.sibling),
              (e = Dt(i, { mode: "hidden", children: e.children })),
              (e.subtreeFlags = i.subtreeFlags & 65011712),
              y !== null ? (u = Dt(y, u)) : ((u = Ea(u, f, a, null)), (u.flags |= 2)),
              (u.return = t),
              (e.return = t),
              (e.sibling = u),
              (t.child = e),
              (e = u),
              (u = t.child),
              (f = l.child.memoizedState),
              f === null
                  ? (f = sf(a))
                  : ((i = f.cachePool),
                    i !== null
                        ? ((y = Sl._currentValue), (i = i.parent !== y ? { parent: y, pool: y } : i))
                        : (i = S0()),
                    (f = { baseLanes: f.baseLanes | a, cachePool: i })),
              (u.memoizedState = f),
              (u.childLanes = rf(l, c, a)),
              (t.memoizedState = ff),
              e)
            : (Pt(t),
              (a = l.child),
              (l = a.sibling),
              (a = Dt(a, { mode: "visible", children: e.children })),
              (a.return = t),
              (a.sibling = null),
              l !== null && ((c = t.deletions), c === null ? ((t.deletions = [l]), (t.flags |= 16)) : c.push(l)),
              (t.child = a),
              (t.memoizedState = null),
              a);
    }
    function of(l, t) {
        return (t = on({ mode: "visible", children: t }, l.mode)), (t.return = l), (l.child = t);
    }
    function on(l, t) {
        return (
            (l = kl(22, l, null, t)),
            (l.lanes = 0),
            (l.stateNode = { _visibility: 1, _pendingMarkers: null, _retryCache: null, _transitions: null }),
            l
        );
    }
    function df(l, t, a) {
        return (
            ie(t, l.child, null, a), (l = of(t, t.pendingProps.children)), (l.flags |= 2), (t.memoizedState = null), l
        );
    }
    function Hs(l, t, a) {
        l.lanes |= t;
        var e = l.alternate;
        e !== null && (e.lanes |= t), _c(l.return, t, a);
    }
    function hf(l, t, a, e, u) {
        var n = l.memoizedState;
        n === null
            ? (l.memoizedState = {
                  isBackwards: t,
                  rendering: null,
                  renderingStartTime: 0,
                  last: e,
                  tail: a,
                  tailMode: u,
              })
            : ((n.isBackwards = t),
              (n.rendering = null),
              (n.renderingStartTime = 0),
              (n.last = e),
              (n.tail = a),
              (n.tailMode = u));
    }
    function Bs(l, t, a) {
        var e = t.pendingProps,
            u = e.revealOrder,
            n = e.tail;
        if ((zl(l, t, e.children, a), (e = xl.current), (e & 2) !== 0)) (e = (e & 1) | 2), (t.flags |= 128);
        else {
            if (l !== null && (l.flags & 128) !== 0)
                l: for (l = t.child; l !== null; ) {
                    if (l.tag === 13) l.memoizedState !== null && Hs(l, a, t);
                    else if (l.tag === 19) Hs(l, a, t);
                    else if (l.child !== null) {
                        (l.child.return = l), (l = l.child);
                        continue;
                    }
                    if (l === t) break l;
                    for (; l.sibling === null; ) {
                        if (l.return === null || l.return === t) break l;
                        l = l.return;
                    }
                    (l.sibling.return = l.return), (l = l.sibling);
                }
            e &= 1;
        }
        switch ((N(xl, e), u)) {
            case "forwards":
                for (a = t.child, u = null; a !== null; )
                    (l = a.alternate), l !== null && cn(l) === null && (u = a), (a = a.sibling);
                (a = u),
                    a === null ? ((u = t.child), (t.child = null)) : ((u = a.sibling), (a.sibling = null)),
                    hf(t, !1, u, a, n);
                break;
            case "backwards":
                for (a = null, u = t.child, t.child = null; u !== null; ) {
                    if (((l = u.alternate), l !== null && cn(l) === null)) {
                        t.child = u;
                        break;
                    }
                    (l = u.sibling), (u.sibling = a), (a = u), (u = l);
                }
                hf(t, !0, a, null, n);
                break;
            case "together":
                hf(t, !1, null, null, void 0);
                break;
            default:
                t.memoizedState = null;
        }
        return t.child;
    }
    function qt(l, t, a) {
        if ((l !== null && (t.dependencies = l.dependencies), (ua |= t.lanes), (a & t.childLanes) === 0))
            if (l !== null) {
                if ((Ge(l, t, a, !1), (a & t.childLanes) === 0)) return null;
            } else return null;
        if (l !== null && t.child !== l.child) throw Error(r(153));
        if (t.child !== null) {
            for (l = t.child, a = Dt(l, l.pendingProps), t.child = a, a.return = t; l.sibling !== null; )
                (l = l.sibling), (a = a.sibling = Dt(l, l.pendingProps)), (a.return = t);
            a.sibling = null;
        }
        return t.child;
    }
    function vf(l, t) {
        return (l.lanes & t) !== 0 ? !0 : ((l = l.dependencies), !!(l !== null && Lu(l)));
    }
    function $o(l, t, a) {
        switch (t.tag) {
            case 3:
                rl(t, t.stateNode.containerInfo), Jt(t, Sl, l.memoizedState.cache), qe();
                break;
            case 27:
            case 5:
                Zn(t);
                break;
            case 4:
                rl(t, t.stateNode.containerInfo);
                break;
            case 10:
                Jt(t, t.type, t.memoizedProps.value);
                break;
            case 13:
                var e = t.memoizedState;
                if (e !== null)
                    return e.dehydrated !== null
                        ? (Pt(t), (t.flags |= 128), null)
                        : (a & t.child.childLanes) !== 0
                          ? Rs(l, t, a)
                          : (Pt(t), (l = qt(l, t, a)), l !== null ? l.sibling : null);
                Pt(t);
                break;
            case 19:
                var u = (l.flags & 128) !== 0;
                if (((e = (a & t.childLanes) !== 0), e || (Ge(l, t, a, !1), (e = (a & t.childLanes) !== 0)), u)) {
                    if (e) return Bs(l, t, a);
                    t.flags |= 128;
                }
                if (
                    ((u = t.memoizedState),
                    u !== null && ((u.rendering = null), (u.tail = null), (u.lastEffect = null)),
                    N(xl, xl.current),
                    e)
                )
                    break;
                return null;
            case 22:
            case 23:
                return (t.lanes = 0), Ns(l, t, a);
            case 24:
                Jt(t, Sl, l.memoizedState.cache);
        }
        return qt(l, t, a);
    }
    function Cs(l, t, a) {
        if (l !== null)
            if (l.memoizedProps !== t.pendingProps) El = !0;
            else {
                if (!vf(l, a) && (t.flags & 128) === 0) return (El = !1), $o(l, t, a);
                El = (l.flags & 131072) !== 0;
            }
        else (El = !1), I && (t.flags & 1048576) !== 0 && d0(t, Vu, t.index);
        switch (((t.lanes = 0), t.tag)) {
            case 16:
                l: {
                    l = t.pendingProps;
                    var e = t.elementType,
                        u = e._init;
                    if (((e = u(e._payload)), (t.type = e), typeof e == "function"))
                        Ec(e)
                            ? ((l = ja(e, l)), (t.tag = 1), (t = js(null, t, e, l, a)))
                            : ((t.tag = 0), (t = cf(null, t, e, l, a)));
                    else {
                        if (e != null) {
                            if (((u = e.$$typeof), u === yt)) {
                                (t.tag = 11), (t = zs(null, t, e, l, a));
                                break l;
                            } else if (u === wl) {
                                (t.tag = 14), (t = Os(null, t, e, l, a));
                                break l;
                            }
                        }
                        throw ((t = ma(e) || e), Error(r(306, t, "")));
                    }
                }
                return t;
            case 0:
                return cf(l, t, t.type, t.pendingProps, a);
            case 1:
                return (e = t.type), (u = ja(e, t.pendingProps)), js(l, t, e, u, a);
            case 3:
                l: {
                    if ((rl(t, t.stateNode.containerInfo), l === null)) throw Error(r(387));
                    e = t.pendingProps;
                    var n = t.memoizedState;
                    (u = n.element), Cc(l, t), Ke(t, e, null, a);
                    var c = t.memoizedState;
                    if (
                        ((e = c.cache),
                        Jt(t, Sl, e),
                        e !== n.cache && Dc(t, [Sl], a, !0),
                        we(),
                        (e = c.element),
                        n.isDehydrated)
                    )
                        if (
                            ((n = { element: e, isDehydrated: !1, cache: c.cache }),
                            (t.updateQueue.baseState = n),
                            (t.memoizedState = n),
                            t.flags & 256)
                        ) {
                            t = Us(l, t, e, a);
                            break l;
                        } else if (e !== u) {
                            (u = nt(Error(r(424)), t)), Ye(u), (t = Us(l, t, e, a));
                            break l;
                        } else {
                            switch (((l = t.stateNode.containerInfo), l.nodeType)) {
                                case 9:
                                    l = l.body;
                                    break;
                                default:
                                    l = l.nodeName === "HTML" ? l.ownerDocument.body : l;
                            }
                            for (
                                hl = bt(l.firstChild),
                                    Cl = t,
                                    I = !0,
                                    za = null,
                                    Tt = !0,
                                    a = vs(t, null, e, a),
                                    t.child = a;
                                a;

                            )
                                (a.flags = (a.flags & -3) | 4096), (a = a.sibling);
                        }
                    else {
                        if ((qe(), e === u)) {
                            t = qt(l, t, a);
                            break l;
                        }
                        zl(l, t, e, a);
                    }
                    t = t.child;
                }
                return t;
            case 26:
                return (
                    rn(l, t),
                    l === null
                        ? (a = X1(t.type, null, t.pendingProps, null))
                            ? (t.memoizedState = a)
                            : I ||
                              ((a = t.type),
                              (l = t.pendingProps),
                              (e = zn(Q.current).createElement(a)),
                              (e[jl] = t),
                              (e[Gl] = l),
                              Ml(e, a, l),
                              Tl(e),
                              (t.stateNode = e))
                        : (t.memoizedState = X1(t.type, l.memoizedProps, t.pendingProps, l.memoizedState)),
                    null
                );
            case 27:
                return (
                    Zn(t),
                    l === null &&
                        I &&
                        ((e = t.stateNode = q1(t.type, t.pendingProps, Q.current)),
                        (Cl = t),
                        (Tt = !0),
                        (u = hl),
                        ia(t.type) ? ((Ff = u), (hl = bt(e.firstChild))) : (hl = u)),
                    zl(l, t, t.pendingProps.children, a),
                    rn(l, t),
                    l === null && (t.flags |= 4194304),
                    t.child
                );
            case 5:
                return (
                    l === null &&
                        I &&
                        ((u = e = hl) &&
                            ((e = Ad(e, t.type, t.pendingProps, Tt)),
                            e !== null
                                ? ((t.stateNode = e), (Cl = t), (hl = bt(e.firstChild)), (Tt = !1), (u = !0))
                                : (u = !1)),
                        u || Oa(t)),
                    Zn(t),
                    (u = t.type),
                    (n = t.pendingProps),
                    (c = l !== null ? l.memoizedProps : null),
                    (e = n.children),
                    Lf(u, n) ? (e = null) : c !== null && Lf(u, c) && (t.flags |= 32),
                    t.memoizedState !== null && ((u = Zc(l, t, Zo, null, null, a)), (vu._currentValue = u)),
                    rn(l, t),
                    zl(l, t, e, a),
                    t.child
                );
            case 6:
                return (
                    l === null &&
                        I &&
                        ((l = a = hl) &&
                            ((a = zd(a, t.pendingProps, Tt)),
                            a !== null ? ((t.stateNode = a), (Cl = t), (hl = null), (l = !0)) : (l = !1)),
                        l || Oa(t)),
                    null
                );
            case 13:
                return Rs(l, t, a);
            case 4:
                return (
                    rl(t, t.stateNode.containerInfo),
                    (e = t.pendingProps),
                    l === null ? (t.child = ie(t, null, e, a)) : zl(l, t, e, a),
                    t.child
                );
            case 11:
                return zs(l, t, t.type, t.pendingProps, a);
            case 7:
                return zl(l, t, t.pendingProps, a), t.child;
            case 8:
                return zl(l, t, t.pendingProps.children, a), t.child;
            case 12:
                return zl(l, t, t.pendingProps.children, a), t.child;
            case 10:
                return (e = t.pendingProps), Jt(t, t.type, e.value), zl(l, t, e.children, a), t.child;
            case 9:
                return (
                    (u = t.type._context),
                    (e = t.pendingProps.children),
                    Na(t),
                    (u = Ul(u)),
                    (e = e(u)),
                    (t.flags |= 1),
                    zl(l, t, e, a),
                    t.child
                );
            case 14:
                return Os(l, t, t.type, t.pendingProps, a);
            case 15:
                return Ms(l, t, t.type, t.pendingProps, a);
            case 19:
                return Bs(l, t, a);
            case 31:
                return (
                    (e = t.pendingProps),
                    (a = t.mode),
                    (e = { mode: e.mode, children: e.children }),
                    l === null
                        ? ((a = on(e, a)), (a.ref = t.ref), (t.child = a), (a.return = t), (t = a))
                        : ((a = Dt(l.child, e)), (a.ref = t.ref), (t.child = a), (a.return = t), (t = a)),
                    t
                );
            case 22:
                return Ns(l, t, a);
            case 24:
                return (
                    Na(t),
                    (e = Ul(Sl)),
                    l === null
                        ? ((u = Rc()),
                          u === null &&
                              ((u = il),
                              (n = jc()),
                              (u.pooledCache = n),
                              n.refCount++,
                              n !== null && (u.pooledCacheLanes |= a),
                              (u = n)),
                          (t.memoizedState = { parent: e, cache: u }),
                          Bc(t),
                          Jt(t, Sl, u))
                        : ((l.lanes & a) !== 0 && (Cc(l, t), Ke(t, null, null, a), we()),
                          (u = l.memoizedState),
                          (n = t.memoizedState),
                          u.parent !== e
                              ? ((u = { parent: e, cache: e }),
                                (t.memoizedState = u),
                                t.lanes === 0 && (t.memoizedState = t.updateQueue.baseState = u),
                                Jt(t, Sl, e))
                              : ((e = n.cache), Jt(t, Sl, e), e !== u.cache && Dc(t, [Sl], a, !0))),
                    zl(l, t, t.pendingProps.children, a),
                    t.child
                );
            case 29:
                throw t.pendingProps;
        }
        throw Error(r(156, t.tag));
    }
    function Yt(l) {
        l.flags |= 4;
    }
    function qs(l, t) {
        if (t.type !== "stylesheet" || (t.state.loading & 4) !== 0) l.flags &= -16777217;
        else if (((l.flags |= 16777216), !w1(t))) {
            if (
                ((t = st.current),
                t !== null &&
                    ((F & 4194048) === F ? Et !== null : ((F & 62914560) !== F && (F & 536870912) === 0) || t !== Et))
            )
                throw ((Ve = Hc), x0);
            l.flags |= 8192;
        }
    }
    function dn(l, t) {
        t !== null && (l.flags |= 4),
            l.flags & 16384 && ((t = l.tag !== 22 ? yi() : 536870912), (l.lanes |= t), (de |= t));
    }
    function Ie(l, t) {
        if (!I)
            switch (l.tailMode) {
                case "hidden":
                    t = l.tail;
                    for (var a = null; t !== null; ) t.alternate !== null && (a = t), (t = t.sibling);
                    a === null ? (l.tail = null) : (a.sibling = null);
                    break;
                case "collapsed":
                    a = l.tail;
                    for (var e = null; a !== null; ) a.alternate !== null && (e = a), (a = a.sibling);
                    e === null
                        ? t || l.tail === null
                            ? (l.tail = null)
                            : (l.tail.sibling = null)
                        : (e.sibling = null);
            }
    }
    function dl(l) {
        var t = l.alternate !== null && l.alternate.child === l.child,
            a = 0,
            e = 0;
        if (t)
            for (var u = l.child; u !== null; )
                (a |= u.lanes | u.childLanes),
                    (e |= u.subtreeFlags & 65011712),
                    (e |= u.flags & 65011712),
                    (u.return = l),
                    (u = u.sibling);
        else
            for (u = l.child; u !== null; )
                (a |= u.lanes | u.childLanes), (e |= u.subtreeFlags), (e |= u.flags), (u.return = l), (u = u.sibling);
        return (l.subtreeFlags |= e), (l.childLanes = a), t;
    }
    function ko(l, t, a) {
        var e = t.pendingProps;
        switch ((Oc(t), t.tag)) {
            case 31:
            case 16:
            case 15:
            case 0:
            case 11:
            case 7:
            case 8:
            case 12:
            case 9:
            case 14:
                return dl(t), null;
            case 1:
                return dl(t), null;
            case 3:
                return (
                    (a = t.stateNode),
                    (e = null),
                    l !== null && (e = l.memoizedState.cache),
                    t.memoizedState.cache !== e && (t.flags |= 2048),
                    Ht(Sl),
                    Vt(),
                    a.pendingContext && ((a.context = a.pendingContext), (a.pendingContext = null)),
                    (l === null || l.child === null) &&
                        (Ce(t)
                            ? Yt(t)
                            : l === null ||
                              (l.memoizedState.isDehydrated && (t.flags & 256) === 0) ||
                              ((t.flags |= 1024), y0())),
                    dl(t),
                    null
                );
            case 26:
                return (
                    (a = t.memoizedState),
                    l === null
                        ? (Yt(t), a !== null ? (dl(t), qs(t, a)) : (dl(t), (t.flags &= -16777217)))
                        : a
                          ? a !== l.memoizedState
                              ? (Yt(t), dl(t), qs(t, a))
                              : (dl(t), (t.flags &= -16777217))
                          : (l.memoizedProps !== e && Yt(t), dl(t), (t.flags &= -16777217)),
                    null
                );
            case 27:
                Eu(t), (a = Q.current);
                var u = t.type;
                if (l !== null && t.stateNode != null) l.memoizedProps !== e && Yt(t);
                else {
                    if (!e) {
                        if (t.stateNode === null) throw Error(r(166));
                        return dl(t), null;
                    }
                    (l = C.current), Ce(t) ? h0(t) : ((l = q1(u, e, a)), (t.stateNode = l), Yt(t));
                }
                return dl(t), null;
            case 5:
                if ((Eu(t), (a = t.type), l !== null && t.stateNode != null)) l.memoizedProps !== e && Yt(t);
                else {
                    if (!e) {
                        if (t.stateNode === null) throw Error(r(166));
                        return dl(t), null;
                    }
                    if (((l = C.current), Ce(t))) h0(t);
                    else {
                        switch (((u = zn(Q.current)), l)) {
                            case 1:
                                l = u.createElementNS("http://www.w3.org/2000/svg", a);
                                break;
                            case 2:
                                l = u.createElementNS("http://www.w3.org/1998/Math/MathML", a);
                                break;
                            default:
                                switch (a) {
                                    case "svg":
                                        l = u.createElementNS("http://www.w3.org/2000/svg", a);
                                        break;
                                    case "math":
                                        l = u.createElementNS("http://www.w3.org/1998/Math/MathML", a);
                                        break;
                                    case "script":
                                        (l = u.createElement("div")),
                                            (l.innerHTML = "<script></script>"),
                                            (l = l.removeChild(l.firstChild));
                                        break;
                                    case "select":
                                        (l =
                                            typeof e.is == "string"
                                                ? u.createElement("select", { is: e.is })
                                                : u.createElement("select")),
                                            e.multiple ? (l.multiple = !0) : e.size && (l.size = e.size);
                                        break;
                                    default:
                                        l =
                                            typeof e.is == "string"
                                                ? u.createElement(a, { is: e.is })
                                                : u.createElement(a);
                                }
                        }
                        (l[jl] = t), (l[Gl] = e);
                        l: for (u = t.child; u !== null; ) {
                            if (u.tag === 5 || u.tag === 6) l.appendChild(u.stateNode);
                            else if (u.tag !== 4 && u.tag !== 27 && u.child !== null) {
                                (u.child.return = u), (u = u.child);
                                continue;
                            }
                            if (u === t) break l;
                            for (; u.sibling === null; ) {
                                if (u.return === null || u.return === t) break l;
                                u = u.return;
                            }
                            (u.sibling.return = u.return), (u = u.sibling);
                        }
                        t.stateNode = l;
                        l: switch ((Ml(l, a, e), a)) {
                            case "button":
                            case "input":
                            case "select":
                            case "textarea":
                                l = !!e.autoFocus;
                                break l;
                            case "img":
                                l = !0;
                                break l;
                            default:
                                l = !1;
                        }
                        l && Yt(t);
                    }
                }
                return dl(t), (t.flags &= -16777217), null;
            case 6:
                if (l && t.stateNode != null) l.memoizedProps !== e && Yt(t);
                else {
                    if (typeof e != "string" && t.stateNode === null) throw Error(r(166));
                    if (((l = Q.current), Ce(t))) {
                        if (((l = t.stateNode), (a = t.memoizedProps), (e = null), (u = Cl), u !== null))
                            switch (u.tag) {
                                case 27:
                                case 5:
                                    e = u.memoizedProps;
                            }
                        (l[jl] = t),
                            (l = !!(
                                l.nodeValue === a ||
                                (e !== null && e.suppressHydrationWarning === !0) ||
                                D1(l.nodeValue, a)
                            )),
                            l || Oa(t);
                    } else (l = zn(l).createTextNode(e)), (l[jl] = t), (t.stateNode = l);
                }
                return dl(t), null;
            case 13:
                if (
                    ((e = t.memoizedState),
                    l === null || (l.memoizedState !== null && l.memoizedState.dehydrated !== null))
                ) {
                    if (((u = Ce(t)), e !== null && e.dehydrated !== null)) {
                        if (l === null) {
                            if (!u) throw Error(r(318));
                            if (((u = t.memoizedState), (u = u !== null ? u.dehydrated : null), !u))
                                throw Error(r(317));
                            u[jl] = t;
                        } else qe(), (t.flags & 128) === 0 && (t.memoizedState = null), (t.flags |= 4);
                        dl(t), (u = !1);
                    } else
                        (u = y0()),
                            l !== null && l.memoizedState !== null && (l.memoizedState.hydrationErrors = u),
                            (u = !0);
                    if (!u) return t.flags & 256 ? (Ct(t), t) : (Ct(t), null);
                }
                if ((Ct(t), (t.flags & 128) !== 0)) return (t.lanes = a), t;
                if (((a = e !== null), (l = l !== null && l.memoizedState !== null), a)) {
                    (e = t.child),
                        (u = null),
                        e.alternate !== null &&
                            e.alternate.memoizedState !== null &&
                            e.alternate.memoizedState.cachePool !== null &&
                            (u = e.alternate.memoizedState.cachePool.pool);
                    var n = null;
                    e.memoizedState !== null &&
                        e.memoizedState.cachePool !== null &&
                        (n = e.memoizedState.cachePool.pool),
                        n !== u && (e.flags |= 2048);
                }
                return a !== l && a && (t.child.flags |= 8192), dn(t, t.updateQueue), dl(t), null;
            case 4:
                return Vt(), l === null && Gf(t.stateNode.containerInfo), dl(t), null;
            case 10:
                return Ht(t.type), dl(t), null;
            case 19:
                if ((j(xl), (u = t.memoizedState), u === null)) return dl(t), null;
                if (((e = (t.flags & 128) !== 0), (n = u.rendering), n === null))
                    if (e) Ie(u, !1);
                    else {
                        if (vl !== 0 || (l !== null && (l.flags & 128) !== 0))
                            for (l = t.child; l !== null; ) {
                                if (((n = cn(l)), n !== null)) {
                                    for (
                                        t.flags |= 128,
                                            Ie(u, !1),
                                            l = n.updateQueue,
                                            t.updateQueue = l,
                                            dn(t, l),
                                            t.subtreeFlags = 0,
                                            l = a,
                                            a = t.child;
                                        a !== null;

                                    )
                                        o0(a, l), (a = a.sibling);
                                    return N(xl, (xl.current & 1) | 2), t.child;
                                }
                                l = l.sibling;
                            }
                        u.tail !== null && xt() > yn && ((t.flags |= 128), (e = !0), Ie(u, !1), (t.lanes = 4194304));
                    }
                else {
                    if (!e)
                        if (((l = cn(n)), l !== null)) {
                            if (
                                ((t.flags |= 128),
                                (e = !0),
                                (l = l.updateQueue),
                                (t.updateQueue = l),
                                dn(t, l),
                                Ie(u, !0),
                                u.tail === null && u.tailMode === "hidden" && !n.alternate && !I)
                            )
                                return dl(t), null;
                        } else
                            2 * xt() - u.renderingStartTime > yn &&
                                a !== 536870912 &&
                                ((t.flags |= 128), (e = !0), Ie(u, !1), (t.lanes = 4194304));
                    u.isBackwards
                        ? ((n.sibling = t.child), (t.child = n))
                        : ((l = u.last), l !== null ? (l.sibling = n) : (t.child = n), (u.last = n));
                }
                return u.tail !== null
                    ? ((t = u.tail),
                      (u.rendering = t),
                      (u.tail = t.sibling),
                      (u.renderingStartTime = xt()),
                      (t.sibling = null),
                      (l = xl.current),
                      N(xl, e ? (l & 1) | 2 : l & 1),
                      t)
                    : (dl(t), null);
            case 22:
            case 23:
                return (
                    Ct(t),
                    Xc(),
                    (e = t.memoizedState !== null),
                    l !== null ? (l.memoizedState !== null) !== e && (t.flags |= 8192) : e && (t.flags |= 8192),
                    e
                        ? (a & 536870912) !== 0 &&
                          (t.flags & 128) === 0 &&
                          (dl(t), t.subtreeFlags & 6 && (t.flags |= 8192))
                        : dl(t),
                    (a = t.updateQueue),
                    a !== null && dn(t, a.retryQueue),
                    (a = null),
                    l !== null &&
                        l.memoizedState !== null &&
                        l.memoizedState.cachePool !== null &&
                        (a = l.memoizedState.cachePool.pool),
                    (e = null),
                    t.memoizedState !== null &&
                        t.memoizedState.cachePool !== null &&
                        (e = t.memoizedState.cachePool.pool),
                    e !== a && (t.flags |= 2048),
                    l !== null && j(_a),
                    null
                );
            case 24:
                return (
                    (a = null),
                    l !== null && (a = l.memoizedState.cache),
                    t.memoizedState.cache !== a && (t.flags |= 2048),
                    Ht(Sl),
                    dl(t),
                    null
                );
            case 25:
                return null;
            case 30:
                return null;
        }
        throw Error(r(156, t.tag));
    }
    function Po(l, t) {
        switch ((Oc(t), t.tag)) {
            case 1:
                return (l = t.flags), l & 65536 ? ((t.flags = (l & -65537) | 128), t) : null;
            case 3:
                return (
                    Ht(Sl),
                    Vt(),
                    (l = t.flags),
                    (l & 65536) !== 0 && (l & 128) === 0 ? ((t.flags = (l & -65537) | 128), t) : null
                );
            case 26:
            case 27:
            case 5:
                return Eu(t), null;
            case 13:
                if ((Ct(t), (l = t.memoizedState), l !== null && l.dehydrated !== null)) {
                    if (t.alternate === null) throw Error(r(340));
                    qe();
                }
                return (l = t.flags), l & 65536 ? ((t.flags = (l & -65537) | 128), t) : null;
            case 19:
                return j(xl), null;
            case 4:
                return Vt(), null;
            case 10:
                return Ht(t.type), null;
            case 22:
            case 23:
                return (
                    Ct(t),
                    Xc(),
                    l !== null && j(_a),
                    (l = t.flags),
                    l & 65536 ? ((t.flags = (l & -65537) | 128), t) : null
                );
            case 24:
                return Ht(Sl), null;
            case 25:
                return null;
            default:
                return null;
        }
    }
    function Ys(l, t) {
        switch ((Oc(t), t.tag)) {
            case 3:
                Ht(Sl), Vt();
                break;
            case 26:
            case 27:
            case 5:
                Eu(t);
                break;
            case 4:
                Vt();
                break;
            case 13:
                Ct(t);
                break;
            case 19:
                j(xl);
                break;
            case 10:
                Ht(t.type);
                break;
            case 22:
            case 23:
                Ct(t), Xc(), l !== null && j(_a);
                break;
            case 24:
                Ht(Sl);
        }
    }
    function lu(l, t) {
        try {
            var a = t.updateQueue,
                e = a !== null ? a.lastEffect : null;
            if (e !== null) {
                var u = e.next;
                a = u;
                do {
                    if ((a.tag & l) === l) {
                        e = void 0;
                        var n = a.create,
                            c = a.inst;
                        (e = n()), (c.destroy = e);
                    }
                    a = a.next;
                } while (a !== u);
            }
        } catch (f) {
            cl(t, t.return, f);
        }
    }
    function la(l, t, a) {
        try {
            var e = t.updateQueue,
                u = e !== null ? e.lastEffect : null;
            if (u !== null) {
                var n = u.next;
                e = n;
                do {
                    if ((e.tag & l) === l) {
                        var c = e.inst,
                            f = c.destroy;
                        if (f !== void 0) {
                            (c.destroy = void 0), (u = t);
                            var i = a,
                                y = f;
                            try {
                                y();
                            } catch (T) {
                                cl(u, i, T);
                            }
                        }
                    }
                    e = e.next;
                } while (e !== n);
            }
        } catch (T) {
            cl(t, t.return, T);
        }
    }
    function Gs(l) {
        var t = l.updateQueue;
        if (t !== null) {
            var a = l.stateNode;
            try {
                O0(t, a);
            } catch (e) {
                cl(l, l.return, e);
            }
        }
    }
    function Xs(l, t, a) {
        (a.props = ja(l.type, l.memoizedProps)), (a.state = l.memoizedState);
        try {
            a.componentWillUnmount();
        } catch (e) {
            cl(l, t, e);
        }
    }
    function tu(l, t) {
        try {
            var a = l.ref;
            if (a !== null) {
                switch (l.tag) {
                    case 26:
                    case 27:
                    case 5:
                        var e = l.stateNode;
                        break;
                    case 30:
                        e = l.stateNode;
                        break;
                    default:
                        e = l.stateNode;
                }
                typeof a == "function" ? (l.refCleanup = a(e)) : (a.current = e);
            }
        } catch (u) {
            cl(l, t, u);
        }
    }
    function pt(l, t) {
        var a = l.ref,
            e = l.refCleanup;
        if (a !== null)
            if (typeof e == "function")
                try {
                    e();
                } catch (u) {
                    cl(l, t, u);
                } finally {
                    (l.refCleanup = null), (l = l.alternate), l != null && (l.refCleanup = null);
                }
            else if (typeof a == "function")
                try {
                    a(null);
                } catch (u) {
                    cl(l, t, u);
                }
            else a.current = null;
    }
    function Qs(l) {
        var t = l.type,
            a = l.memoizedProps,
            e = l.stateNode;
        try {
            l: switch (t) {
                case "button":
                case "input":
                case "select":
                case "textarea":
                    a.autoFocus && e.focus();
                    break l;
                case "img":
                    a.src ? (e.src = a.src) : a.srcSet && (e.srcset = a.srcSet);
            }
        } catch (u) {
            cl(l, l.return, u);
        }
    }
    function yf(l, t, a) {
        try {
            var e = l.stateNode;
            Sd(e, l.type, a, t), (e[Gl] = t);
        } catch (u) {
            cl(l, l.return, u);
        }
    }
    function Zs(l) {
        return l.tag === 5 || l.tag === 3 || l.tag === 26 || (l.tag === 27 && ia(l.type)) || l.tag === 4;
    }
    function mf(l) {
        l: for (;;) {
            for (; l.sibling === null; ) {
                if (l.return === null || Zs(l.return)) return null;
                l = l.return;
            }
            for (l.sibling.return = l.return, l = l.sibling; l.tag !== 5 && l.tag !== 6 && l.tag !== 18; ) {
                if ((l.tag === 27 && ia(l.type)) || l.flags & 2 || l.child === null || l.tag === 4) continue l;
                (l.child.return = l), (l = l.child);
            }
            if (!(l.flags & 2)) return l.stateNode;
        }
    }
    function gf(l, t, a) {
        var e = l.tag;
        if (e === 5 || e === 6)
            (l = l.stateNode),
                t
                    ? (a.nodeType === 9 ? a.body : a.nodeName === "HTML" ? a.ownerDocument.body : a).insertBefore(l, t)
                    : ((t = a.nodeType === 9 ? a.body : a.nodeName === "HTML" ? a.ownerDocument.body : a),
                      t.appendChild(l),
                      (a = a._reactRootContainer),
                      a != null || t.onclick !== null || (t.onclick = An));
        else if (e !== 4 && (e === 27 && ia(l.type) && ((a = l.stateNode), (t = null)), (l = l.child), l !== null))
            for (gf(l, t, a), l = l.sibling; l !== null; ) gf(l, t, a), (l = l.sibling);
    }
    function hn(l, t, a) {
        var e = l.tag;
        if (e === 5 || e === 6) (l = l.stateNode), t ? a.insertBefore(l, t) : a.appendChild(l);
        else if (e !== 4 && (e === 27 && ia(l.type) && (a = l.stateNode), (l = l.child), l !== null))
            for (hn(l, t, a), l = l.sibling; l !== null; ) hn(l, t, a), (l = l.sibling);
    }
    function Vs(l) {
        var t = l.stateNode,
            a = l.memoizedProps;
        try {
            for (var e = l.type, u = t.attributes; u.length; ) t.removeAttributeNode(u[0]);
            Ml(t, e, a), (t[jl] = l), (t[Gl] = a);
        } catch (n) {
            cl(l, l.return, n);
        }
    }
    var Gt = !1,
        ml = !1,
        bf = !1,
        Ls = typeof WeakSet == "function" ? WeakSet : Set,
        pl = null;
    function Io(l, t) {
        if (((l = l.containerInfo), (Zf = jn), (l = t0(l)), yc(l))) {
            if ("selectionStart" in l) var a = { start: l.selectionStart, end: l.selectionEnd };
            else
                l: {
                    a = ((a = l.ownerDocument) && a.defaultView) || window;
                    var e = a.getSelection && a.getSelection();
                    if (e && e.rangeCount !== 0) {
                        a = e.anchorNode;
                        var u = e.anchorOffset,
                            n = e.focusNode;
                        e = e.focusOffset;
                        try {
                            a.nodeType, n.nodeType;
                        } catch {
                            a = null;
                            break l;
                        }
                        var c = 0,
                            f = -1,
                            i = -1,
                            y = 0,
                            T = 0,
                            A = l,
                            m = null;
                        t: for (;;) {
                            for (
                                var g;
                                A !== a || (u !== 0 && A.nodeType !== 3) || (f = c + u),
                                    A !== n || (e !== 0 && A.nodeType !== 3) || (i = c + e),
                                    A.nodeType === 3 && (c += A.nodeValue.length),
                                    (g = A.firstChild) !== null;

                            )
                                (m = A), (A = g);
                            for (;;) {
                                if (A === l) break t;
                                if (
                                    (m === a && ++y === u && (f = c),
                                    m === n && ++T === e && (i = c),
                                    (g = A.nextSibling) !== null)
                                )
                                    break;
                                (A = m), (m = A.parentNode);
                            }
                            A = g;
                        }
                        a = f === -1 || i === -1 ? null : { start: f, end: i };
                    } else a = null;
                }
            a = a || { start: 0, end: 0 };
        } else a = null;
        for (Vf = { focusedElem: l, selectionRange: a }, jn = !1, pl = t; pl !== null; )
            if (((t = pl), (l = t.child), (t.subtreeFlags & 1024) !== 0 && l !== null)) (l.return = t), (pl = l);
            else
                for (; pl !== null; ) {
                    switch (((t = pl), (n = t.alternate), (l = t.flags), t.tag)) {
                        case 0:
                            break;
                        case 11:
                        case 15:
                            break;
                        case 1:
                            if ((l & 1024) !== 0 && n !== null) {
                                (l = void 0), (a = t), (u = n.memoizedProps), (n = n.memoizedState), (e = a.stateNode);
                                try {
                                    var X = ja(a.type, u, a.elementType === a.type);
                                    (l = e.getSnapshotBeforeUpdate(X, n)), (e.__reactInternalSnapshotBeforeUpdate = l);
                                } catch (q) {
                                    cl(a, a.return, q);
                                }
                            }
                            break;
                        case 3:
                            if ((l & 1024) !== 0) {
                                if (((l = t.stateNode.containerInfo), (a = l.nodeType), a === 9)) Kf(l);
                                else if (a === 1)
                                    switch (l.nodeName) {
                                        case "HEAD":
                                        case "HTML":
                                        case "BODY":
                                            Kf(l);
                                            break;
                                        default:
                                            l.textContent = "";
                                    }
                            }
                            break;
                        case 5:
                        case 26:
                        case 27:
                        case 6:
                        case 4:
                        case 17:
                            break;
                        default:
                            if ((l & 1024) !== 0) throw Error(r(163));
                    }
                    if (((l = t.sibling), l !== null)) {
                        (l.return = t.return), (pl = l);
                        break;
                    }
                    pl = t.return;
                }
    }
    function ws(l, t, a) {
        var e = a.flags;
        switch (a.tag) {
            case 0:
            case 11:
            case 15:
                ta(l, a), e & 4 && lu(5, a);
                break;
            case 1:
                if ((ta(l, a), e & 4))
                    if (((l = a.stateNode), t === null))
                        try {
                            l.componentDidMount();
                        } catch (c) {
                            cl(a, a.return, c);
                        }
                    else {
                        var u = ja(a.type, t.memoizedProps);
                        t = t.memoizedState;
                        try {
                            l.componentDidUpdate(u, t, l.__reactInternalSnapshotBeforeUpdate);
                        } catch (c) {
                            cl(a, a.return, c);
                        }
                    }
                e & 64 && Gs(a), e & 512 && tu(a, a.return);
                break;
            case 3:
                if ((ta(l, a), e & 64 && ((l = a.updateQueue), l !== null))) {
                    if (((t = null), a.child !== null))
                        switch (a.child.tag) {
                            case 27:
                            case 5:
                                t = a.child.stateNode;
                                break;
                            case 1:
                                t = a.child.stateNode;
                        }
                    try {
                        O0(l, t);
                    } catch (c) {
                        cl(a, a.return, c);
                    }
                }
                break;
            case 27:
                t === null && e & 4 && Vs(a);
            case 26:
            case 5:
                ta(l, a), t === null && e & 4 && Qs(a), e & 512 && tu(a, a.return);
                break;
            case 12:
                ta(l, a);
                break;
            case 13:
                ta(l, a),
                    e & 4 && Fs(l, a),
                    e & 64 &&
                        ((l = a.memoizedState),
                        l !== null && ((l = l.dehydrated), l !== null && ((a = id.bind(null, a)), Od(l, a))));
                break;
            case 22:
                if (((e = a.memoizedState !== null || Gt), !e)) {
                    (t = (t !== null && t.memoizedState !== null) || ml), (u = Gt);
                    var n = ml;
                    (Gt = e), (ml = t) && !n ? aa(l, a, (a.subtreeFlags & 8772) !== 0) : ta(l, a), (Gt = u), (ml = n);
                }
                break;
            case 30:
                break;
            default:
                ta(l, a);
        }
    }
    function Ks(l) {
        var t = l.alternate;
        t !== null && ((l.alternate = null), Ks(t)),
            (l.child = null),
            (l.deletions = null),
            (l.sibling = null),
            l.tag === 5 && ((t = l.stateNode), t !== null && $n(t)),
            (l.stateNode = null),
            (l.return = null),
            (l.dependencies = null),
            (l.memoizedProps = null),
            (l.memoizedState = null),
            (l.pendingProps = null),
            (l.stateNode = null),
            (l.updateQueue = null);
    }
    var ol = null,
        Zl = !1;
    function Xt(l, t, a) {
        for (a = a.child; a !== null; ) Js(l, t, a), (a = a.sibling);
    }
    function Js(l, t, a) {
        if (Fl && typeof Fl.onCommitFiberUnmount == "function")
            try {
                Fl.onCommitFiberUnmount(Ee, a);
            } catch {}
        switch (a.tag) {
            case 26:
                ml || pt(a, t),
                    Xt(l, t, a),
                    a.memoizedState
                        ? a.memoizedState.count--
                        : a.stateNode && ((a = a.stateNode), a.parentNode.removeChild(a));
                break;
            case 27:
                ml || pt(a, t);
                var e = ol,
                    u = Zl;
                ia(a.type) && ((ol = a.stateNode), (Zl = !1)), Xt(l, t, a), ru(a.stateNode), (ol = e), (Zl = u);
                break;
            case 5:
                ml || pt(a, t);
            case 6:
                if (((e = ol), (u = Zl), (ol = null), Xt(l, t, a), (ol = e), (Zl = u), ol !== null))
                    if (Zl)
                        try {
                            (ol.nodeType === 9
                                ? ol.body
                                : ol.nodeName === "HTML"
                                  ? ol.ownerDocument.body
                                  : ol
                            ).removeChild(a.stateNode);
                        } catch (n) {
                            cl(a, t, n);
                        }
                    else
                        try {
                            ol.removeChild(a.stateNode);
                        } catch (n) {
                            cl(a, t, n);
                        }
                break;
            case 18:
                ol !== null &&
                    (Zl
                        ? ((l = ol),
                          B1(l.nodeType === 9 ? l.body : l.nodeName === "HTML" ? l.ownerDocument.body : l, a.stateNode),
                          bu(l))
                        : B1(ol, a.stateNode));
                break;
            case 4:
                (e = ol), (u = Zl), (ol = a.stateNode.containerInfo), (Zl = !0), Xt(l, t, a), (ol = e), (Zl = u);
                break;
            case 0:
            case 11:
            case 14:
            case 15:
                ml || la(2, a, t), ml || la(4, a, t), Xt(l, t, a);
                break;
            case 1:
                ml || (pt(a, t), (e = a.stateNode), typeof e.componentWillUnmount == "function" && Xs(a, t, e)),
                    Xt(l, t, a);
                break;
            case 21:
                Xt(l, t, a);
                break;
            case 22:
                (ml = (e = ml) || a.memoizedState !== null), Xt(l, t, a), (ml = e);
                break;
            default:
                Xt(l, t, a);
        }
    }
    function Fs(l, t) {
        if (
            t.memoizedState === null &&
            ((l = t.alternate), l !== null && ((l = l.memoizedState), l !== null && ((l = l.dehydrated), l !== null)))
        )
            try {
                bu(l);
            } catch (a) {
                cl(t, t.return, a);
            }
    }
    function ld(l) {
        switch (l.tag) {
            case 13:
            case 19:
                var t = l.stateNode;
                return t === null && (t = l.stateNode = new Ls()), t;
            case 22:
                return (l = l.stateNode), (t = l._retryCache), t === null && (t = l._retryCache = new Ls()), t;
            default:
                throw Error(r(435, l.tag));
        }
    }
    function Sf(l, t) {
        var a = ld(l);
        t.forEach(function (e) {
            var u = sd.bind(null, l, e);
            a.has(e) || (a.add(e), e.then(u, u));
        });
    }
    function Pl(l, t) {
        var a = t.deletions;
        if (a !== null)
            for (var e = 0; e < a.length; e++) {
                var u = a[e],
                    n = l,
                    c = t,
                    f = c;
                l: for (; f !== null; ) {
                    switch (f.tag) {
                        case 27:
                            if (ia(f.type)) {
                                (ol = f.stateNode), (Zl = !1);
                                break l;
                            }
                            break;
                        case 5:
                            (ol = f.stateNode), (Zl = !1);
                            break l;
                        case 3:
                        case 4:
                            (ol = f.stateNode.containerInfo), (Zl = !0);
                            break l;
                    }
                    f = f.return;
                }
                if (ol === null) throw Error(r(160));
                Js(n, c, u),
                    (ol = null),
                    (Zl = !1),
                    (n = u.alternate),
                    n !== null && (n.return = null),
                    (u.return = null);
            }
        if (t.subtreeFlags & 13878) for (t = t.child; t !== null; ) Ws(t, l), (t = t.sibling);
    }
    var gt = null;
    function Ws(l, t) {
        var a = l.alternate,
            e = l.flags;
        switch (l.tag) {
            case 0:
            case 11:
            case 14:
            case 15:
                Pl(t, l), Il(l), e & 4 && (la(3, l, l.return), lu(3, l), la(5, l, l.return));
                break;
            case 1:
                Pl(t, l),
                    Il(l),
                    e & 512 && (ml || a === null || pt(a, a.return)),
                    e & 64 &&
                        Gt &&
                        ((l = l.updateQueue),
                        l !== null &&
                            ((e = l.callbacks),
                            e !== null &&
                                ((a = l.shared.hiddenCallbacks),
                                (l.shared.hiddenCallbacks = a === null ? e : a.concat(e)))));
                break;
            case 26:
                var u = gt;
                if ((Pl(t, l), Il(l), e & 512 && (ml || a === null || pt(a, a.return)), e & 4)) {
                    var n = a !== null ? a.memoizedState : null;
                    if (((e = l.memoizedState), a === null))
                        if (e === null)
                            if (l.stateNode === null) {
                                l: {
                                    (e = l.type), (a = l.memoizedProps), (u = u.ownerDocument || u);
                                    t: switch (e) {
                                        case "title":
                                            (n = u.getElementsByTagName("title")[0]),
                                                (!n ||
                                                    n[ze] ||
                                                    n[jl] ||
                                                    n.namespaceURI === "http://www.w3.org/2000/svg" ||
                                                    n.hasAttribute("itemprop")) &&
                                                    ((n = u.createElement(e)),
                                                    u.head.insertBefore(n, u.querySelector("head > title"))),
                                                Ml(n, e, a),
                                                (n[jl] = l),
                                                Tl(n),
                                                (e = n);
                                            break l;
                                        case "link":
                                            var c = V1("link", "href", u).get(e + (a.href || ""));
                                            if (c) {
                                                for (var f = 0; f < c.length; f++)
                                                    if (
                                                        ((n = c[f]),
                                                        n.getAttribute("href") ===
                                                            (a.href == null || a.href === "" ? null : a.href) &&
                                                            n.getAttribute("rel") === (a.rel == null ? null : a.rel) &&
                                                            n.getAttribute("title") ===
                                                                (a.title == null ? null : a.title) &&
                                                            n.getAttribute("crossorigin") ===
                                                                (a.crossOrigin == null ? null : a.crossOrigin))
                                                    ) {
                                                        c.splice(f, 1);
                                                        break t;
                                                    }
                                            }
                                            (n = u.createElement(e)), Ml(n, e, a), u.head.appendChild(n);
                                            break;
                                        case "meta":
                                            if ((c = V1("meta", "content", u).get(e + (a.content || "")))) {
                                                for (f = 0; f < c.length; f++)
                                                    if (
                                                        ((n = c[f]),
                                                        n.getAttribute("content") ===
                                                            (a.content == null ? null : "" + a.content) &&
                                                            n.getAttribute("name") ===
                                                                (a.name == null ? null : a.name) &&
                                                            n.getAttribute("property") ===
                                                                (a.property == null ? null : a.property) &&
                                                            n.getAttribute("http-equiv") ===
                                                                (a.httpEquiv == null ? null : a.httpEquiv) &&
                                                            n.getAttribute("charset") ===
                                                                (a.charSet == null ? null : a.charSet))
                                                    ) {
                                                        c.splice(f, 1);
                                                        break t;
                                                    }
                                            }
                                            (n = u.createElement(e)), Ml(n, e, a), u.head.appendChild(n);
                                            break;
                                        default:
                                            throw Error(r(468, e));
                                    }
                                    (n[jl] = l), Tl(n), (e = n);
                                }
                                l.stateNode = e;
                            } else L1(u, l.type, l.stateNode);
                        else l.stateNode = Z1(u, e, l.memoizedProps);
                    else
                        n !== e
                            ? (n === null
                                  ? a.stateNode !== null && ((a = a.stateNode), a.parentNode.removeChild(a))
                                  : n.count--,
                              e === null ? L1(u, l.type, l.stateNode) : Z1(u, e, l.memoizedProps))
                            : e === null && l.stateNode !== null && yf(l, l.memoizedProps, a.memoizedProps);
                }
                break;
            case 27:
                Pl(t, l),
                    Il(l),
                    e & 512 && (ml || a === null || pt(a, a.return)),
                    a !== null && e & 4 && yf(l, l.memoizedProps, a.memoizedProps);
                break;
            case 5:
                if ((Pl(t, l), Il(l), e & 512 && (ml || a === null || pt(a, a.return)), l.flags & 32)) {
                    u = l.stateNode;
                    try {
                        La(u, "");
                    } catch (g) {
                        cl(l, l.return, g);
                    }
                }
                e & 4 && l.stateNode != null && ((u = l.memoizedProps), yf(l, u, a !== null ? a.memoizedProps : u)),
                    e & 1024 && (bf = !0);
                break;
            case 6:
                if ((Pl(t, l), Il(l), e & 4)) {
                    if (l.stateNode === null) throw Error(r(162));
                    (e = l.memoizedProps), (a = l.stateNode);
                    try {
                        a.nodeValue = e;
                    } catch (g) {
                        cl(l, l.return, g);
                    }
                }
                break;
            case 3:
                if (
                    ((Nn = null),
                    (u = gt),
                    (gt = On(t.containerInfo)),
                    Pl(t, l),
                    (gt = u),
                    Il(l),
                    e & 4 && a !== null && a.memoizedState.isDehydrated)
                )
                    try {
                        bu(t.containerInfo);
                    } catch (g) {
                        cl(l, l.return, g);
                    }
                bf && ((bf = !1), $s(l));
                break;
            case 4:
                (e = gt), (gt = On(l.stateNode.containerInfo)), Pl(t, l), Il(l), (gt = e);
                break;
            case 12:
                Pl(t, l), Il(l);
                break;
            case 13:
                Pl(t, l),
                    Il(l),
                    l.child.flags & 8192 &&
                        (l.memoizedState !== null) != (a !== null && a.memoizedState !== null) &&
                        (zf = xt()),
                    e & 4 && ((e = l.updateQueue), e !== null && ((l.updateQueue = null), Sf(l, e)));
                break;
            case 22:
                u = l.memoizedState !== null;
                var i = a !== null && a.memoizedState !== null,
                    y = Gt,
                    T = ml;
                if (((Gt = y || u), (ml = T || i), Pl(t, l), (ml = T), (Gt = y), Il(l), e & 8192))
                    l: for (
                        t = l.stateNode,
                            t._visibility = u ? t._visibility & -2 : t._visibility | 1,
                            u && (a === null || i || Gt || ml || Ua(l)),
                            a = null,
                            t = l;
                        ;

                    ) {
                        if (t.tag === 5 || t.tag === 26) {
                            if (a === null) {
                                i = a = t;
                                try {
                                    if (((n = i.stateNode), u))
                                        (c = n.style),
                                            typeof c.setProperty == "function"
                                                ? c.setProperty("display", "none", "important")
                                                : (c.display = "none");
                                    else {
                                        f = i.stateNode;
                                        var A = i.memoizedProps.style,
                                            m = A != null && A.hasOwnProperty("display") ? A.display : null;
                                        f.style.display = m == null || typeof m == "boolean" ? "" : ("" + m).trim();
                                    }
                                } catch (g) {
                                    cl(i, i.return, g);
                                }
                            }
                        } else if (t.tag === 6) {
                            if (a === null) {
                                i = t;
                                try {
                                    i.stateNode.nodeValue = u ? "" : i.memoizedProps;
                                } catch (g) {
                                    cl(i, i.return, g);
                                }
                            }
                        } else if (
                            ((t.tag !== 22 && t.tag !== 23) || t.memoizedState === null || t === l) &&
                            t.child !== null
                        ) {
                            (t.child.return = t), (t = t.child);
                            continue;
                        }
                        if (t === l) break l;
                        for (; t.sibling === null; ) {
                            if (t.return === null || t.return === l) break l;
                            a === t && (a = null), (t = t.return);
                        }
                        a === t && (a = null), (t.sibling.return = t.return), (t = t.sibling);
                    }
                e & 4 &&
                    ((e = l.updateQueue),
                    e !== null && ((a = e.retryQueue), a !== null && ((e.retryQueue = null), Sf(l, a))));
                break;
            case 19:
                Pl(t, l), Il(l), e & 4 && ((e = l.updateQueue), e !== null && ((l.updateQueue = null), Sf(l, e)));
                break;
            case 30:
                break;
            case 21:
                break;
            default:
                Pl(t, l), Il(l);
        }
    }
    function Il(l) {
        var t = l.flags;
        if (t & 2) {
            try {
                for (var a, e = l.return; e !== null; ) {
                    if (Zs(e)) {
                        a = e;
                        break;
                    }
                    e = e.return;
                }
                if (a == null) throw Error(r(160));
                switch (a.tag) {
                    case 27:
                        var u = a.stateNode,
                            n = mf(l);
                        hn(l, n, u);
                        break;
                    case 5:
                        var c = a.stateNode;
                        a.flags & 32 && (La(c, ""), (a.flags &= -33));
                        var f = mf(l);
                        hn(l, f, c);
                        break;
                    case 3:
                    case 4:
                        var i = a.stateNode.containerInfo,
                            y = mf(l);
                        gf(l, y, i);
                        break;
                    default:
                        throw Error(r(161));
                }
            } catch (T) {
                cl(l, l.return, T);
            }
            l.flags &= -3;
        }
        t & 4096 && (l.flags &= -4097);
    }
    function $s(l) {
        if (l.subtreeFlags & 1024)
            for (l = l.child; l !== null; ) {
                var t = l;
                $s(t), t.tag === 5 && t.flags & 1024 && t.stateNode.reset(), (l = l.sibling);
            }
    }
    function ta(l, t) {
        if (t.subtreeFlags & 8772) for (t = t.child; t !== null; ) ws(l, t.alternate, t), (t = t.sibling);
    }
    function Ua(l) {
        for (l = l.child; l !== null; ) {
            var t = l;
            switch (t.tag) {
                case 0:
                case 11:
                case 14:
                case 15:
                    la(4, t, t.return), Ua(t);
                    break;
                case 1:
                    pt(t, t.return);
                    var a = t.stateNode;
                    typeof a.componentWillUnmount == "function" && Xs(t, t.return, a), Ua(t);
                    break;
                case 27:
                    ru(t.stateNode);
                case 26:
                case 5:
                    pt(t, t.return), Ua(t);
                    break;
                case 22:
                    t.memoizedState === null && Ua(t);
                    break;
                case 30:
                    Ua(t);
                    break;
                default:
                    Ua(t);
            }
            l = l.sibling;
        }
    }
    function aa(l, t, a) {
        for (a = a && (t.subtreeFlags & 8772) !== 0, t = t.child; t !== null; ) {
            var e = t.alternate,
                u = l,
                n = t,
                c = n.flags;
            switch (n.tag) {
                case 0:
                case 11:
                case 15:
                    aa(u, n, a), lu(4, n);
                    break;
                case 1:
                    if ((aa(u, n, a), (e = n), (u = e.stateNode), typeof u.componentDidMount == "function"))
                        try {
                            u.componentDidMount();
                        } catch (y) {
                            cl(e, e.return, y);
                        }
                    if (((e = n), (u = e.updateQueue), u !== null)) {
                        var f = e.stateNode;
                        try {
                            var i = u.shared.hiddenCallbacks;
                            if (i !== null) for (u.shared.hiddenCallbacks = null, u = 0; u < i.length; u++) z0(i[u], f);
                        } catch (y) {
                            cl(e, e.return, y);
                        }
                    }
                    a && c & 64 && Gs(n), tu(n, n.return);
                    break;
                case 27:
                    Vs(n);
                case 26:
                case 5:
                    aa(u, n, a), a && e === null && c & 4 && Qs(n), tu(n, n.return);
                    break;
                case 12:
                    aa(u, n, a);
                    break;
                case 13:
                    aa(u, n, a), a && c & 4 && Fs(u, n);
                    break;
                case 22:
                    n.memoizedState === null && aa(u, n, a), tu(n, n.return);
                    break;
                case 30:
                    break;
                default:
                    aa(u, n, a);
            }
            t = t.sibling;
        }
    }
    function xf(l, t) {
        var a = null;
        l !== null &&
            l.memoizedState !== null &&
            l.memoizedState.cachePool !== null &&
            (a = l.memoizedState.cachePool.pool),
            (l = null),
            t.memoizedState !== null && t.memoizedState.cachePool !== null && (l = t.memoizedState.cachePool.pool),
            l !== a && (l != null && l.refCount++, a != null && Xe(a));
    }
    function Tf(l, t) {
        (l = null),
            t.alternate !== null && (l = t.alternate.memoizedState.cache),
            (t = t.memoizedState.cache),
            t !== l && (t.refCount++, l != null && Xe(l));
    }
    function At(l, t, a, e) {
        if (t.subtreeFlags & 10256) for (t = t.child; t !== null; ) ks(l, t, a, e), (t = t.sibling);
    }
    function ks(l, t, a, e) {
        var u = t.flags;
        switch (t.tag) {
            case 0:
            case 11:
            case 15:
                At(l, t, a, e), u & 2048 && lu(9, t);
                break;
            case 1:
                At(l, t, a, e);
                break;
            case 3:
                At(l, t, a, e),
                    u & 2048 &&
                        ((l = null),
                        t.alternate !== null && (l = t.alternate.memoizedState.cache),
                        (t = t.memoizedState.cache),
                        t !== l && (t.refCount++, l != null && Xe(l)));
                break;
            case 12:
                if (u & 2048) {
                    At(l, t, a, e), (l = t.stateNode);
                    try {
                        var n = t.memoizedProps,
                            c = n.id,
                            f = n.onPostCommit;
                        typeof f == "function" &&
                            f(c, t.alternate === null ? "mount" : "update", l.passiveEffectDuration, -0);
                    } catch (i) {
                        cl(t, t.return, i);
                    }
                } else At(l, t, a, e);
                break;
            case 13:
                At(l, t, a, e);
                break;
            case 23:
                break;
            case 22:
                (n = t.stateNode),
                    (c = t.alternate),
                    t.memoizedState !== null
                        ? n._visibility & 2
                            ? At(l, t, a, e)
                            : au(l, t)
                        : n._visibility & 2
                          ? At(l, t, a, e)
                          : ((n._visibility |= 2), se(l, t, a, e, (t.subtreeFlags & 10256) !== 0)),
                    u & 2048 && xf(c, t);
                break;
            case 24:
                At(l, t, a, e), u & 2048 && Tf(t.alternate, t);
                break;
            default:
                At(l, t, a, e);
        }
    }
    function se(l, t, a, e, u) {
        for (u = u && (t.subtreeFlags & 10256) !== 0, t = t.child; t !== null; ) {
            var n = l,
                c = t,
                f = a,
                i = e,
                y = c.flags;
            switch (c.tag) {
                case 0:
                case 11:
                case 15:
                    se(n, c, f, i, u), lu(8, c);
                    break;
                case 23:
                    break;
                case 22:
                    var T = c.stateNode;
                    c.memoizedState !== null
                        ? T._visibility & 2
                            ? se(n, c, f, i, u)
                            : au(n, c)
                        : ((T._visibility |= 2), se(n, c, f, i, u)),
                        u && y & 2048 && xf(c.alternate, c);
                    break;
                case 24:
                    se(n, c, f, i, u), u && y & 2048 && Tf(c.alternate, c);
                    break;
                default:
                    se(n, c, f, i, u);
            }
            t = t.sibling;
        }
    }
    function au(l, t) {
        if (t.subtreeFlags & 10256)
            for (t = t.child; t !== null; ) {
                var a = l,
                    e = t,
                    u = e.flags;
                switch (e.tag) {
                    case 22:
                        au(a, e), u & 2048 && xf(e.alternate, e);
                        break;
                    case 24:
                        au(a, e), u & 2048 && Tf(e.alternate, e);
                        break;
                    default:
                        au(a, e);
                }
                t = t.sibling;
            }
    }
    var eu = 8192;
    function re(l) {
        if (l.subtreeFlags & eu) for (l = l.child; l !== null; ) Ps(l), (l = l.sibling);
    }
    function Ps(l) {
        switch (l.tag) {
            case 26:
                re(l), l.flags & eu && l.memoizedState !== null && Gd(gt, l.memoizedState, l.memoizedProps);
                break;
            case 5:
                re(l);
                break;
            case 3:
            case 4:
                var t = gt;
                (gt = On(l.stateNode.containerInfo)), re(l), (gt = t);
                break;
            case 22:
                l.memoizedState === null &&
                    ((t = l.alternate),
                    t !== null && t.memoizedState !== null ? ((t = eu), (eu = 16777216), re(l), (eu = t)) : re(l));
                break;
            default:
                re(l);
        }
    }
    function Is(l) {
        var t = l.alternate;
        if (t !== null && ((l = t.child), l !== null)) {
            t.child = null;
            do (t = l.sibling), (l.sibling = null), (l = t);
            while (l !== null);
        }
    }
    function uu(l) {
        var t = l.deletions;
        if ((l.flags & 16) !== 0) {
            if (t !== null)
                for (var a = 0; a < t.length; a++) {
                    var e = t[a];
                    (pl = e), t1(e, l);
                }
            Is(l);
        }
        if (l.subtreeFlags & 10256) for (l = l.child; l !== null; ) l1(l), (l = l.sibling);
    }
    function l1(l) {
        switch (l.tag) {
            case 0:
            case 11:
            case 15:
                uu(l), l.flags & 2048 && la(9, l, l.return);
                break;
            case 3:
                uu(l);
                break;
            case 12:
                uu(l);
                break;
            case 22:
                var t = l.stateNode;
                l.memoizedState !== null && t._visibility & 2 && (l.return === null || l.return.tag !== 13)
                    ? ((t._visibility &= -3), vn(l))
                    : uu(l);
                break;
            default:
                uu(l);
        }
    }
    function vn(l) {
        var t = l.deletions;
        if ((l.flags & 16) !== 0) {
            if (t !== null)
                for (var a = 0; a < t.length; a++) {
                    var e = t[a];
                    (pl = e), t1(e, l);
                }
            Is(l);
        }
        for (l = l.child; l !== null; ) {
            switch (((t = l), t.tag)) {
                case 0:
                case 11:
                case 15:
                    la(8, t, t.return), vn(t);
                    break;
                case 22:
                    (a = t.stateNode), a._visibility & 2 && ((a._visibility &= -3), vn(t));
                    break;
                default:
                    vn(t);
            }
            l = l.sibling;
        }
    }
    function t1(l, t) {
        for (; pl !== null; ) {
            var a = pl;
            switch (a.tag) {
                case 0:
                case 11:
                case 15:
                    la(8, a, t);
                    break;
                case 23:
                case 22:
                    if (a.memoizedState !== null && a.memoizedState.cachePool !== null) {
                        var e = a.memoizedState.cachePool.pool;
                        e != null && e.refCount++;
                    }
                    break;
                case 24:
                    Xe(a.memoizedState.cache);
            }
            if (((e = a.child), e !== null)) (e.return = a), (pl = e);
            else
                l: for (a = l; pl !== null; ) {
                    e = pl;
                    var u = e.sibling,
                        n = e.return;
                    if ((Ks(e), e === a)) {
                        pl = null;
                        break l;
                    }
                    if (u !== null) {
                        (u.return = n), (pl = u);
                        break l;
                    }
                    pl = n;
                }
        }
    }
    var td = {
            getCacheForType: function (l) {
                var t = Ul(Sl),
                    a = t.data.get(l);
                return a === void 0 && ((a = l()), t.data.set(l, a)), a;
            },
        },
        ad = typeof WeakMap == "function" ? WeakMap : Map,
        ll = 0,
        il = null,
        K = null,
        F = 0,
        tl = 0,
        lt = null,
        ea = !1,
        oe = !1,
        Ef = !1,
        Qt = 0,
        vl = 0,
        ua = 0,
        Ra = 0,
        pf = 0,
        rt = 0,
        de = 0,
        nu = null,
        Vl = null,
        Af = !1,
        zf = 0,
        yn = 1 / 0,
        mn = null,
        na = null,
        Ol = 0,
        ca = null,
        he = null,
        ve = 0,
        Of = 0,
        Mf = null,
        a1 = null,
        cu = 0,
        Nf = null;
    function tt() {
        if ((ll & 2) !== 0 && F !== 0) return F & -F;
        if (E.T !== null) {
            var l = te;
            return l !== 0 ? l : Bf();
        }
        return bi();
    }
    function e1() {
        rt === 0 && (rt = (F & 536870912) === 0 || I ? vi() : 536870912);
        var l = st.current;
        return l !== null && (l.flags |= 32), rt;
    }
    function at(l, t, a) {
        ((l === il && (tl === 2 || tl === 9)) || l.cancelPendingCommit !== null) && (ye(l, 0), fa(l, F, rt, !1)),
            Ae(l, a),
            ((ll & 2) === 0 || l !== il) &&
                (l === il && ((ll & 2) === 0 && (Ra |= a), vl === 4 && fa(l, F, rt, !1)), zt(l));
    }
    function u1(l, t, a) {
        if ((ll & 6) !== 0) throw Error(r(327));
        var e = (!a && (t & 124) === 0 && (t & l.expiredLanes) === 0) || pe(l, t),
            u = e ? nd(l, t) : jf(l, t, !0),
            n = e;
        do {
            if (u === 0) {
                oe && !e && fa(l, t, 0, !1);
                break;
            } else {
                if (((a = l.current.alternate), n && !ed(a))) {
                    (u = jf(l, t, !1)), (n = !1);
                    continue;
                }
                if (u === 2) {
                    if (((n = t), l.errorRecoveryDisabledLanes & n)) var c = 0;
                    else (c = l.pendingLanes & -536870913), (c = c !== 0 ? c : c & 536870912 ? 536870912 : 0);
                    if (c !== 0) {
                        t = c;
                        l: {
                            var f = l;
                            u = nu;
                            var i = f.current.memoizedState.isDehydrated;
                            if ((i && (ye(f, c).flags |= 256), (c = jf(f, c, !1)), c !== 2)) {
                                if (Ef && !i) {
                                    (f.errorRecoveryDisabledLanes |= n), (Ra |= n), (u = 4);
                                    break l;
                                }
                                (n = Vl), (Vl = u), n !== null && (Vl === null ? (Vl = n) : Vl.push.apply(Vl, n));
                            }
                            u = c;
                        }
                        if (((n = !1), u !== 2)) continue;
                    }
                }
                if (u === 1) {
                    ye(l, 0), fa(l, t, 0, !0);
                    break;
                }
                l: {
                    switch (((e = l), (n = u), n)) {
                        case 0:
                        case 1:
                            throw Error(r(345));
                        case 4:
                            if ((t & 4194048) !== t) break;
                        case 6:
                            fa(e, t, rt, !ea);
                            break l;
                        case 2:
                            Vl = null;
                            break;
                        case 3:
                        case 5:
                            break;
                        default:
                            throw Error(r(329));
                    }
                    if ((t & 62914560) === t && ((u = zf + 300 - xt()), 10 < u)) {
                        if ((fa(e, t, rt, !ea), Ou(e, 0, !0) !== 0)) break l;
                        e.timeoutHandle = R1(n1.bind(null, e, a, Vl, mn, Af, t, rt, Ra, de, ea, n, 2, -0, 0), u);
                        break l;
                    }
                    n1(e, a, Vl, mn, Af, t, rt, Ra, de, ea, n, 0, -0, 0);
                }
            }
            break;
        } while (!0);
        zt(l);
    }
    function n1(l, t, a, e, u, n, c, f, i, y, T, A, m, g) {
        if (
            ((l.timeoutHandle = -1),
            (A = t.subtreeFlags),
            (A & 8192 || (A & 16785408) === 16785408) &&
                ((hu = { stylesheets: null, count: 0, unsuspend: Yd }), Ps(t), (A = Xd()), A !== null))
        ) {
            (l.cancelPendingCommit = A(d1.bind(null, l, t, n, a, e, u, c, f, i, T, 1, m, g))), fa(l, n, c, !y);
            return;
        }
        d1(l, t, n, a, e, u, c, f, i);
    }
    function ed(l) {
        for (var t = l; ; ) {
            var a = t.tag;
            if (
                (a === 0 || a === 11 || a === 15) &&
                t.flags & 16384 &&
                ((a = t.updateQueue), a !== null && ((a = a.stores), a !== null))
            )
                for (var e = 0; e < a.length; e++) {
                    var u = a[e],
                        n = u.getSnapshot;
                    u = u.value;
                    try {
                        if (!$l(n(), u)) return !1;
                    } catch {
                        return !1;
                    }
                }
            if (((a = t.child), t.subtreeFlags & 16384 && a !== null)) (a.return = t), (t = a);
            else {
                if (t === l) break;
                for (; t.sibling === null; ) {
                    if (t.return === null || t.return === l) return !0;
                    t = t.return;
                }
                (t.sibling.return = t.return), (t = t.sibling);
            }
        }
        return !0;
    }
    function fa(l, t, a, e) {
        (t &= ~pf),
            (t &= ~Ra),
            (l.suspendedLanes |= t),
            (l.pingedLanes &= ~t),
            e && (l.warmLanes |= t),
            (e = l.expirationTimes);
        for (var u = t; 0 < u; ) {
            var n = 31 - Wl(u),
                c = 1 << n;
            (e[n] = -1), (u &= ~c);
        }
        a !== 0 && mi(l, a, t);
    }
    function gn() {
        return (ll & 6) === 0 ? (fu(0), !1) : !0;
    }
    function _f() {
        if (K !== null) {
            if (tl === 0) var l = K.return;
            else (l = K), (Rt = Ma = null), wc(l), (fe = null), (ke = 0), (l = K);
            for (; l !== null; ) Ys(l.alternate, l), (l = l.return);
            K = null;
        }
    }
    function ye(l, t) {
        var a = l.timeoutHandle;
        a !== -1 && ((l.timeoutHandle = -1), Td(a)),
            (a = l.cancelPendingCommit),
            a !== null && ((l.cancelPendingCommit = null), a()),
            _f(),
            (il = l),
            (K = a = Dt(l.current, null)),
            (F = t),
            (tl = 0),
            (lt = null),
            (ea = !1),
            (oe = pe(l, t)),
            (Ef = !1),
            (de = rt = pf = Ra = ua = vl = 0),
            (Vl = nu = null),
            (Af = !1),
            (t & 8) !== 0 && (t |= t & 32);
        var e = l.entangledLanes;
        if (e !== 0)
            for (l = l.entanglements, e &= t; 0 < e; ) {
                var u = 31 - Wl(e),
                    n = 1 << u;
                (t |= l[u]), (e &= ~n);
            }
        return (Qt = t), Yu(), a;
    }
    function c1(l, t) {
        (L = null),
            (E.H = en),
            t === Ze || t === Ju
                ? ((t = p0()), (tl = 3))
                : t === x0
                  ? ((t = p0()), (tl = 4))
                  : (tl = t === As ? 8 : t !== null && typeof t == "object" && typeof t.then == "function" ? 6 : 1),
            (lt = t),
            K === null && ((vl = 1), sn(l, nt(t, l.current)));
    }
    function f1() {
        var l = E.H;
        return (E.H = en), l === null ? en : l;
    }
    function i1() {
        var l = E.A;
        return (E.A = td), l;
    }
    function Df() {
        (vl = 4),
            ea || ((F & 4194048) !== F && st.current !== null) || (oe = !0),
            ((ua & 134217727) === 0 && (Ra & 134217727) === 0) || il === null || fa(il, F, rt, !1);
    }
    function jf(l, t, a) {
        var e = ll;
        ll |= 2;
        var u = f1(),
            n = i1();
        (il !== l || F !== t) && ((mn = null), ye(l, t)), (t = !1);
        var c = vl;
        l: do
            try {
                if (tl !== 0 && K !== null) {
                    var f = K,
                        i = lt;
                    switch (tl) {
                        case 8:
                            _f(), (c = 6);
                            break l;
                        case 3:
                        case 2:
                        case 9:
                        case 6:
                            st.current === null && (t = !0);
                            var y = tl;
                            if (((tl = 0), (lt = null), me(l, f, i, y), a && oe)) {
                                c = 0;
                                break l;
                            }
                            break;
                        default:
                            (y = tl), (tl = 0), (lt = null), me(l, f, i, y);
                    }
                }
                ud(), (c = vl);
                break;
            } catch (T) {
                c1(l, T);
            }
        while (!0);
        return (
            t && l.shellSuspendCounter++,
            (Rt = Ma = null),
            (ll = e),
            (E.H = u),
            (E.A = n),
            K === null && ((il = null), (F = 0), Yu()),
            c
        );
    }
    function ud() {
        for (; K !== null; ) s1(K);
    }
    function nd(l, t) {
        var a = ll;
        ll |= 2;
        var e = f1(),
            u = i1();
        il !== l || F !== t ? ((mn = null), (yn = xt() + 500), ye(l, t)) : (oe = pe(l, t));
        l: do
            try {
                if (tl !== 0 && K !== null) {
                    t = K;
                    var n = lt;
                    t: switch (tl) {
                        case 1:
                            (tl = 0), (lt = null), me(l, t, n, 1);
                            break;
                        case 2:
                        case 9:
                            if (T0(n)) {
                                (tl = 0), (lt = null), r1(t);
                                break;
                            }
                            (t = function () {
                                (tl !== 2 && tl !== 9) || il !== l || (tl = 7), zt(l);
                            }),
                                n.then(t, t);
                            break l;
                        case 3:
                            tl = 7;
                            break l;
                        case 4:
                            tl = 5;
                            break l;
                        case 7:
                            T0(n) ? ((tl = 0), (lt = null), r1(t)) : ((tl = 0), (lt = null), me(l, t, n, 7));
                            break;
                        case 5:
                            var c = null;
                            switch (K.tag) {
                                case 26:
                                    c = K.memoizedState;
                                case 5:
                                case 27:
                                    var f = K;
                                    if (!c || w1(c)) {
                                        (tl = 0), (lt = null);
                                        var i = f.sibling;
                                        if (i !== null) K = i;
                                        else {
                                            var y = f.return;
                                            y !== null ? ((K = y), bn(y)) : (K = null);
                                        }
                                        break t;
                                    }
                            }
                            (tl = 0), (lt = null), me(l, t, n, 5);
                            break;
                        case 6:
                            (tl = 0), (lt = null), me(l, t, n, 6);
                            break;
                        case 8:
                            _f(), (vl = 6);
                            break l;
                        default:
                            throw Error(r(462));
                    }
                }
                cd();
                break;
            } catch (T) {
                c1(l, T);
            }
        while (!0);
        return (Rt = Ma = null), (E.H = e), (E.A = u), (ll = a), K !== null ? 0 : ((il = null), (F = 0), Yu(), vl);
    }
    function cd() {
        for (; K !== null && !Mr(); ) s1(K);
    }
    function s1(l) {
        var t = Cs(l.alternate, l, Qt);
        (l.memoizedProps = l.pendingProps), t === null ? bn(l) : (K = t);
    }
    function r1(l) {
        var t = l,
            a = t.alternate;
        switch (t.tag) {
            case 15:
            case 0:
                t = Ds(a, t, t.pendingProps, t.type, void 0, F);
                break;
            case 11:
                t = Ds(a, t, t.pendingProps, t.type.render, t.ref, F);
                break;
            case 5:
                wc(t);
            default:
                Ys(a, t), (t = K = o0(t, Qt)), (t = Cs(a, t, Qt));
        }
        (l.memoizedProps = l.pendingProps), t === null ? bn(l) : (K = t);
    }
    function me(l, t, a, e) {
        (Rt = Ma = null), wc(t), (fe = null), (ke = 0);
        var u = t.return;
        try {
            if (Wo(l, u, t, a, F)) {
                (vl = 1), sn(l, nt(a, l.current)), (K = null);
                return;
            }
        } catch (n) {
            if (u !== null) throw ((K = u), n);
            (vl = 1), sn(l, nt(a, l.current)), (K = null);
            return;
        }
        t.flags & 32768
            ? (I || e === 1
                  ? (l = !0)
                  : oe || (F & 536870912) !== 0
                    ? (l = !1)
                    : ((ea = l = !0),
                      (e === 2 || e === 9 || e === 3 || e === 6) &&
                          ((e = st.current), e !== null && e.tag === 13 && (e.flags |= 16384))),
              o1(t, l))
            : bn(t);
    }
    function bn(l) {
        var t = l;
        do {
            if ((t.flags & 32768) !== 0) {
                o1(t, ea);
                return;
            }
            l = t.return;
            var a = ko(t.alternate, t, Qt);
            if (a !== null) {
                K = a;
                return;
            }
            if (((t = t.sibling), t !== null)) {
                K = t;
                return;
            }
            K = t = l;
        } while (t !== null);
        vl === 0 && (vl = 5);
    }
    function o1(l, t) {
        do {
            var a = Po(l.alternate, l);
            if (a !== null) {
                (a.flags &= 32767), (K = a);
                return;
            }
            if (
                ((a = l.return),
                a !== null && ((a.flags |= 32768), (a.subtreeFlags = 0), (a.deletions = null)),
                !t && ((l = l.sibling), l !== null))
            ) {
                K = l;
                return;
            }
            K = l = a;
        } while (l !== null);
        (vl = 6), (K = null);
    }
    function d1(l, t, a, e, u, n, c, f, i) {
        l.cancelPendingCommit = null;
        do Sn();
        while (Ol !== 0);
        if ((ll & 6) !== 0) throw Error(r(327));
        if (t !== null) {
            if (t === l.current) throw Error(r(177));
            if (
                ((n = t.lanes | t.childLanes),
                (n |= xc),
                qr(l, a, n, c, f, i),
                l === il && ((K = il = null), (F = 0)),
                (he = t),
                (ca = l),
                (ve = a),
                (Of = n),
                (Mf = u),
                (a1 = e),
                (t.subtreeFlags & 10256) !== 0 || (t.flags & 10256) !== 0
                    ? ((l.callbackNode = null),
                      (l.callbackPriority = 0),
                      rd(pu, function () {
                          return g1(), null;
                      }))
                    : ((l.callbackNode = null), (l.callbackPriority = 0)),
                (e = (t.flags & 13878) !== 0),
                (t.subtreeFlags & 13878) !== 0 || e)
            ) {
                (e = E.T), (E.T = null), (u = _.p), (_.p = 2), (c = ll), (ll |= 4);
                try {
                    Io(l, t, a);
                } finally {
                    (ll = c), (_.p = u), (E.T = e);
                }
            }
            (Ol = 1), h1(), v1(), y1();
        }
    }
    function h1() {
        if (Ol === 1) {
            Ol = 0;
            var l = ca,
                t = he,
                a = (t.flags & 13878) !== 0;
            if ((t.subtreeFlags & 13878) !== 0 || a) {
                (a = E.T), (E.T = null);
                var e = _.p;
                _.p = 2;
                var u = ll;
                ll |= 4;
                try {
                    Ws(t, l);
                    var n = Vf,
                        c = t0(l.containerInfo),
                        f = n.focusedElem,
                        i = n.selectionRange;
                    if (c !== f && f && f.ownerDocument && l0(f.ownerDocument.documentElement, f)) {
                        if (i !== null && yc(f)) {
                            var y = i.start,
                                T = i.end;
                            if ((T === void 0 && (T = y), "selectionStart" in f))
                                (f.selectionStart = y), (f.selectionEnd = Math.min(T, f.value.length));
                            else {
                                var A = f.ownerDocument || document,
                                    m = (A && A.defaultView) || window;
                                if (m.getSelection) {
                                    var g = m.getSelection(),
                                        X = f.textContent.length,
                                        q = Math.min(i.start, X),
                                        ul = i.end === void 0 ? q : Math.min(i.end, X);
                                    !g.extend && q > ul && ((c = ul), (ul = q), (q = c));
                                    var h = Ii(f, q),
                                        d = Ii(f, ul);
                                    if (
                                        h &&
                                        d &&
                                        (g.rangeCount !== 1 ||
                                            g.anchorNode !== h.node ||
                                            g.anchorOffset !== h.offset ||
                                            g.focusNode !== d.node ||
                                            g.focusOffset !== d.offset)
                                    ) {
                                        var v = A.createRange();
                                        v.setStart(h.node, h.offset),
                                            g.removeAllRanges(),
                                            q > ul
                                                ? (g.addRange(v), g.extend(d.node, d.offset))
                                                : (v.setEnd(d.node, d.offset), g.addRange(v));
                                    }
                                }
                            }
                        }
                        for (A = [], g = f; (g = g.parentNode); )
                            g.nodeType === 1 && A.push({ element: g, left: g.scrollLeft, top: g.scrollTop });
                        for (typeof f.focus == "function" && f.focus(), f = 0; f < A.length; f++) {
                            var p = A[f];
                            (p.element.scrollLeft = p.left), (p.element.scrollTop = p.top);
                        }
                    }
                    (jn = !!Zf), (Vf = Zf = null);
                } finally {
                    (ll = u), (_.p = e), (E.T = a);
                }
            }
            (l.current = t), (Ol = 2);
        }
    }
    function v1() {
        if (Ol === 2) {
            Ol = 0;
            var l = ca,
                t = he,
                a = (t.flags & 8772) !== 0;
            if ((t.subtreeFlags & 8772) !== 0 || a) {
                (a = E.T), (E.T = null);
                var e = _.p;
                _.p = 2;
                var u = ll;
                ll |= 4;
                try {
                    ws(l, t.alternate, t);
                } finally {
                    (ll = u), (_.p = e), (E.T = a);
                }
            }
            Ol = 3;
        }
    }
    function y1() {
        if (Ol === 4 || Ol === 3) {
            (Ol = 0), Nr();
            var l = ca,
                t = he,
                a = ve,
                e = a1;
            (t.subtreeFlags & 10256) !== 0 || (t.flags & 10256) !== 0
                ? (Ol = 5)
                : ((Ol = 0), (he = ca = null), m1(l, l.pendingLanes));
            var u = l.pendingLanes;
            if ((u === 0 && (na = null), Fn(a), (t = t.stateNode), Fl && typeof Fl.onCommitFiberRoot == "function"))
                try {
                    Fl.onCommitFiberRoot(Ee, t, void 0, (t.current.flags & 128) === 128);
                } catch {}
            if (e !== null) {
                (t = E.T), (u = _.p), (_.p = 2), (E.T = null);
                try {
                    for (var n = l.onRecoverableError, c = 0; c < e.length; c++) {
                        var f = e[c];
                        n(f.value, { componentStack: f.stack });
                    }
                } finally {
                    (E.T = t), (_.p = u);
                }
            }
            (ve & 3) !== 0 && Sn(),
                zt(l),
                (u = l.pendingLanes),
                (a & 4194090) !== 0 && (u & 42) !== 0 ? (l === Nf ? cu++ : ((cu = 0), (Nf = l))) : (cu = 0),
                fu(0);
        }
    }
    function m1(l, t) {
        (l.pooledCacheLanes &= t) === 0 && ((t = l.pooledCache), t != null && ((l.pooledCache = null), Xe(t)));
    }
    function Sn(l) {
        return h1(), v1(), y1(), g1();
    }
    function g1() {
        if (Ol !== 5) return !1;
        var l = ca,
            t = Of;
        Of = 0;
        var a = Fn(ve),
            e = E.T,
            u = _.p;
        try {
            (_.p = 32 > a ? 32 : a), (E.T = null), (a = Mf), (Mf = null);
            var n = ca,
                c = ve;
            if (((Ol = 0), (he = ca = null), (ve = 0), (ll & 6) !== 0)) throw Error(r(331));
            var f = ll;
            if (
                ((ll |= 4),
                l1(n.current),
                ks(n, n.current, c, a),
                (ll = f),
                fu(0, !1),
                Fl && typeof Fl.onPostCommitFiberRoot == "function")
            )
                try {
                    Fl.onPostCommitFiberRoot(Ee, n);
                } catch {}
            return !0;
        } finally {
            (_.p = u), (E.T = e), m1(l, t);
        }
    }
    function b1(l, t, a) {
        (t = nt(a, t)), (t = nf(l.stateNode, t, 2)), (l = $t(l, t, 2)), l !== null && (Ae(l, 2), zt(l));
    }
    function cl(l, t, a) {
        if (l.tag === 3) b1(l, l, a);
        else
            for (; t !== null; ) {
                if (t.tag === 3) {
                    b1(t, l, a);
                    break;
                } else if (t.tag === 1) {
                    var e = t.stateNode;
                    if (
                        typeof t.type.getDerivedStateFromError == "function" ||
                        (typeof e.componentDidCatch == "function" && (na === null || !na.has(e)))
                    ) {
                        (l = nt(a, l)), (a = Es(2)), (e = $t(t, a, 2)), e !== null && (ps(a, e, t, l), Ae(e, 2), zt(e));
                        break;
                    }
                }
                t = t.return;
            }
    }
    function Uf(l, t, a) {
        var e = l.pingCache;
        if (e === null) {
            e = l.pingCache = new ad();
            var u = new Set();
            e.set(t, u);
        } else (u = e.get(t)), u === void 0 && ((u = new Set()), e.set(t, u));
        u.has(a) || ((Ef = !0), u.add(a), (l = fd.bind(null, l, t, a)), t.then(l, l));
    }
    function fd(l, t, a) {
        var e = l.pingCache;
        e !== null && e.delete(t),
            (l.pingedLanes |= l.suspendedLanes & a),
            (l.warmLanes &= ~a),
            il === l &&
                (F & a) === a &&
                (vl === 4 || (vl === 3 && (F & 62914560) === F && 300 > xt() - zf)
                    ? (ll & 2) === 0 && ye(l, 0)
                    : (pf |= a),
                de === F && (de = 0)),
            zt(l);
    }
    function S1(l, t) {
        t === 0 && (t = yi()), (l = ka(l, t)), l !== null && (Ae(l, t), zt(l));
    }
    function id(l) {
        var t = l.memoizedState,
            a = 0;
        t !== null && (a = t.retryLane), S1(l, a);
    }
    function sd(l, t) {
        var a = 0;
        switch (l.tag) {
            case 13:
                var e = l.stateNode,
                    u = l.memoizedState;
                u !== null && (a = u.retryLane);
                break;
            case 19:
                e = l.stateNode;
                break;
            case 22:
                e = l.stateNode._retryCache;
                break;
            default:
                throw Error(r(314));
        }
        e !== null && e.delete(t), S1(l, a);
    }
    function rd(l, t) {
        return Ln(l, t);
    }
    var xn = null,
        ge = null,
        Rf = !1,
        Tn = !1,
        Hf = !1,
        Ha = 0;
    function zt(l) {
        l !== ge && l.next === null && (ge === null ? (xn = ge = l) : (ge = ge.next = l)),
            (Tn = !0),
            Rf || ((Rf = !0), dd());
    }
    function fu(l, t) {
        if (!Hf && Tn) {
            Hf = !0;
            do
                for (var a = !1, e = xn; e !== null; ) {
                    if (l !== 0) {
                        var u = e.pendingLanes;
                        if (u === 0) var n = 0;
                        else {
                            var c = e.suspendedLanes,
                                f = e.pingedLanes;
                            (n = (1 << (31 - Wl(42 | l) + 1)) - 1),
                                (n &= u & ~(c & ~f)),
                                (n = n & 201326741 ? (n & 201326741) | 1 : n ? n | 2 : 0);
                        }
                        n !== 0 && ((a = !0), p1(e, n));
                    } else
                        (n = F),
                            (n = Ou(e, e === il ? n : 0, e.cancelPendingCommit !== null || e.timeoutHandle !== -1)),
                            (n & 3) === 0 || pe(e, n) || ((a = !0), p1(e, n));
                    e = e.next;
                }
            while (a);
            Hf = !1;
        }
    }
    function od() {
        x1();
    }
    function x1() {
        Tn = Rf = !1;
        var l = 0;
        Ha !== 0 && (xd() && (l = Ha), (Ha = 0));
        for (var t = xt(), a = null, e = xn; e !== null; ) {
            var u = e.next,
                n = T1(e, t);
            n === 0
                ? ((e.next = null), a === null ? (xn = u) : (a.next = u), u === null && (ge = a))
                : ((a = e), (l !== 0 || (n & 3) !== 0) && (Tn = !0)),
                (e = u);
        }
        fu(l);
    }
    function T1(l, t) {
        for (
            var a = l.suspendedLanes, e = l.pingedLanes, u = l.expirationTimes, n = l.pendingLanes & -62914561;
            0 < n;

        ) {
            var c = 31 - Wl(n),
                f = 1 << c,
                i = u[c];
            i === -1 ? ((f & a) === 0 || (f & e) !== 0) && (u[c] = Cr(f, t)) : i <= t && (l.expiredLanes |= f),
                (n &= ~f);
        }
        if (
            ((t = il),
            (a = F),
            (a = Ou(l, l === t ? a : 0, l.cancelPendingCommit !== null || l.timeoutHandle !== -1)),
            (e = l.callbackNode),
            a === 0 || (l === t && (tl === 2 || tl === 9)) || l.cancelPendingCommit !== null)
        )
            return e !== null && e !== null && wn(e), (l.callbackNode = null), (l.callbackPriority = 0);
        if ((a & 3) === 0 || pe(l, a)) {
            if (((t = a & -a), t === l.callbackPriority)) return t;
            switch ((e !== null && wn(e), Fn(a))) {
                case 2:
                case 8:
                    a = di;
                    break;
                case 32:
                    a = pu;
                    break;
                case 268435456:
                    a = hi;
                    break;
                default:
                    a = pu;
            }
            return (e = E1.bind(null, l)), (a = Ln(a, e)), (l.callbackPriority = t), (l.callbackNode = a), t;
        }
        return e !== null && e !== null && wn(e), (l.callbackPriority = 2), (l.callbackNode = null), 2;
    }
    function E1(l, t) {
        if (Ol !== 0 && Ol !== 5) return (l.callbackNode = null), (l.callbackPriority = 0), null;
        var a = l.callbackNode;
        if (Sn() && l.callbackNode !== a) return null;
        var e = F;
        return (
            (e = Ou(l, l === il ? e : 0, l.cancelPendingCommit !== null || l.timeoutHandle !== -1)),
            e === 0
                ? null
                : (u1(l, e, t), T1(l, xt()), l.callbackNode != null && l.callbackNode === a ? E1.bind(null, l) : null)
        );
    }
    function p1(l, t) {
        if (Sn()) return null;
        u1(l, t, !0);
    }
    function dd() {
        Ed(function () {
            (ll & 6) !== 0 ? Ln(oi, od) : x1();
        });
    }
    function Bf() {
        return Ha === 0 && (Ha = vi()), Ha;
    }
    function A1(l) {
        return l == null || typeof l == "symbol" || typeof l == "boolean"
            ? null
            : typeof l == "function"
              ? l
              : ju("" + l);
    }
    function z1(l, t) {
        var a = t.ownerDocument.createElement("input");
        return (
            (a.name = t.name),
            (a.value = t.value),
            l.id && a.setAttribute("form", l.id),
            t.parentNode.insertBefore(a, t),
            (l = new FormData(l)),
            a.parentNode.removeChild(a),
            l
        );
    }
    function hd(l, t, a, e, u) {
        if (t === "submit" && a && a.stateNode === u) {
            var n = A1((u[Gl] || null).action),
                c = e.submitter;
            c &&
                ((t = (t = c[Gl] || null) ? A1(t.formAction) : c.getAttribute("formAction")),
                t !== null && ((n = t), (c = null)));
            var f = new Bu("action", "action", null, e, u);
            l.push({
                event: f,
                listeners: [
                    {
                        instance: null,
                        listener: function () {
                            if (e.defaultPrevented) {
                                if (Ha !== 0) {
                                    var i = c ? z1(u, c) : new FormData(u);
                                    lf(a, { pending: !0, data: i, method: u.method, action: n }, null, i);
                                }
                            } else
                                typeof n == "function" &&
                                    (f.preventDefault(),
                                    (i = c ? z1(u, c) : new FormData(u)),
                                    lf(a, { pending: !0, data: i, method: u.method, action: n }, n, i));
                        },
                        currentTarget: u,
                    },
                ],
            });
        }
    }
    for (var Cf = 0; Cf < Sc.length; Cf++) {
        var qf = Sc[Cf],
            vd = qf.toLowerCase(),
            yd = qf[0].toUpperCase() + qf.slice(1);
        mt(vd, "on" + yd);
    }
    mt(u0, "onAnimationEnd"),
        mt(n0, "onAnimationIteration"),
        mt(c0, "onAnimationStart"),
        mt("dblclick", "onDoubleClick"),
        mt("focusin", "onFocus"),
        mt("focusout", "onBlur"),
        mt(Uo, "onTransitionRun"),
        mt(Ro, "onTransitionStart"),
        mt(Ho, "onTransitionCancel"),
        mt(f0, "onTransitionEnd"),
        Qa("onMouseEnter", ["mouseout", "mouseover"]),
        Qa("onMouseLeave", ["mouseout", "mouseover"]),
        Qa("onPointerEnter", ["pointerout", "pointerover"]),
        Qa("onPointerLeave", ["pointerout", "pointerover"]),
        ba("onChange", "change click focusin focusout input keydown keyup selectionchange".split(" ")),
        ba(
            "onSelect",
            "focusout contextmenu dragend focusin keydown keyup mousedown mouseup selectionchange".split(" ")
        ),
        ba("onBeforeInput", ["compositionend", "keypress", "textInput", "paste"]),
        ba("onCompositionEnd", "compositionend focusout keydown keypress keyup mousedown".split(" ")),
        ba("onCompositionStart", "compositionstart focusout keydown keypress keyup mousedown".split(" ")),
        ba("onCompositionUpdate", "compositionupdate focusout keydown keypress keyup mousedown".split(" "));
    var iu =
            "abort canplay canplaythrough durationchange emptied encrypted ended error loadeddata loadedmetadata loadstart pause play playing progress ratechange resize seeked seeking stalled suspend timeupdate volumechange waiting".split(
                " "
            ),
        md = new Set("beforetoggle cancel close invalid load scroll scrollend toggle".split(" ").concat(iu));
    function O1(l, t) {
        t = (t & 4) !== 0;
        for (var a = 0; a < l.length; a++) {
            var e = l[a],
                u = e.event;
            e = e.listeners;
            l: {
                var n = void 0;
                if (t)
                    for (var c = e.length - 1; 0 <= c; c--) {
                        var f = e[c],
                            i = f.instance,
                            y = f.currentTarget;
                        if (((f = f.listener), i !== n && u.isPropagationStopped())) break l;
                        (n = f), (u.currentTarget = y);
                        try {
                            n(u);
                        } catch (T) {
                            fn(T);
                        }
                        (u.currentTarget = null), (n = i);
                    }
                else
                    for (c = 0; c < e.length; c++) {
                        if (
                            ((f = e[c]),
                            (i = f.instance),
                            (y = f.currentTarget),
                            (f = f.listener),
                            i !== n && u.isPropagationStopped())
                        )
                            break l;
                        (n = f), (u.currentTarget = y);
                        try {
                            n(u);
                        } catch (T) {
                            fn(T);
                        }
                        (u.currentTarget = null), (n = i);
                    }
            }
        }
    }
    function J(l, t) {
        var a = t[Wn];
        a === void 0 && (a = t[Wn] = new Set());
        var e = l + "__bubble";
        a.has(e) || (M1(t, l, 2, !1), a.add(e));
    }
    function Yf(l, t, a) {
        var e = 0;
        t && (e |= 4), M1(a, l, e, t);
    }
    var En = "_reactListening" + Math.random().toString(36).slice(2);
    function Gf(l) {
        if (!l[En]) {
            (l[En] = !0),
                xi.forEach(function (a) {
                    a !== "selectionchange" && (md.has(a) || Yf(a, !1, l), Yf(a, !0, l));
                });
            var t = l.nodeType === 9 ? l : l.ownerDocument;
            t === null || t[En] || ((t[En] = !0), Yf("selectionchange", !1, t));
        }
    }
    function M1(l, t, a, e) {
        switch (k1(t)) {
            case 2:
                var u = Vd;
                break;
            case 8:
                u = Ld;
                break;
            default:
                u = If;
        }
        (a = u.bind(null, t, a, l)),
            (u = void 0),
            !cc || (t !== "touchstart" && t !== "touchmove" && t !== "wheel") || (u = !0),
            e
                ? u !== void 0
                    ? l.addEventListener(t, a, { capture: !0, passive: u })
                    : l.addEventListener(t, a, !0)
                : u !== void 0
                  ? l.addEventListener(t, a, { passive: u })
                  : l.addEventListener(t, a, !1);
    }
    function Xf(l, t, a, e, u) {
        var n = e;
        if ((t & 1) === 0 && (t & 2) === 0 && e !== null)
            l: for (;;) {
                if (e === null) return;
                var c = e.tag;
                if (c === 3 || c === 4) {
                    var f = e.stateNode.containerInfo;
                    if (f === u) break;
                    if (c === 4)
                        for (c = e.return; c !== null; ) {
                            var i = c.tag;
                            if ((i === 3 || i === 4) && c.stateNode.containerInfo === u) return;
                            c = c.return;
                        }
                    for (; f !== null; ) {
                        if (((c = Ya(f)), c === null)) return;
                        if (((i = c.tag), i === 5 || i === 6 || i === 26 || i === 27)) {
                            e = n = c;
                            continue l;
                        }
                        f = f.parentNode;
                    }
                }
                e = e.return;
            }
        Hi(function () {
            var y = n,
                T = uc(a),
                A = [];
            l: {
                var m = i0.get(l);
                if (m !== void 0) {
                    var g = Bu,
                        X = l;
                    switch (l) {
                        case "keypress":
                            if (Ru(a) === 0) break l;
                        case "keydown":
                        case "keyup":
                            g = so;
                            break;
                        case "focusin":
                            (X = "focus"), (g = rc);
                            break;
                        case "focusout":
                            (X = "blur"), (g = rc);
                            break;
                        case "beforeblur":
                        case "afterblur":
                            g = rc;
                            break;
                        case "click":
                            if (a.button === 2) break l;
                        case "auxclick":
                        case "dblclick":
                        case "mousedown":
                        case "mousemove":
                        case "mouseup":
                        case "mouseout":
                        case "mouseover":
                        case "contextmenu":
                            g = qi;
                            break;
                        case "drag":
                        case "dragend":
                        case "dragenter":
                        case "dragexit":
                        case "dragleave":
                        case "dragover":
                        case "dragstart":
                        case "drop":
                            g = kr;
                            break;
                        case "touchcancel":
                        case "touchend":
                        case "touchmove":
                        case "touchstart":
                            g = ho;
                            break;
                        case u0:
                        case n0:
                        case c0:
                            g = lo;
                            break;
                        case f0:
                            g = yo;
                            break;
                        case "scroll":
                        case "scrollend":
                            g = Wr;
                            break;
                        case "wheel":
                            g = go;
                            break;
                        case "copy":
                        case "cut":
                        case "paste":
                            g = ao;
                            break;
                        case "gotpointercapture":
                        case "lostpointercapture":
                        case "pointercancel":
                        case "pointerdown":
                        case "pointermove":
                        case "pointerout":
                        case "pointerover":
                        case "pointerup":
                            g = Gi;
                            break;
                        case "toggle":
                        case "beforetoggle":
                            g = So;
                    }
                    var q = (t & 4) !== 0,
                        ul = !q && (l === "scroll" || l === "scrollend"),
                        h = q ? (m !== null ? m + "Capture" : null) : m;
                    q = [];
                    for (var d = y, v; d !== null; ) {
                        var p = d;
                        if (
                            ((v = p.stateNode),
                            (p = p.tag),
                            (p !== 5 && p !== 26 && p !== 27) ||
                                v === null ||
                                h === null ||
                                ((p = Me(d, h)), p != null && q.push(su(d, p, v))),
                            ul)
                        )
                            break;
                        d = d.return;
                    }
                    0 < q.length && ((m = new g(m, X, null, a, T)), A.push({ event: m, listeners: q }));
                }
            }
            if ((t & 7) === 0) {
                l: {
                    if (
                        ((m = l === "mouseover" || l === "pointerover"),
                        (g = l === "mouseout" || l === "pointerout"),
                        m && a !== ec && (X = a.relatedTarget || a.fromElement) && (Ya(X) || X[qa]))
                    )
                        break l;
                    if (
                        (g || m) &&
                        ((m = T.window === T ? T : (m = T.ownerDocument) ? m.defaultView || m.parentWindow : window),
                        g
                            ? ((X = a.relatedTarget || a.toElement),
                              (g = y),
                              (X = X ? Ya(X) : null),
                              X !== null &&
                                  ((ul = H(X)), (q = X.tag), X !== ul || (q !== 5 && q !== 27 && q !== 6)) &&
                                  (X = null))
                            : ((g = null), (X = y)),
                        g !== X)
                    ) {
                        if (
                            ((q = qi),
                            (p = "onMouseLeave"),
                            (h = "onMouseEnter"),
                            (d = "mouse"),
                            (l === "pointerout" || l === "pointerover") &&
                                ((q = Gi), (p = "onPointerLeave"), (h = "onPointerEnter"), (d = "pointer")),
                            (ul = g == null ? m : Oe(g)),
                            (v = X == null ? m : Oe(X)),
                            (m = new q(p, d + "leave", g, a, T)),
                            (m.target = ul),
                            (m.relatedTarget = v),
                            (p = null),
                            Ya(T) === y &&
                                ((q = new q(h, d + "enter", X, a, T)), (q.target = v), (q.relatedTarget = ul), (p = q)),
                            (ul = p),
                            g && X)
                        )
                            t: {
                                for (q = g, h = X, d = 0, v = q; v; v = be(v)) d++;
                                for (v = 0, p = h; p; p = be(p)) v++;
                                for (; 0 < d - v; ) (q = be(q)), d--;
                                for (; 0 < v - d; ) (h = be(h)), v--;
                                for (; d--; ) {
                                    if (q === h || (h !== null && q === h.alternate)) break t;
                                    (q = be(q)), (h = be(h));
                                }
                                q = null;
                            }
                        else q = null;
                        g !== null && N1(A, m, g, q, !1), X !== null && ul !== null && N1(A, ul, X, q, !0);
                    }
                }
                l: {
                    if (
                        ((m = y ? Oe(y) : window),
                        (g = m.nodeName && m.nodeName.toLowerCase()),
                        g === "select" || (g === "input" && m.type === "file"))
                    )
                        var U = Ji;
                    else if (wi(m))
                        if (Fi) U = _o;
                        else {
                            U = Mo;
                            var w = Oo;
                        }
                    else
                        (g = m.nodeName),
                            !g || g.toLowerCase() !== "input" || (m.type !== "checkbox" && m.type !== "radio")
                                ? y && ac(y.elementType) && (U = Ji)
                                : (U = No);
                    if (U && (U = U(l, y))) {
                        Ki(A, U, a, T);
                        break l;
                    }
                    w && w(l, m, y),
                        l === "focusout" &&
                            y &&
                            m.type === "number" &&
                            y.memoizedProps.value != null &&
                            tc(m, "number", m.value);
                }
                switch (((w = y ? Oe(y) : window), l)) {
                    case "focusin":
                        (wi(w) || w.contentEditable === "true") && ((Fa = w), (mc = y), (Be = null));
                        break;
                    case "focusout":
                        Be = mc = Fa = null;
                        break;
                    case "mousedown":
                        gc = !0;
                        break;
                    case "contextmenu":
                    case "mouseup":
                    case "dragend":
                        (gc = !1), a0(A, a, T);
                        break;
                    case "selectionchange":
                        if (jo) break;
                    case "keydown":
                    case "keyup":
                        a0(A, a, T);
                }
                var R;
                if (dc)
                    l: {
                        switch (l) {
                            case "compositionstart":
                                var Y = "onCompositionStart";
                                break l;
                            case "compositionend":
                                Y = "onCompositionEnd";
                                break l;
                            case "compositionupdate":
                                Y = "onCompositionUpdate";
                                break l;
                        }
                        Y = void 0;
                    }
                else
                    Ja
                        ? Vi(l, a) && (Y = "onCompositionEnd")
                        : l === "keydown" && a.keyCode === 229 && (Y = "onCompositionStart");
                Y &&
                    (Xi &&
                        a.locale !== "ko" &&
                        (Ja || Y !== "onCompositionStart"
                            ? Y === "onCompositionEnd" && Ja && (R = Bi())
                            : ((Kt = T), (fc = "value" in Kt ? Kt.value : Kt.textContent), (Ja = !0))),
                    (w = pn(y, Y)),
                    0 < w.length &&
                        ((Y = new Yi(Y, l, null, a, T)),
                        A.push({ event: Y, listeners: w }),
                        R ? (Y.data = R) : ((R = Li(a)), R !== null && (Y.data = R)))),
                    (R = To ? Eo(l, a) : po(l, a)) &&
                        ((Y = pn(y, "onBeforeInput")),
                        0 < Y.length &&
                            ((w = new Yi("onBeforeInput", "beforeinput", null, a, T)),
                            A.push({ event: w, listeners: Y }),
                            (w.data = R))),
                    hd(A, l, y, a, T);
            }
            O1(A, t);
        });
    }
    function su(l, t, a) {
        return { instance: l, listener: t, currentTarget: a };
    }
    function pn(l, t) {
        for (var a = t + "Capture", e = []; l !== null; ) {
            var u = l,
                n = u.stateNode;
            if (
                ((u = u.tag),
                (u !== 5 && u !== 26 && u !== 27) ||
                    n === null ||
                    ((u = Me(l, a)),
                    u != null && e.unshift(su(l, u, n)),
                    (u = Me(l, t)),
                    u != null && e.push(su(l, u, n))),
                l.tag === 3)
            )
                return e;
            l = l.return;
        }
        return [];
    }
    function be(l) {
        if (l === null) return null;
        do l = l.return;
        while (l && l.tag !== 5 && l.tag !== 27);
        return l || null;
    }
    function N1(l, t, a, e, u) {
        for (var n = t._reactName, c = []; a !== null && a !== e; ) {
            var f = a,
                i = f.alternate,
                y = f.stateNode;
            if (((f = f.tag), i !== null && i === e)) break;
            (f !== 5 && f !== 26 && f !== 27) ||
                y === null ||
                ((i = y),
                u
                    ? ((y = Me(a, n)), y != null && c.unshift(su(a, y, i)))
                    : u || ((y = Me(a, n)), y != null && c.push(su(a, y, i)))),
                (a = a.return);
        }
        c.length !== 0 && l.push({ event: t, listeners: c });
    }
    var gd = /\r\n?/g,
        bd = /\u0000|\uFFFD/g;
    function _1(l) {
        return (typeof l == "string" ? l : "" + l)
            .replace(
                gd,
                `
`
            )
            .replace(bd, "");
    }
    function D1(l, t) {
        return (t = _1(t)), _1(l) === t;
    }
    function An() {}
    function el(l, t, a, e, u, n) {
        switch (a) {
            case "children":
                typeof e == "string"
                    ? t === "body" || (t === "textarea" && e === "") || La(l, e)
                    : (typeof e == "number" || typeof e == "bigint") && t !== "body" && La(l, "" + e);
                break;
            case "className":
                Nu(l, "class", e);
                break;
            case "tabIndex":
                Nu(l, "tabindex", e);
                break;
            case "dir":
            case "role":
            case "viewBox":
            case "width":
            case "height":
                Nu(l, a, e);
                break;
            case "style":
                Ui(l, e, n);
                break;
            case "data":
                if (t !== "object") {
                    Nu(l, "data", e);
                    break;
                }
            case "src":
            case "href":
                if (e === "" && (t !== "a" || a !== "href")) {
                    l.removeAttribute(a);
                    break;
                }
                if (e == null || typeof e == "function" || typeof e == "symbol" || typeof e == "boolean") {
                    l.removeAttribute(a);
                    break;
                }
                (e = ju("" + e)), l.setAttribute(a, e);
                break;
            case "action":
            case "formAction":
                if (typeof e == "function") {
                    l.setAttribute(
                        a,
                        "javascript:throw new Error('A React form was unexpectedly submitted. If you called form.submit() manually, consider using form.requestSubmit() instead. If you\\'re trying to use event.stopPropagation() in a submit event handler, consider also calling event.preventDefault().')"
                    );
                    break;
                } else
                    typeof n == "function" &&
                        (a === "formAction"
                            ? (t !== "input" && el(l, t, "name", u.name, u, null),
                              el(l, t, "formEncType", u.formEncType, u, null),
                              el(l, t, "formMethod", u.formMethod, u, null),
                              el(l, t, "formTarget", u.formTarget, u, null))
                            : (el(l, t, "encType", u.encType, u, null),
                              el(l, t, "method", u.method, u, null),
                              el(l, t, "target", u.target, u, null)));
                if (e == null || typeof e == "symbol" || typeof e == "boolean") {
                    l.removeAttribute(a);
                    break;
                }
                (e = ju("" + e)), l.setAttribute(a, e);
                break;
            case "onClick":
                e != null && (l.onclick = An);
                break;
            case "onScroll":
                e != null && J("scroll", l);
                break;
            case "onScrollEnd":
                e != null && J("scrollend", l);
                break;
            case "dangerouslySetInnerHTML":
                if (e != null) {
                    if (typeof e != "object" || !("__html" in e)) throw Error(r(61));
                    if (((a = e.__html), a != null)) {
                        if (u.children != null) throw Error(r(60));
                        l.innerHTML = a;
                    }
                }
                break;
            case "multiple":
                l.multiple = e && typeof e != "function" && typeof e != "symbol";
                break;
            case "muted":
                l.muted = e && typeof e != "function" && typeof e != "symbol";
                break;
            case "suppressContentEditableWarning":
            case "suppressHydrationWarning":
            case "defaultValue":
            case "defaultChecked":
            case "innerHTML":
            case "ref":
                break;
            case "autoFocus":
                break;
            case "xlinkHref":
                if (e == null || typeof e == "function" || typeof e == "boolean" || typeof e == "symbol") {
                    l.removeAttribute("xlink:href");
                    break;
                }
                (a = ju("" + e)), l.setAttributeNS("http://www.w3.org/1999/xlink", "xlink:href", a);
                break;
            case "contentEditable":
            case "spellCheck":
            case "draggable":
            case "value":
            case "autoReverse":
            case "externalResourcesRequired":
            case "focusable":
            case "preserveAlpha":
                e != null && typeof e != "function" && typeof e != "symbol"
                    ? l.setAttribute(a, "" + e)
                    : l.removeAttribute(a);
                break;
            case "inert":
            case "allowFullScreen":
            case "async":
            case "autoPlay":
            case "controls":
            case "default":
            case "defer":
            case "disabled":
            case "disablePictureInPicture":
            case "disableRemotePlayback":
            case "formNoValidate":
            case "hidden":
            case "loop":
            case "noModule":
            case "noValidate":
            case "open":
            case "playsInline":
            case "readOnly":
            case "required":
            case "reversed":
            case "scoped":
            case "seamless":
            case "itemScope":
                e && typeof e != "function" && typeof e != "symbol" ? l.setAttribute(a, "") : l.removeAttribute(a);
                break;
            case "capture":
            case "download":
                e === !0
                    ? l.setAttribute(a, "")
                    : e !== !1 && e != null && typeof e != "function" && typeof e != "symbol"
                      ? l.setAttribute(a, e)
                      : l.removeAttribute(a);
                break;
            case "cols":
            case "rows":
            case "size":
            case "span":
                e != null && typeof e != "function" && typeof e != "symbol" && !isNaN(e) && 1 <= e
                    ? l.setAttribute(a, e)
                    : l.removeAttribute(a);
                break;
            case "rowSpan":
            case "start":
                e == null || typeof e == "function" || typeof e == "symbol" || isNaN(e)
                    ? l.removeAttribute(a)
                    : l.setAttribute(a, e);
                break;
            case "popover":
                J("beforetoggle", l), J("toggle", l), Mu(l, "popover", e);
                break;
            case "xlinkActuate":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:actuate", e);
                break;
            case "xlinkArcrole":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:arcrole", e);
                break;
            case "xlinkRole":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:role", e);
                break;
            case "xlinkShow":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:show", e);
                break;
            case "xlinkTitle":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:title", e);
                break;
            case "xlinkType":
                Nt(l, "http://www.w3.org/1999/xlink", "xlink:type", e);
                break;
            case "xmlBase":
                Nt(l, "http://www.w3.org/XML/1998/namespace", "xml:base", e);
                break;
            case "xmlLang":
                Nt(l, "http://www.w3.org/XML/1998/namespace", "xml:lang", e);
                break;
            case "xmlSpace":
                Nt(l, "http://www.w3.org/XML/1998/namespace", "xml:space", e);
                break;
            case "is":
                Mu(l, "is", e);
                break;
            case "innerText":
            case "textContent":
                break;
            default:
                (!(2 < a.length) || (a[0] !== "o" && a[0] !== "O") || (a[1] !== "n" && a[1] !== "N")) &&
                    ((a = Jr.get(a) || a), Mu(l, a, e));
        }
    }
    function Qf(l, t, a, e, u, n) {
        switch (a) {
            case "style":
                Ui(l, e, n);
                break;
            case "dangerouslySetInnerHTML":
                if (e != null) {
                    if (typeof e != "object" || !("__html" in e)) throw Error(r(61));
                    if (((a = e.__html), a != null)) {
                        if (u.children != null) throw Error(r(60));
                        l.innerHTML = a;
                    }
                }
                break;
            case "children":
                typeof e == "string" ? La(l, e) : (typeof e == "number" || typeof e == "bigint") && La(l, "" + e);
                break;
            case "onScroll":
                e != null && J("scroll", l);
                break;
            case "onScrollEnd":
                e != null && J("scrollend", l);
                break;
            case "onClick":
                e != null && (l.onclick = An);
                break;
            case "suppressContentEditableWarning":
            case "suppressHydrationWarning":
            case "innerHTML":
            case "ref":
                break;
            case "innerText":
            case "textContent":
                break;
            default:
                if (!Ti.hasOwnProperty(a))
                    l: {
                        if (
                            a[0] === "o" &&
                            a[1] === "n" &&
                            ((u = a.endsWith("Capture")),
                            (t = a.slice(2, u ? a.length - 7 : void 0)),
                            (n = l[Gl] || null),
                            (n = n != null ? n[a] : null),
                            typeof n == "function" && l.removeEventListener(t, n, u),
                            typeof e == "function")
                        ) {
                            typeof n != "function" &&
                                n !== null &&
                                (a in l ? (l[a] = null) : l.hasAttribute(a) && l.removeAttribute(a)),
                                l.addEventListener(t, e, u);
                            break l;
                        }
                        a in l ? (l[a] = e) : e === !0 ? l.setAttribute(a, "") : Mu(l, a, e);
                    }
        }
    }
    function Ml(l, t, a) {
        switch (t) {
            case "div":
            case "span":
            case "svg":
            case "path":
            case "a":
            case "g":
            case "p":
            case "li":
                break;
            case "img":
                J("error", l), J("load", l);
                var e = !1,
                    u = !1,
                    n;
                for (n in a)
                    if (a.hasOwnProperty(n)) {
                        var c = a[n];
                        if (c != null)
                            switch (n) {
                                case "src":
                                    e = !0;
                                    break;
                                case "srcSet":
                                    u = !0;
                                    break;
                                case "children":
                                case "dangerouslySetInnerHTML":
                                    throw Error(r(137, t));
                                default:
                                    el(l, t, n, c, a, null);
                            }
                    }
                u && el(l, t, "srcSet", a.srcSet, a, null), e && el(l, t, "src", a.src, a, null);
                return;
            case "input":
                J("invalid", l);
                var f = (n = c = u = null),
                    i = null,
                    y = null;
                for (e in a)
                    if (a.hasOwnProperty(e)) {
                        var T = a[e];
                        if (T != null)
                            switch (e) {
                                case "name":
                                    u = T;
                                    break;
                                case "type":
                                    c = T;
                                    break;
                                case "checked":
                                    i = T;
                                    break;
                                case "defaultChecked":
                                    y = T;
                                    break;
                                case "value":
                                    n = T;
                                    break;
                                case "defaultValue":
                                    f = T;
                                    break;
                                case "children":
                                case "dangerouslySetInnerHTML":
                                    if (T != null) throw Error(r(137, t));
                                    break;
                                default:
                                    el(l, t, e, T, a, null);
                            }
                    }
                Ni(l, n, f, i, y, c, u, !1), _u(l);
                return;
            case "select":
                J("invalid", l), (e = c = n = null);
                for (u in a)
                    if (a.hasOwnProperty(u) && ((f = a[u]), f != null))
                        switch (u) {
                            case "value":
                                n = f;
                                break;
                            case "defaultValue":
                                c = f;
                                break;
                            case "multiple":
                                e = f;
                            default:
                                el(l, t, u, f, a, null);
                        }
                (t = n), (a = c), (l.multiple = !!e), t != null ? Va(l, !!e, t, !1) : a != null && Va(l, !!e, a, !0);
                return;
            case "textarea":
                J("invalid", l), (n = u = e = null);
                for (c in a)
                    if (a.hasOwnProperty(c) && ((f = a[c]), f != null))
                        switch (c) {
                            case "value":
                                e = f;
                                break;
                            case "defaultValue":
                                u = f;
                                break;
                            case "children":
                                n = f;
                                break;
                            case "dangerouslySetInnerHTML":
                                if (f != null) throw Error(r(91));
                                break;
                            default:
                                el(l, t, c, f, a, null);
                        }
                Di(l, e, u, n), _u(l);
                return;
            case "option":
                for (i in a)
                    if (a.hasOwnProperty(i) && ((e = a[i]), e != null))
                        switch (i) {
                            case "selected":
                                l.selected = e && typeof e != "function" && typeof e != "symbol";
                                break;
                            default:
                                el(l, t, i, e, a, null);
                        }
                return;
            case "dialog":
                J("beforetoggle", l), J("toggle", l), J("cancel", l), J("close", l);
                break;
            case "iframe":
            case "object":
                J("load", l);
                break;
            case "video":
            case "audio":
                for (e = 0; e < iu.length; e++) J(iu[e], l);
                break;
            case "image":
                J("error", l), J("load", l);
                break;
            case "details":
                J("toggle", l);
                break;
            case "embed":
            case "source":
            case "link":
                J("error", l), J("load", l);
            case "area":
            case "base":
            case "br":
            case "col":
            case "hr":
            case "keygen":
            case "meta":
            case "param":
            case "track":
            case "wbr":
            case "menuitem":
                for (y in a)
                    if (a.hasOwnProperty(y) && ((e = a[y]), e != null))
                        switch (y) {
                            case "children":
                            case "dangerouslySetInnerHTML":
                                throw Error(r(137, t));
                            default:
                                el(l, t, y, e, a, null);
                        }
                return;
            default:
                if (ac(t)) {
                    for (T in a) a.hasOwnProperty(T) && ((e = a[T]), e !== void 0 && Qf(l, t, T, e, a, void 0));
                    return;
                }
        }
        for (f in a) a.hasOwnProperty(f) && ((e = a[f]), e != null && el(l, t, f, e, a, null));
    }
    function Sd(l, t, a, e) {
        switch (t) {
            case "div":
            case "span":
            case "svg":
            case "path":
            case "a":
            case "g":
            case "p":
            case "li":
                break;
            case "input":
                var u = null,
                    n = null,
                    c = null,
                    f = null,
                    i = null,
                    y = null,
                    T = null;
                for (g in a) {
                    var A = a[g];
                    if (a.hasOwnProperty(g) && A != null)
                        switch (g) {
                            case "checked":
                                break;
                            case "value":
                                break;
                            case "defaultValue":
                                i = A;
                            default:
                                e.hasOwnProperty(g) || el(l, t, g, null, e, A);
                        }
                }
                for (var m in e) {
                    var g = e[m];
                    if (((A = a[m]), e.hasOwnProperty(m) && (g != null || A != null)))
                        switch (m) {
                            case "type":
                                n = g;
                                break;
                            case "name":
                                u = g;
                                break;
                            case "checked":
                                y = g;
                                break;
                            case "defaultChecked":
                                T = g;
                                break;
                            case "value":
                                c = g;
                                break;
                            case "defaultValue":
                                f = g;
                                break;
                            case "children":
                            case "dangerouslySetInnerHTML":
                                if (g != null) throw Error(r(137, t));
                                break;
                            default:
                                g !== A && el(l, t, m, g, e, A);
                        }
                }
                lc(l, c, f, i, y, T, n, u);
                return;
            case "select":
                g = c = f = m = null;
                for (n in a)
                    if (((i = a[n]), a.hasOwnProperty(n) && i != null))
                        switch (n) {
                            case "value":
                                break;
                            case "multiple":
                                g = i;
                            default:
                                e.hasOwnProperty(n) || el(l, t, n, null, e, i);
                        }
                for (u in e)
                    if (((n = e[u]), (i = a[u]), e.hasOwnProperty(u) && (n != null || i != null)))
                        switch (u) {
                            case "value":
                                m = n;
                                break;
                            case "defaultValue":
                                f = n;
                                break;
                            case "multiple":
                                c = n;
                            default:
                                n !== i && el(l, t, u, n, e, i);
                        }
                (t = f),
                    (a = c),
                    (e = g),
                    m != null
                        ? Va(l, !!a, m, !1)
                        : !!e != !!a && (t != null ? Va(l, !!a, t, !0) : Va(l, !!a, a ? [] : "", !1));
                return;
            case "textarea":
                g = m = null;
                for (f in a)
                    if (((u = a[f]), a.hasOwnProperty(f) && u != null && !e.hasOwnProperty(f)))
                        switch (f) {
                            case "value":
                                break;
                            case "children":
                                break;
                            default:
                                el(l, t, f, null, e, u);
                        }
                for (c in e)
                    if (((u = e[c]), (n = a[c]), e.hasOwnProperty(c) && (u != null || n != null)))
                        switch (c) {
                            case "value":
                                m = u;
                                break;
                            case "defaultValue":
                                g = u;
                                break;
                            case "children":
                                break;
                            case "dangerouslySetInnerHTML":
                                if (u != null) throw Error(r(91));
                                break;
                            default:
                                u !== n && el(l, t, c, u, e, n);
                        }
                _i(l, m, g);
                return;
            case "option":
                for (var X in a)
                    if (((m = a[X]), a.hasOwnProperty(X) && m != null && !e.hasOwnProperty(X)))
                        switch (X) {
                            case "selected":
                                l.selected = !1;
                                break;
                            default:
                                el(l, t, X, null, e, m);
                        }
                for (i in e)
                    if (((m = e[i]), (g = a[i]), e.hasOwnProperty(i) && m !== g && (m != null || g != null)))
                        switch (i) {
                            case "selected":
                                l.selected = m && typeof m != "function" && typeof m != "symbol";
                                break;
                            default:
                                el(l, t, i, m, e, g);
                        }
                return;
            case "img":
            case "link":
            case "area":
            case "base":
            case "br":
            case "col":
            case "embed":
            case "hr":
            case "keygen":
            case "meta":
            case "param":
            case "source":
            case "track":
            case "wbr":
            case "menuitem":
                for (var q in a)
                    (m = a[q]), a.hasOwnProperty(q) && m != null && !e.hasOwnProperty(q) && el(l, t, q, null, e, m);
                for (y in e)
                    if (((m = e[y]), (g = a[y]), e.hasOwnProperty(y) && m !== g && (m != null || g != null)))
                        switch (y) {
                            case "children":
                            case "dangerouslySetInnerHTML":
                                if (m != null) throw Error(r(137, t));
                                break;
                            default:
                                el(l, t, y, m, e, g);
                        }
                return;
            default:
                if (ac(t)) {
                    for (var ul in a)
                        (m = a[ul]),
                            a.hasOwnProperty(ul) && m !== void 0 && !e.hasOwnProperty(ul) && Qf(l, t, ul, void 0, e, m);
                    for (T in e)
                        (m = e[T]),
                            (g = a[T]),
                            !e.hasOwnProperty(T) || m === g || (m === void 0 && g === void 0) || Qf(l, t, T, m, e, g);
                    return;
                }
        }
        for (var h in a)
            (m = a[h]), a.hasOwnProperty(h) && m != null && !e.hasOwnProperty(h) && el(l, t, h, null, e, m);
        for (A in e)
            (m = e[A]), (g = a[A]), !e.hasOwnProperty(A) || m === g || (m == null && g == null) || el(l, t, A, m, e, g);
    }
    var Zf = null,
        Vf = null;
    function zn(l) {
        return l.nodeType === 9 ? l : l.ownerDocument;
    }
    function j1(l) {
        switch (l) {
            case "http://www.w3.org/2000/svg":
                return 1;
            case "http://www.w3.org/1998/Math/MathML":
                return 2;
            default:
                return 0;
        }
    }
    function U1(l, t) {
        if (l === 0)
            switch (t) {
                case "svg":
                    return 1;
                case "math":
                    return 2;
                default:
                    return 0;
            }
        return l === 1 && t === "foreignObject" ? 0 : l;
    }
    function Lf(l, t) {
        return (
            l === "textarea" ||
            l === "noscript" ||
            typeof t.children == "string" ||
            typeof t.children == "number" ||
            typeof t.children == "bigint" ||
            (typeof t.dangerouslySetInnerHTML == "object" &&
                t.dangerouslySetInnerHTML !== null &&
                t.dangerouslySetInnerHTML.__html != null)
        );
    }
    var wf = null;
    function xd() {
        var l = window.event;
        return l && l.type === "popstate" ? (l === wf ? !1 : ((wf = l), !0)) : ((wf = null), !1);
    }
    var R1 = typeof setTimeout == "function" ? setTimeout : void 0,
        Td = typeof clearTimeout == "function" ? clearTimeout : void 0,
        H1 = typeof Promise == "function" ? Promise : void 0,
        Ed =
            typeof queueMicrotask == "function"
                ? queueMicrotask
                : typeof H1 < "u"
                  ? function (l) {
                        return H1.resolve(null).then(l).catch(pd);
                    }
                  : R1;
    function pd(l) {
        setTimeout(function () {
            throw l;
        });
    }
    function ia(l) {
        return l === "head";
    }
    function B1(l, t) {
        var a = t,
            e = 0,
            u = 0;
        do {
            var n = a.nextSibling;
            if ((l.removeChild(a), n && n.nodeType === 8))
                if (((a = n.data), a === "/$")) {
                    if (0 < e && 8 > e) {
                        a = e;
                        var c = l.ownerDocument;
                        if ((a & 1 && ru(c.documentElement), a & 2 && ru(c.body), a & 4))
                            for (a = c.head, ru(a), c = a.firstChild; c; ) {
                                var f = c.nextSibling,
                                    i = c.nodeName;
                                c[ze] ||
                                    i === "SCRIPT" ||
                                    i === "STYLE" ||
                                    (i === "LINK" && c.rel.toLowerCase() === "stylesheet") ||
                                    a.removeChild(c),
                                    (c = f);
                            }
                    }
                    if (u === 0) {
                        l.removeChild(n), bu(t);
                        return;
                    }
                    u--;
                } else a === "$" || a === "$?" || a === "$!" ? u++ : (e = a.charCodeAt(0) - 48);
            else e = 0;
            a = n;
        } while (a);
        bu(t);
    }
    function Kf(l) {
        var t = l.firstChild;
        for (t && t.nodeType === 10 && (t = t.nextSibling); t; ) {
            var a = t;
            switch (((t = t.nextSibling), a.nodeName)) {
                case "HTML":
                case "HEAD":
                case "BODY":
                    Kf(a), $n(a);
                    continue;
                case "SCRIPT":
                case "STYLE":
                    continue;
                case "LINK":
                    if (a.rel.toLowerCase() === "stylesheet") continue;
            }
            l.removeChild(a);
        }
    }
    function Ad(l, t, a, e) {
        for (; l.nodeType === 1; ) {
            var u = a;
            if (l.nodeName.toLowerCase() !== t.toLowerCase()) {
                if (!e && (l.nodeName !== "INPUT" || l.type !== "hidden")) break;
            } else if (e) {
                if (!l[ze])
                    switch (t) {
                        case "meta":
                            if (!l.hasAttribute("itemprop")) break;
                            return l;
                        case "link":
                            if (((n = l.getAttribute("rel")), n === "stylesheet" && l.hasAttribute("data-precedence")))
                                break;
                            if (
                                n !== u.rel ||
                                l.getAttribute("href") !== (u.href == null || u.href === "" ? null : u.href) ||
                                l.getAttribute("crossorigin") !== (u.crossOrigin == null ? null : u.crossOrigin) ||
                                l.getAttribute("title") !== (u.title == null ? null : u.title)
                            )
                                break;
                            return l;
                        case "style":
                            if (l.hasAttribute("data-precedence")) break;
                            return l;
                        case "script":
                            if (
                                ((n = l.getAttribute("src")),
                                (n !== (u.src == null ? null : u.src) ||
                                    l.getAttribute("type") !== (u.type == null ? null : u.type) ||
                                    l.getAttribute("crossorigin") !== (u.crossOrigin == null ? null : u.crossOrigin)) &&
                                    n &&
                                    l.hasAttribute("async") &&
                                    !l.hasAttribute("itemprop"))
                            )
                                break;
                            return l;
                        default:
                            return l;
                    }
            } else if (t === "input" && l.type === "hidden") {
                var n = u.name == null ? null : "" + u.name;
                if (u.type === "hidden" && l.getAttribute("name") === n) return l;
            } else return l;
            if (((l = bt(l.nextSibling)), l === null)) break;
        }
        return null;
    }
    function zd(l, t, a) {
        if (t === "") return null;
        for (; l.nodeType !== 3; )
            if (
                ((l.nodeType !== 1 || l.nodeName !== "INPUT" || l.type !== "hidden") && !a) ||
                ((l = bt(l.nextSibling)), l === null)
            )
                return null;
        return l;
    }
    function Jf(l) {
        return l.data === "$!" || (l.data === "$?" && l.ownerDocument.readyState === "complete");
    }
    function Od(l, t) {
        var a = l.ownerDocument;
        if (l.data !== "$?" || a.readyState === "complete") t();
        else {
            var e = function () {
                t(), a.removeEventListener("DOMContentLoaded", e);
            };
            a.addEventListener("DOMContentLoaded", e), (l._reactRetry = e);
        }
    }
    function bt(l) {
        for (; l != null; l = l.nextSibling) {
            var t = l.nodeType;
            if (t === 1 || t === 3) break;
            if (t === 8) {
                if (((t = l.data), t === "$" || t === "$!" || t === "$?" || t === "F!" || t === "F")) break;
                if (t === "/$") return null;
            }
        }
        return l;
    }
    var Ff = null;
    function C1(l) {
        l = l.previousSibling;
        for (var t = 0; l; ) {
            if (l.nodeType === 8) {
                var a = l.data;
                if (a === "$" || a === "$!" || a === "$?") {
                    if (t === 0) return l;
                    t--;
                } else a === "/$" && t++;
            }
            l = l.previousSibling;
        }
        return null;
    }
    function q1(l, t, a) {
        switch (((t = zn(a)), l)) {
            case "html":
                if (((l = t.documentElement), !l)) throw Error(r(452));
                return l;
            case "head":
                if (((l = t.head), !l)) throw Error(r(453));
                return l;
            case "body":
                if (((l = t.body), !l)) throw Error(r(454));
                return l;
            default:
                throw Error(r(451));
        }
    }
    function ru(l) {
        for (var t = l.attributes; t.length; ) l.removeAttributeNode(t[0]);
        $n(l);
    }
    var ot = new Map(),
        Y1 = new Set();
    function On(l) {
        return typeof l.getRootNode == "function" ? l.getRootNode() : l.nodeType === 9 ? l : l.ownerDocument;
    }
    var Zt = _.d;
    _.d = { f: Md, r: Nd, D: _d, C: Dd, L: jd, m: Ud, X: Hd, S: Rd, M: Bd };
    function Md() {
        var l = Zt.f(),
            t = gn();
        return l || t;
    }
    function Nd(l) {
        var t = Ga(l);
        t !== null && t.tag === 5 && t.type === "form" ? us(t) : Zt.r(l);
    }
    var Se = typeof document > "u" ? null : document;
    function G1(l, t, a) {
        var e = Se;
        if (e && typeof t == "string" && t) {
            var u = ut(t);
            (u = 'link[rel="' + l + '"][href="' + u + '"]'),
                typeof a == "string" && (u += '[crossorigin="' + a + '"]'),
                Y1.has(u) ||
                    (Y1.add(u),
                    (l = { rel: l, crossOrigin: a, href: t }),
                    e.querySelector(u) === null &&
                        ((t = e.createElement("link")), Ml(t, "link", l), Tl(t), e.head.appendChild(t)));
        }
    }
    function _d(l) {
        Zt.D(l), G1("dns-prefetch", l, null);
    }
    function Dd(l, t) {
        Zt.C(l, t), G1("preconnect", l, t);
    }
    function jd(l, t, a) {
        Zt.L(l, t, a);
        var e = Se;
        if (e && l && t) {
            var u = 'link[rel="preload"][as="' + ut(t) + '"]';
            t === "image" && a && a.imageSrcSet
                ? ((u += '[imagesrcset="' + ut(a.imageSrcSet) + '"]'),
                  typeof a.imageSizes == "string" && (u += '[imagesizes="' + ut(a.imageSizes) + '"]'))
                : (u += '[href="' + ut(l) + '"]');
            var n = u;
            switch (t) {
                case "style":
                    n = xe(l);
                    break;
                case "script":
                    n = Te(l);
            }
            ot.has(n) ||
                ((l = B({ rel: "preload", href: t === "image" && a && a.imageSrcSet ? void 0 : l, as: t }, a)),
                ot.set(n, l),
                e.querySelector(u) !== null ||
                    (t === "style" && e.querySelector(ou(n))) ||
                    (t === "script" && e.querySelector(du(n))) ||
                    ((t = e.createElement("link")), Ml(t, "link", l), Tl(t), e.head.appendChild(t)));
        }
    }
    function Ud(l, t) {
        Zt.m(l, t);
        var a = Se;
        if (a && l) {
            var e = t && typeof t.as == "string" ? t.as : "script",
                u = 'link[rel="modulepreload"][as="' + ut(e) + '"][href="' + ut(l) + '"]',
                n = u;
            switch (e) {
                case "audioworklet":
                case "paintworklet":
                case "serviceworker":
                case "sharedworker":
                case "worker":
                case "script":
                    n = Te(l);
            }
            if (
                !ot.has(n) &&
                ((l = B({ rel: "modulepreload", href: l }, t)), ot.set(n, l), a.querySelector(u) === null)
            ) {
                switch (e) {
                    case "audioworklet":
                    case "paintworklet":
                    case "serviceworker":
                    case "sharedworker":
                    case "worker":
                    case "script":
                        if (a.querySelector(du(n))) return;
                }
                (e = a.createElement("link")), Ml(e, "link", l), Tl(e), a.head.appendChild(e);
            }
        }
    }
    function Rd(l, t, a) {
        Zt.S(l, t, a);
        var e = Se;
        if (e && l) {
            var u = Xa(e).hoistableStyles,
                n = xe(l);
            t = t || "default";
            var c = u.get(n);
            if (!c) {
                var f = { loading: 0, preload: null };
                if ((c = e.querySelector(ou(n)))) f.loading = 5;
                else {
                    (l = B({ rel: "stylesheet", href: l, "data-precedence": t }, a)), (a = ot.get(n)) && Wf(l, a);
                    var i = (c = e.createElement("link"));
                    Tl(i),
                        Ml(i, "link", l),
                        (i._p = new Promise(function (y, T) {
                            (i.onload = y), (i.onerror = T);
                        })),
                        i.addEventListener("load", function () {
                            f.loading |= 1;
                        }),
                        i.addEventListener("error", function () {
                            f.loading |= 2;
                        }),
                        (f.loading |= 4),
                        Mn(c, t, e);
                }
                (c = { type: "stylesheet", instance: c, count: 1, state: f }), u.set(n, c);
            }
        }
    }
    function Hd(l, t) {
        Zt.X(l, t);
        var a = Se;
        if (a && l) {
            var e = Xa(a).hoistableScripts,
                u = Te(l),
                n = e.get(u);
            n ||
                ((n = a.querySelector(du(u))),
                n ||
                    ((l = B({ src: l, async: !0 }, t)),
                    (t = ot.get(u)) && $f(l, t),
                    (n = a.createElement("script")),
                    Tl(n),
                    Ml(n, "link", l),
                    a.head.appendChild(n)),
                (n = { type: "script", instance: n, count: 1, state: null }),
                e.set(u, n));
        }
    }
    function Bd(l, t) {
        Zt.M(l, t);
        var a = Se;
        if (a && l) {
            var e = Xa(a).hoistableScripts,
                u = Te(l),
                n = e.get(u);
            n ||
                ((n = a.querySelector(du(u))),
                n ||
                    ((l = B({ src: l, async: !0, type: "module" }, t)),
                    (t = ot.get(u)) && $f(l, t),
                    (n = a.createElement("script")),
                    Tl(n),
                    Ml(n, "link", l),
                    a.head.appendChild(n)),
                (n = { type: "script", instance: n, count: 1, state: null }),
                e.set(u, n));
        }
    }
    function X1(l, t, a, e) {
        var u = (u = Q.current) ? On(u) : null;
        if (!u) throw Error(r(446));
        switch (l) {
            case "meta":
            case "title":
                return null;
            case "style":
                return typeof a.precedence == "string" && typeof a.href == "string"
                    ? ((t = xe(a.href)),
                      (a = Xa(u).hoistableStyles),
                      (e = a.get(t)),
                      e || ((e = { type: "style", instance: null, count: 0, state: null }), a.set(t, e)),
                      e)
                    : { type: "void", instance: null, count: 0, state: null };
            case "link":
                if (a.rel === "stylesheet" && typeof a.href == "string" && typeof a.precedence == "string") {
                    l = xe(a.href);
                    var n = Xa(u).hoistableStyles,
                        c = n.get(l);
                    if (
                        (c ||
                            ((u = u.ownerDocument || u),
                            (c = {
                                type: "stylesheet",
                                instance: null,
                                count: 0,
                                state: { loading: 0, preload: null },
                            }),
                            n.set(l, c),
                            (n = u.querySelector(ou(l))) && !n._p && ((c.instance = n), (c.state.loading = 5)),
                            ot.has(l) ||
                                ((a = {
                                    rel: "preload",
                                    as: "style",
                                    href: a.href,
                                    crossOrigin: a.crossOrigin,
                                    integrity: a.integrity,
                                    media: a.media,
                                    hrefLang: a.hrefLang,
                                    referrerPolicy: a.referrerPolicy,
                                }),
                                ot.set(l, a),
                                n || Cd(u, l, a, c.state))),
                        t && e === null)
                    )
                        throw Error(r(528, ""));
                    return c;
                }
                if (t && e !== null) throw Error(r(529, ""));
                return null;
            case "script":
                return (
                    (t = a.async),
                    (a = a.src),
                    typeof a == "string" && t && typeof t != "function" && typeof t != "symbol"
                        ? ((t = Te(a)),
                          (a = Xa(u).hoistableScripts),
                          (e = a.get(t)),
                          e || ((e = { type: "script", instance: null, count: 0, state: null }), a.set(t, e)),
                          e)
                        : { type: "void", instance: null, count: 0, state: null }
                );
            default:
                throw Error(r(444, l));
        }
    }
    function xe(l) {
        return 'href="' + ut(l) + '"';
    }
    function ou(l) {
        return 'link[rel="stylesheet"][' + l + "]";
    }
    function Q1(l) {
        return B({}, l, { "data-precedence": l.precedence, precedence: null });
    }
    function Cd(l, t, a, e) {
        l.querySelector('link[rel="preload"][as="style"][' + t + "]")
            ? (e.loading = 1)
            : ((t = l.createElement("link")),
              (e.preload = t),
              t.addEventListener("load", function () {
                  return (e.loading |= 1);
              }),
              t.addEventListener("error", function () {
                  return (e.loading |= 2);
              }),
              Ml(t, "link", a),
              Tl(t),
              l.head.appendChild(t));
    }
    function Te(l) {
        return '[src="' + ut(l) + '"]';
    }
    function du(l) {
        return "script[async]" + l;
    }
    function Z1(l, t, a) {
        if ((t.count++, t.instance === null))
            switch (t.type) {
                case "style":
                    var e = l.querySelector('style[data-href~="' + ut(a.href) + '"]');
                    if (e) return (t.instance = e), Tl(e), e;
                    var u = B({}, a, {
                        "data-href": a.href,
                        "data-precedence": a.precedence,
                        href: null,
                        precedence: null,
                    });
                    return (
                        (e = (l.ownerDocument || l).createElement("style")),
                        Tl(e),
                        Ml(e, "style", u),
                        Mn(e, a.precedence, l),
                        (t.instance = e)
                    );
                case "stylesheet":
                    u = xe(a.href);
                    var n = l.querySelector(ou(u));
                    if (n) return (t.state.loading |= 4), (t.instance = n), Tl(n), n;
                    (e = Q1(a)), (u = ot.get(u)) && Wf(e, u), (n = (l.ownerDocument || l).createElement("link")), Tl(n);
                    var c = n;
                    return (
                        (c._p = new Promise(function (f, i) {
                            (c.onload = f), (c.onerror = i);
                        })),
                        Ml(n, "link", e),
                        (t.state.loading |= 4),
                        Mn(n, a.precedence, l),
                        (t.instance = n)
                    );
                case "script":
                    return (
                        (n = Te(a.src)),
                        (u = l.querySelector(du(n)))
                            ? ((t.instance = u), Tl(u), u)
                            : ((e = a),
                              (u = ot.get(n)) && ((e = B({}, a)), $f(e, u)),
                              (l = l.ownerDocument || l),
                              (u = l.createElement("script")),
                              Tl(u),
                              Ml(u, "link", e),
                              l.head.appendChild(u),
                              (t.instance = u))
                    );
                case "void":
                    return null;
                default:
                    throw Error(r(443, t.type));
            }
        else
            t.type === "stylesheet" &&
                (t.state.loading & 4) === 0 &&
                ((e = t.instance), (t.state.loading |= 4), Mn(e, a.precedence, l));
        return t.instance;
    }
    function Mn(l, t, a) {
        for (
            var e = a.querySelectorAll('link[rel="stylesheet"][data-precedence],style[data-precedence]'),
                u = e.length ? e[e.length - 1] : null,
                n = u,
                c = 0;
            c < e.length;
            c++
        ) {
            var f = e[c];
            if (f.dataset.precedence === t) n = f;
            else if (n !== u) break;
        }
        n
            ? n.parentNode.insertBefore(l, n.nextSibling)
            : ((t = a.nodeType === 9 ? a.head : a), t.insertBefore(l, t.firstChild));
    }
    function Wf(l, t) {
        l.crossOrigin == null && (l.crossOrigin = t.crossOrigin),
            l.referrerPolicy == null && (l.referrerPolicy = t.referrerPolicy),
            l.title == null && (l.title = t.title);
    }
    function $f(l, t) {
        l.crossOrigin == null && (l.crossOrigin = t.crossOrigin),
            l.referrerPolicy == null && (l.referrerPolicy = t.referrerPolicy),
            l.integrity == null && (l.integrity = t.integrity);
    }
    var Nn = null;
    function V1(l, t, a) {
        if (Nn === null) {
            var e = new Map(),
                u = (Nn = new Map());
            u.set(a, e);
        } else (u = Nn), (e = u.get(a)), e || ((e = new Map()), u.set(a, e));
        if (e.has(l)) return e;
        for (e.set(l, null), a = a.getElementsByTagName(l), u = 0; u < a.length; u++) {
            var n = a[u];
            if (
                !(n[ze] || n[jl] || (l === "link" && n.getAttribute("rel") === "stylesheet")) &&
                n.namespaceURI !== "http://www.w3.org/2000/svg"
            ) {
                var c = n.getAttribute(t) || "";
                c = l + c;
                var f = e.get(c);
                f ? f.push(n) : e.set(c, [n]);
            }
        }
        return e;
    }
    function L1(l, t, a) {
        (l = l.ownerDocument || l), l.head.insertBefore(a, t === "title" ? l.querySelector("head > title") : null);
    }
    function qd(l, t, a) {
        if (a === 1 || t.itemProp != null) return !1;
        switch (l) {
            case "meta":
            case "title":
                return !0;
            case "style":
                if (typeof t.precedence != "string" || typeof t.href != "string" || t.href === "") break;
                return !0;
            case "link":
                if (typeof t.rel != "string" || typeof t.href != "string" || t.href === "" || t.onLoad || t.onError)
                    break;
                switch (t.rel) {
                    case "stylesheet":
                        return (l = t.disabled), typeof t.precedence == "string" && l == null;
                    default:
                        return !0;
                }
            case "script":
                if (
                    t.async &&
                    typeof t.async != "function" &&
                    typeof t.async != "symbol" &&
                    !t.onLoad &&
                    !t.onError &&
                    t.src &&
                    typeof t.src == "string"
                )
                    return !0;
        }
        return !1;
    }
    function w1(l) {
        return !(l.type === "stylesheet" && (l.state.loading & 3) === 0);
    }
    var hu = null;
    function Yd() {}
    function Gd(l, t, a) {
        if (hu === null) throw Error(r(475));
        var e = hu;
        if (
            t.type === "stylesheet" &&
            (typeof a.media != "string" || matchMedia(a.media).matches !== !1) &&
            (t.state.loading & 4) === 0
        ) {
            if (t.instance === null) {
                var u = xe(a.href),
                    n = l.querySelector(ou(u));
                if (n) {
                    (l = n._p),
                        l !== null &&
                            typeof l == "object" &&
                            typeof l.then == "function" &&
                            (e.count++, (e = _n.bind(e)), l.then(e, e)),
                        (t.state.loading |= 4),
                        (t.instance = n),
                        Tl(n);
                    return;
                }
                (n = l.ownerDocument || l),
                    (a = Q1(a)),
                    (u = ot.get(u)) && Wf(a, u),
                    (n = n.createElement("link")),
                    Tl(n);
                var c = n;
                (c._p = new Promise(function (f, i) {
                    (c.onload = f), (c.onerror = i);
                })),
                    Ml(n, "link", a),
                    (t.instance = n);
            }
            e.stylesheets === null && (e.stylesheets = new Map()),
                e.stylesheets.set(t, l),
                (l = t.state.preload) &&
                    (t.state.loading & 3) === 0 &&
                    (e.count++, (t = _n.bind(e)), l.addEventListener("load", t), l.addEventListener("error", t));
        }
    }
    function Xd() {
        if (hu === null) throw Error(r(475));
        var l = hu;
        return (
            l.stylesheets && l.count === 0 && kf(l, l.stylesheets),
            0 < l.count
                ? function (t) {
                      var a = setTimeout(function () {
                          if ((l.stylesheets && kf(l, l.stylesheets), l.unsuspend)) {
                              var e = l.unsuspend;
                              (l.unsuspend = null), e();
                          }
                      }, 6e4);
                      return (
                          (l.unsuspend = t),
                          function () {
                              (l.unsuspend = null), clearTimeout(a);
                          }
                      );
                  }
                : null
        );
    }
    function _n() {
        if ((this.count--, this.count === 0)) {
            if (this.stylesheets) kf(this, this.stylesheets);
            else if (this.unsuspend) {
                var l = this.unsuspend;
                (this.unsuspend = null), l();
            }
        }
    }
    var Dn = null;
    function kf(l, t) {
        (l.stylesheets = null),
            l.unsuspend !== null && (l.count++, (Dn = new Map()), t.forEach(Qd, l), (Dn = null), _n.call(l));
    }
    function Qd(l, t) {
        if (!(t.state.loading & 4)) {
            var a = Dn.get(l);
            if (a) var e = a.get(null);
            else {
                (a = new Map()), Dn.set(l, a);
                for (
                    var u = l.querySelectorAll("link[data-precedence],style[data-precedence]"), n = 0;
                    n < u.length;
                    n++
                ) {
                    var c = u[n];
                    (c.nodeName === "LINK" || c.getAttribute("media") !== "not all") &&
                        (a.set(c.dataset.precedence, c), (e = c));
                }
                e && a.set(null, e);
            }
            (u = t.instance),
                (c = u.getAttribute("data-precedence")),
                (n = a.get(c) || e),
                n === e && a.set(null, u),
                a.set(c, u),
                this.count++,
                (e = _n.bind(this)),
                u.addEventListener("load", e),
                u.addEventListener("error", e),
                n
                    ? n.parentNode.insertBefore(u, n.nextSibling)
                    : ((l = l.nodeType === 9 ? l.head : l), l.insertBefore(u, l.firstChild)),
                (t.state.loading |= 4);
        }
    }
    var vu = { $$typeof: Nl, Provider: null, Consumer: null, _currentValue: G, _currentValue2: G, _threadCount: 0 };
    function Zd(l, t, a, e, u, n, c, f) {
        (this.tag = 1),
            (this.containerInfo = l),
            (this.pingCache = this.current = this.pendingChildren = null),
            (this.timeoutHandle = -1),
            (this.callbackNode = this.next = this.pendingContext = this.context = this.cancelPendingCommit = null),
            (this.callbackPriority = 0),
            (this.expirationTimes = Kn(-1)),
            (this.entangledLanes =
                this.shellSuspendCounter =
                this.errorRecoveryDisabledLanes =
                this.expiredLanes =
                this.warmLanes =
                this.pingedLanes =
                this.suspendedLanes =
                this.pendingLanes =
                    0),
            (this.entanglements = Kn(0)),
            (this.hiddenUpdates = Kn(null)),
            (this.identifierPrefix = e),
            (this.onUncaughtError = u),
            (this.onCaughtError = n),
            (this.onRecoverableError = c),
            (this.pooledCache = null),
            (this.pooledCacheLanes = 0),
            (this.formState = f),
            (this.incompleteTransitions = new Map());
    }
    function K1(l, t, a, e, u, n, c, f, i, y, T, A) {
        return (
            (l = new Zd(l, t, a, c, f, i, y, A)),
            (t = 1),
            n === !0 && (t |= 24),
            (n = kl(3, null, null, t)),
            (l.current = n),
            (n.stateNode = l),
            (t = jc()),
            t.refCount++,
            (l.pooledCache = t),
            t.refCount++,
            (n.memoizedState = { element: e, isDehydrated: a, cache: t }),
            Bc(n),
            l
        );
    }
    function J1(l) {
        return l ? ((l = Pa), l) : Pa;
    }
    function F1(l, t, a, e, u, n) {
        (u = J1(u)),
            e.context === null ? (e.context = u) : (e.pendingContext = u),
            (e = Wt(t)),
            (e.payload = { element: a }),
            (n = n === void 0 ? null : n),
            n !== null && (e.callback = n),
            (a = $t(l, e, t)),
            a !== null && (at(a, l, t), Le(a, l, t));
    }
    function W1(l, t) {
        if (((l = l.memoizedState), l !== null && l.dehydrated !== null)) {
            var a = l.retryLane;
            l.retryLane = a !== 0 && a < t ? a : t;
        }
    }
    function Pf(l, t) {
        W1(l, t), (l = l.alternate) && W1(l, t);
    }
    function $1(l) {
        if (l.tag === 13) {
            var t = ka(l, 67108864);
            t !== null && at(t, l, 67108864), Pf(l, 67108864);
        }
    }
    var jn = !0;
    function Vd(l, t, a, e) {
        var u = E.T;
        E.T = null;
        var n = _.p;
        try {
            (_.p = 2), If(l, t, a, e);
        } finally {
            (_.p = n), (E.T = u);
        }
    }
    function Ld(l, t, a, e) {
        var u = E.T;
        E.T = null;
        var n = _.p;
        try {
            (_.p = 8), If(l, t, a, e);
        } finally {
            (_.p = n), (E.T = u);
        }
    }
    function If(l, t, a, e) {
        if (jn) {
            var u = li(e);
            if (u === null) Xf(l, t, e, Un, a), P1(l, e);
            else if (Kd(u, l, t, a, e)) e.stopPropagation();
            else if ((P1(l, e), t & 4 && -1 < wd.indexOf(l))) {
                for (; u !== null; ) {
                    var n = Ga(u);
                    if (n !== null)
                        switch (n.tag) {
                            case 3:
                                if (((n = n.stateNode), n.current.memoizedState.isDehydrated)) {
                                    var c = ga(n.pendingLanes);
                                    if (c !== 0) {
                                        var f = n;
                                        for (f.pendingLanes |= 2, f.entangledLanes |= 2; c; ) {
                                            var i = 1 << (31 - Wl(c));
                                            (f.entanglements[1] |= i), (c &= ~i);
                                        }
                                        zt(n), (ll & 6) === 0 && ((yn = xt() + 500), fu(0));
                                    }
                                }
                                break;
                            case 13:
                                (f = ka(n, 2)), f !== null && at(f, n, 2), gn(), Pf(n, 2);
                        }
                    if (((n = li(e)), n === null && Xf(l, t, e, Un, a), n === u)) break;
                    u = n;
                }
                u !== null && e.stopPropagation();
            } else Xf(l, t, e, null, a);
        }
    }
    function li(l) {
        return (l = uc(l)), ti(l);
    }
    var Un = null;
    function ti(l) {
        if (((Un = null), (l = Ya(l)), l !== null)) {
            var t = H(l);
            if (t === null) l = null;
            else {
                var a = t.tag;
                if (a === 13) {
                    if (((l = V(t)), l !== null)) return l;
                    l = null;
                } else if (a === 3) {
                    if (t.stateNode.current.memoizedState.isDehydrated)
                        return t.tag === 3 ? t.stateNode.containerInfo : null;
                    l = null;
                } else t !== l && (l = null);
            }
        }
        return (Un = l), null;
    }
    function k1(l) {
        switch (l) {
            case "beforetoggle":
            case "cancel":
            case "click":
            case "close":
            case "contextmenu":
            case "copy":
            case "cut":
            case "auxclick":
            case "dblclick":
            case "dragend":
            case "dragstart":
            case "drop":
            case "focusin":
            case "focusout":
            case "input":
            case "invalid":
            case "keydown":
            case "keypress":
            case "keyup":
            case "mousedown":
            case "mouseup":
            case "paste":
            case "pause":
            case "play":
            case "pointercancel":
            case "pointerdown":
            case "pointerup":
            case "ratechange":
            case "reset":
            case "resize":
            case "seeked":
            case "submit":
            case "toggle":
            case "touchcancel":
            case "touchend":
            case "touchstart":
            case "volumechange":
            case "change":
            case "selectionchange":
            case "textInput":
            case "compositionstart":
            case "compositionend":
            case "compositionupdate":
            case "beforeblur":
            case "afterblur":
            case "beforeinput":
            case "blur":
            case "fullscreenchange":
            case "focus":
            case "hashchange":
            case "popstate":
            case "select":
            case "selectstart":
                return 2;
            case "drag":
            case "dragenter":
            case "dragexit":
            case "dragleave":
            case "dragover":
            case "mousemove":
            case "mouseout":
            case "mouseover":
            case "pointermove":
            case "pointerout":
            case "pointerover":
            case "scroll":
            case "touchmove":
            case "wheel":
            case "mouseenter":
            case "mouseleave":
            case "pointerenter":
            case "pointerleave":
                return 8;
            case "message":
                switch (_r()) {
                    case oi:
                        return 2;
                    case di:
                        return 8;
                    case pu:
                    case Dr:
                        return 32;
                    case hi:
                        return 268435456;
                    default:
                        return 32;
                }
            default:
                return 32;
        }
    }
    var ai = !1,
        sa = null,
        ra = null,
        oa = null,
        yu = new Map(),
        mu = new Map(),
        da = [],
        wd =
            "mousedown mouseup touchcancel touchend touchstart auxclick dblclick pointercancel pointerdown pointerup dragend dragstart drop compositionend compositionstart keydown keypress keyup input textInput copy cut paste click change contextmenu reset".split(
                " "
            );
    function P1(l, t) {
        switch (l) {
            case "focusin":
            case "focusout":
                sa = null;
                break;
            case "dragenter":
            case "dragleave":
                ra = null;
                break;
            case "mouseover":
            case "mouseout":
                oa = null;
                break;
            case "pointerover":
            case "pointerout":
                yu.delete(t.pointerId);
                break;
            case "gotpointercapture":
            case "lostpointercapture":
                mu.delete(t.pointerId);
        }
    }
    function gu(l, t, a, e, u, n) {
        return l === null || l.nativeEvent !== n
            ? ((l = { blockedOn: t, domEventName: a, eventSystemFlags: e, nativeEvent: n, targetContainers: [u] }),
              t !== null && ((t = Ga(t)), t !== null && $1(t)),
              l)
            : ((l.eventSystemFlags |= e), (t = l.targetContainers), u !== null && t.indexOf(u) === -1 && t.push(u), l);
    }
    function Kd(l, t, a, e, u) {
        switch (t) {
            case "focusin":
                return (sa = gu(sa, l, t, a, e, u)), !0;
            case "dragenter":
                return (ra = gu(ra, l, t, a, e, u)), !0;
            case "mouseover":
                return (oa = gu(oa, l, t, a, e, u)), !0;
            case "pointerover":
                var n = u.pointerId;
                return yu.set(n, gu(yu.get(n) || null, l, t, a, e, u)), !0;
            case "gotpointercapture":
                return (n = u.pointerId), mu.set(n, gu(mu.get(n) || null, l, t, a, e, u)), !0;
        }
        return !1;
    }
    function I1(l) {
        var t = Ya(l.target);
        if (t !== null) {
            var a = H(t);
            if (a !== null) {
                if (((t = a.tag), t === 13)) {
                    if (((t = V(a)), t !== null)) {
                        (l.blockedOn = t),
                            Yr(l.priority, function () {
                                if (a.tag === 13) {
                                    var e = tt();
                                    e = Jn(e);
                                    var u = ka(a, e);
                                    u !== null && at(u, a, e), Pf(a, e);
                                }
                            });
                        return;
                    }
                } else if (t === 3 && a.stateNode.current.memoizedState.isDehydrated) {
                    l.blockedOn = a.tag === 3 ? a.stateNode.containerInfo : null;
                    return;
                }
            }
        }
        l.blockedOn = null;
    }
    function Rn(l) {
        if (l.blockedOn !== null) return !1;
        for (var t = l.targetContainers; 0 < t.length; ) {
            var a = li(l.nativeEvent);
            if (a === null) {
                a = l.nativeEvent;
                var e = new a.constructor(a.type, a);
                (ec = e), a.target.dispatchEvent(e), (ec = null);
            } else return (t = Ga(a)), t !== null && $1(t), (l.blockedOn = a), !1;
            t.shift();
        }
        return !0;
    }
    function lr(l, t, a) {
        Rn(l) && a.delete(t);
    }
    function Jd() {
        (ai = !1),
            sa !== null && Rn(sa) && (sa = null),
            ra !== null && Rn(ra) && (ra = null),
            oa !== null && Rn(oa) && (oa = null),
            yu.forEach(lr),
            mu.forEach(lr);
    }
    function Hn(l, t) {
        l.blockedOn === t &&
            ((l.blockedOn = null), ai || ((ai = !0), s.unstable_scheduleCallback(s.unstable_NormalPriority, Jd)));
    }
    var Bn = null;
    function tr(l) {
        Bn !== l &&
            ((Bn = l),
            s.unstable_scheduleCallback(s.unstable_NormalPriority, function () {
                Bn === l && (Bn = null);
                for (var t = 0; t < l.length; t += 3) {
                    var a = l[t],
                        e = l[t + 1],
                        u = l[t + 2];
                    if (typeof e != "function") {
                        if (ti(e || a) === null) continue;
                        break;
                    }
                    var n = Ga(a);
                    n !== null &&
                        (l.splice(t, 3), (t -= 3), lf(n, { pending: !0, data: u, method: a.method, action: e }, e, u));
                }
            }));
    }
    function bu(l) {
        function t(i) {
            return Hn(i, l);
        }
        sa !== null && Hn(sa, l), ra !== null && Hn(ra, l), oa !== null && Hn(oa, l), yu.forEach(t), mu.forEach(t);
        for (var a = 0; a < da.length; a++) {
            var e = da[a];
            e.blockedOn === l && (e.blockedOn = null);
        }
        for (; 0 < da.length && ((a = da[0]), a.blockedOn === null); ) I1(a), a.blockedOn === null && da.shift();
        if (((a = (l.ownerDocument || l).$$reactFormReplay), a != null))
            for (e = 0; e < a.length; e += 3) {
                var u = a[e],
                    n = a[e + 1],
                    c = u[Gl] || null;
                if (typeof n == "function") c || tr(a);
                else if (c) {
                    var f = null;
                    if (n && n.hasAttribute("formAction")) {
                        if (((u = n), (c = n[Gl] || null))) f = c.formAction;
                        else if (ti(u) !== null) continue;
                    } else f = c.action;
                    typeof f == "function" ? (a[e + 1] = f) : (a.splice(e, 3), (e -= 3)), tr(a);
                }
            }
    }
    function ei(l) {
        this._internalRoot = l;
    }
    (Cn.prototype.render = ei.prototype.render =
        function (l) {
            var t = this._internalRoot;
            if (t === null) throw Error(r(409));
            var a = t.current,
                e = tt();
            F1(a, e, l, t, null, null);
        }),
        (Cn.prototype.unmount = ei.prototype.unmount =
            function () {
                var l = this._internalRoot;
                if (l !== null) {
                    this._internalRoot = null;
                    var t = l.containerInfo;
                    F1(l.current, 2, null, l, null, null), gn(), (t[qa] = null);
                }
            });
    function Cn(l) {
        this._internalRoot = l;
    }
    Cn.prototype.unstable_scheduleHydration = function (l) {
        if (l) {
            var t = bi();
            l = { blockedOn: null, target: l, priority: t };
            for (var a = 0; a < da.length && t !== 0 && t < da[a].priority; a++);
            da.splice(a, 0, l), a === 0 && I1(l);
        }
    };
    var ar = S.version;
    if (ar !== "19.1.0") throw Error(r(527, ar, "19.1.0"));
    _.findDOMNode = function (l) {
        var t = l._reactInternals;
        if (t === void 0)
            throw typeof l.render == "function" ? Error(r(188)) : ((l = Object.keys(l).join(",")), Error(r(268, l)));
        return (l = D(t)), (l = l !== null ? z(l) : null), (l = l === null ? null : l.stateNode), l;
    };
    var Fd = {
        bundleType: 0,
        version: "19.1.0",
        rendererPackageName: "react-dom",
        currentDispatcherRef: E,
        reconcilerVersion: "19.1.0",
    };
    if (typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ < "u") {
        var qn = __REACT_DEVTOOLS_GLOBAL_HOOK__;
        if (!qn.isDisabled && qn.supportsFiber)
            try {
                (Ee = qn.inject(Fd)), (Fl = qn);
            } catch {}
    }
    return (
        (xu.createRoot = function (l, t) {
            if (!M(l)) throw Error(r(299));
            var a = !1,
                e = "",
                u = bs,
                n = Ss,
                c = xs,
                f = null;
            return (
                t != null &&
                    (t.unstable_strictMode === !0 && (a = !0),
                    t.identifierPrefix !== void 0 && (e = t.identifierPrefix),
                    t.onUncaughtError !== void 0 && (u = t.onUncaughtError),
                    t.onCaughtError !== void 0 && (n = t.onCaughtError),
                    t.onRecoverableError !== void 0 && (c = t.onRecoverableError),
                    t.unstable_transitionCallbacks !== void 0 && (f = t.unstable_transitionCallbacks)),
                (t = K1(l, 1, !1, null, null, a, e, u, n, c, f, null)),
                (l[qa] = t.current),
                Gf(l),
                new ei(t)
            );
        }),
        (xu.hydrateRoot = function (l, t, a) {
            if (!M(l)) throw Error(r(299));
            var e = !1,
                u = "",
                n = bs,
                c = Ss,
                f = xs,
                i = null,
                y = null;
            return (
                a != null &&
                    (a.unstable_strictMode === !0 && (e = !0),
                    a.identifierPrefix !== void 0 && (u = a.identifierPrefix),
                    a.onUncaughtError !== void 0 && (n = a.onUncaughtError),
                    a.onCaughtError !== void 0 && (c = a.onCaughtError),
                    a.onRecoverableError !== void 0 && (f = a.onRecoverableError),
                    a.unstable_transitionCallbacks !== void 0 && (i = a.unstable_transitionCallbacks),
                    a.formState !== void 0 && (y = a.formState)),
                (t = K1(l, 1, !0, t, a ?? null, e, u, n, c, f, i, y)),
                (t.context = J1(null)),
                (a = t.current),
                (e = tt()),
                (e = Jn(e)),
                (u = Wt(e)),
                (u.callback = null),
                $t(a, u, e),
                (a = e),
                (t.current.lanes = a),
                Ae(t, a),
                zt(t),
                (l[qa] = t.current),
                Gf(l),
                new Cn(t)
            );
        }),
        (xu.version = "19.1.0"),
        xu
    );
}
var dr;
function nh() {
    if (dr) return ci.exports;
    dr = 1;
    function s() {
        if (
            !(
                typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ > "u" ||
                typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE != "function"
            )
        )
            try {
                __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(s);
            } catch (S) {
                console.error(S);
            }
    }
    return s(), (ci.exports = uh()), ci.exports;
}
var ch = nh();
const fh = { tables: { style: {}, lang: {}, personalData: {}, links: {}, strings: {} } },
    ih = {
        setTableData: (s, { tableName: S, data: x }) => ({ ...s, tables: { ...s.tables, [S]: x } }),
        updateTableRow: (s, { tableName: S, index: x, updatedRow: r }) => ({
            ...s,
            tables: { ...s.tables, [S]: s.tables[S].map((M, H) => (H === x ? r : M)) },
        }),
        setString: (s, { value: S }) => ({ ...s, someString: S }),
        setBoolean: (s, { value: S }) => ({ ...s, someBoolean: S }),
    },
    sh = (s, S) => {
        const x = ih[S.type];
        return x ? x(s, S.payload) : s;
    },
    gr = dt.createContext(),
    rh = ({ children: s }) => {
        const [S, x] = dt.useReducer(sh, fh),
            r = (W, D) => x({ type: "setTableData", payload: { tableName: W, data: D } }),
            M = (W, D, z) => x({ type: "updateTableRow", payload: { tableName: W, index: D, updatedRow: z } }),
            H = (W) => x({ type: "setString", payload: { value: W } }),
            V = (W) => x({ type: "setBoolean", payload: { value: W } });
        return b.jsx(gr.Provider, {
            value: { state: S, setTableData: r, updateTableRow: M, setString: H, setBoolean: V },
            children: s,
        });
    },
    ht = () => dt.useContext(gr),
    oh = () => {
        const { state: s } = ht(),
            x = {
                background: `radial-gradient(circle, ${s?.tables?.style?.gradientColor ?? "rgba(0,0,0,0)"} 0%, rgba(0, 0, 0, 0) 60%)`,
            };
        return b.jsxs("div", {
            className: "h-[100%] w-[100%] absolute overflow-hidden bg-cover",
            children: [
                b.jsx("div", { className: "w-[100%] h-[100%] bg-[#0b0d14e1]" }),
                b.jsx("div", { style: x, className: "  h-[250vh] w-[200vh] absolute bottom-[5%] right-[60%] " }),
                b.jsx("div", { style: x, className: " h-[200vh] w-[100%] absolute top-[30%] left-[60%] " }),
            ],
        });
    },
    dh = () => {
        const { state: s } = ht(),
            x = {
                background: `radial-gradient(circle, ${s?.tables?.style?.gradientColor ?? "rgba(0,0,0,0)"} 0%, rgba(0, 0, 0, 0) 60%)`,
            };
        return b.jsxs("div", {
            className: "h-[100%] w-[100%] absolute overflow-hidden bg-cover",
            children: [
                b.jsx("div", { className: "w-[100%] h-[100%] bg-side " }),
                b.jsx("div", { style: x, className: " h-[250vh] w-[200vh] absolute bottom-[5%] right-[60%] " }),
                b.jsx("div", { className: "bg-gradient2  h-[250vh] w-[200vh] absolute bottom-[-10%] right-[-60%] " }),
            ],
        });
    };
var br = { color: void 0, size: void 0, className: void 0, style: void 0, attr: void 0 },
    hr = Ba.createContext && Ba.createContext(br),
    hh = ["attr", "size", "title"];
function vh(s, S) {
    if (s == null) return {};
    var x = yh(s, S),
        r,
        M;
    if (Object.getOwnPropertySymbols) {
        var H = Object.getOwnPropertySymbols(s);
        for (M = 0; M < H.length; M++)
            (r = H[M]), !(S.indexOf(r) >= 0) && Object.prototype.propertyIsEnumerable.call(s, r) && (x[r] = s[r]);
    }
    return x;
}
function yh(s, S) {
    if (s == null) return {};
    var x = {};
    for (var r in s)
        if (Object.prototype.hasOwnProperty.call(s, r)) {
            if (S.indexOf(r) >= 0) continue;
            x[r] = s[r];
        }
    return x;
}
function Yn() {
    return (
        (Yn = Object.assign
            ? Object.assign.bind()
            : function (s) {
                  for (var S = 1; S < arguments.length; S++) {
                      var x = arguments[S];
                      for (var r in x) Object.prototype.hasOwnProperty.call(x, r) && (s[r] = x[r]);
                  }
                  return s;
              }),
        Yn.apply(this, arguments)
    );
}
function vr(s, S) {
    var x = Object.keys(s);
    if (Object.getOwnPropertySymbols) {
        var r = Object.getOwnPropertySymbols(s);
        S &&
            (r = r.filter(function (M) {
                return Object.getOwnPropertyDescriptor(s, M).enumerable;
            })),
            x.push.apply(x, r);
    }
    return x;
}
function Gn(s) {
    for (var S = 1; S < arguments.length; S++) {
        var x = arguments[S] != null ? arguments[S] : {};
        S % 2
            ? vr(Object(x), !0).forEach(function (r) {
                  mh(s, r, x[r]);
              })
            : Object.getOwnPropertyDescriptors
              ? Object.defineProperties(s, Object.getOwnPropertyDescriptors(x))
              : vr(Object(x)).forEach(function (r) {
                    Object.defineProperty(s, r, Object.getOwnPropertyDescriptor(x, r));
                });
    }
    return s;
}
function mh(s, S, x) {
    return (
        (S = gh(S)),
        S in s ? Object.defineProperty(s, S, { value: x, enumerable: !0, configurable: !0, writable: !0 }) : (s[S] = x),
        s
    );
}
function gh(s) {
    var S = bh(s, "string");
    return typeof S == "symbol" ? S : S + "";
}
function bh(s, S) {
    if (typeof s != "object" || !s) return s;
    var x = s[Symbol.toPrimitive];
    if (x !== void 0) {
        var r = x.call(s, S);
        if (typeof r != "object") return r;
        throw new TypeError("@@toPrimitive must return a primitive value.");
    }
    return (S === "string" ? String : Number)(s);
}
function Sr(s) {
    return s && s.map((S, x) => Ba.createElement(S.tag, Gn({ key: x }, S.attr), Sr(S.child)));
}
function ql(s) {
    return (S) => Ba.createElement(Sh, Yn({ attr: Gn({}, s.attr) }, S), Sr(s.child));
}
function Sh(s) {
    var S = (x) => {
        var { attr: r, size: M, title: H } = s,
            V = vh(s, hh),
            W = M || x.size || "1em",
            D;
        return (
            x.className && (D = x.className),
            s.className && (D = (D ? D + " " : "") + s.className),
            Ba.createElement(
                "svg",
                Yn({ stroke: "currentColor", fill: "currentColor", strokeWidth: "0" }, x.attr, r, V, {
                    className: D,
                    style: Gn(Gn({ color: s.color || x.color }, x.style), s.style),
                    height: W,
                    width: W,
                    xmlns: "http://www.w3.org/2000/svg",
                }),
                H && Ba.createElement("title", null, H),
                s.children
            )
        );
    };
    return hr !== void 0 ? Ba.createElement(hr.Consumer, null, (x) => S(x)) : S(br);
}
function xh(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M256 32C167.67 32 96 96.51 96 176c0 128 160 304 160 304s160-176 160-304c0-79.49-71.67-144-160-144zm0 224a64 64 0 1 1 64-64 64.07 64.07 0 0 1-64 64z",
                },
                child: [],
            },
        ],
    })(s);
}
function Th(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M256 48C141.13 48 48 141.13 48 256s93.13 208 208 208 208-93.13 208-208S370.87 48 256 48zm96 240h-96a16 16 0 0 1-16-16V128a16 16 0 0 1 32 0v128h80a16 16 0 0 1 0 32z",
                },
                child: [],
            },
        ],
    })(s);
}
const xr = () => {
        const { state: s } = ht(),
            { primaryColor: S = "#00b2ff" } = s?.tables?.style || {},
            { location: x = "Unknown Location" } = s?.tables?.strings || {};
        return b.jsxs("div", {
            className: "w-auto h-[100%] flex items-center gap-[2vh] ",
            children: [
                b.jsx("img", { className: "h-[7vh]", src: "./images/Img.png", alt: "logo" }),
                b.jsxs("div", {
                    className:
                        "w-auto h-[4vh] pl-[2vh] gap-[1vh] pr-[2vh] flex items-center justify-center border-[#FFFFFF0A] border-[0.1vh] rounded-[1vh] bg-[#FFFFFF14]",
                    children: [
                        b.jsx(xh, { style: { color: S }, className: "text-[2vh]" }),
                        b.jsx("p", {
                            className: "text-[1.4vh] text-[#ffffff65] font-[500] tracking-wide",
                            children: x,
                        }),
                    ],
                }),
            ],
        });
    },
    Tr = ({ reverse: s }) => {
        const { state: S } = ht(),
            x = S?.tables?.style?.primaryColor ?? "#ffffff",
            r = S?.tables?.lang ?? {};
        return b.jsxs("div", {
            className: `${s ? "flex-row-reverse" : ""} w-auto h-[100%] flex justify-start items-center gap-[1vh]`,
            children: [
                b.jsx("button", {
                    style: { borderColor: x, color: x },
                    className: "border-[0.2vh] w-[8vh] h-[4vh] font-[600] rounded-[1vh] cursor-pointer",
                    children: "ESC",
                }),
                b.jsxs("div", {
                    className: `${s ? "items-end" : ""} w-auto h-[4vh] flex flex-col justify-center `,
                    children: [
                        b.jsx("p", { className: "text-white text-[1.3vh] font-[700]", children: r.close }),
                        b.jsx("p", { className: "text-[#FFFFFFA6] text-[1.3vh] font-[400]", children: r.pauseMenu }),
                    ],
                }),
            ],
        });
    },
    Eh = ({ children: s, onClick: S, style: x }) =>
        b.jsx("div", {
            onClick: S,
            style: x,
            className:
                "cursor-pointer border-b-transparent w-auto h-[100%] flex justify-center items-center gap-[0.3vh] border-[0.3vh] border-transparent",
            children: s,
        }),
    Xn = ({ primaryColorBackground: s, primaryColor: S, icon: x, reverse: r, title: M, description: H }) => {
        const { state: V } = ht(),
            W = V?.tables?.lang ?? {},
            D = x;
        return b.jsxs("div", {
            className: "h-[5vh] w-[100%] flex gap-[1vh]",
            children: [
                b.jsx("div", {
                    style: { backgroundColor: s },
                    className: "rounded-[1vh] flex items-center justify-center h-[5vh] w-[5vh]",
                    children: b.jsx(D, { className: "text-[3.5vh]", style: { color: S } }),
                }),
                b.jsxs("div", {
                    className: `${r ? "flex-col-reverse" : "flex-col"} w-auto h-[100%] flex  leading-none gap-[0.5vh] justify-center`,
                    children: [
                        b.jsx("h1", {
                            className: `${r && M === W.map ? "text-[3vh]" : "text-[1.8vh]"} uppercase text-white font-[700]`,
                            children: M,
                        }),
                        b.jsx("p", { className: "text-[#ffffff65] text-[1.4vh] break-all uppercase", children: H }),
                    ],
                }),
            ],
        });
    };
function ph(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M144 136v107h179.9l-47.2-47.9c-5-5.1-5-13.3.1-18.4 5.1-5 13.3-5 18.4.1l69 70c2.4 2.5 3.7 5.8 3.7 9.1 0 1.7-.3 3.4-1 5-.6 1.5-1.6 2.9-2.7 4.1l-69 70c-5 5.1-13.3 5.2-18.4.1-5.1-5-5.2-13.3-.1-18.4l47.2-47.9H144v107c0 22 18 40 40 40h240c22 0 40-18 40-40V136c0-22-18-40-40-40H184c-22 0-40 18-40 40zM61 243c-7.2 0-13 5.8-13 13s5.8 13 13 13h83v-26H61z",
                },
                child: [],
            },
        ],
    })(s);
}
function Ah(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M463 192H315.9L271.2 58.6C269 52.1 262.9 48 256 48s-13 4.1-15.2 10.6L196.1 192H48c-8.8 0-16 7.2-16 16 0 .9.1 1.9.3 2.7.2 3.5 1.8 7.4 6.7 11.3l120.9 85.2-46.4 134.9c-2.3 6.5 0 13.8 5.5 18 2.9 2.1 5.6 3.9 9 3.9 3.3 0 7.2-1.7 10-3.6l118-84.1 118 84.1c2.8 2 6.7 3.6 10 3.6 3.4 0 6.1-1.7 8.9-3.9 5.6-4.2 7.8-11.4 5.5-18L352 307.2l119.9-86 2.9-2.5c2.6-2.8 5.2-6.6 5.2-10.7 0-8.8-8.2-16-17-16z",
                },
                child: [],
            },
        ],
    })(s);
}
function zh(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M413.967 276.8c1.06-6.235 1.06-13.518 1.06-20.8s-1.06-13.518-1.06-20.8l44.667-34.318c4.26-3.118 5.319-8.317 2.13-13.518L418.215 115.6c-2.129-4.164-8.507-6.235-12.767-4.164l-53.186 20.801c-10.638-8.318-23.394-15.601-36.16-20.801l-7.448-55.117c-1.06-4.154-5.319-8.318-10.638-8.318h-85.098c-5.318 0-9.577 4.164-10.637 8.318l-8.508 55.117c-12.767 5.2-24.464 12.482-36.171 20.801l-53.186-20.801c-5.319-2.071-10.638 0-12.767 4.164L49.1 187.365c-2.119 4.153-1.061 10.399 2.129 13.518L96.97 235.2c0 7.282-1.06 13.518-1.06 20.8s1.06 13.518 1.06 20.8l-44.668 34.318c-4.26 3.118-5.318 8.317-2.13 13.518L92.721 396.4c2.13 4.164 8.508 6.235 12.767 4.164l53.187-20.801c10.637 8.318 23.394 15.601 36.16 20.801l8.508 55.117c1.069 5.2 5.318 8.318 10.637 8.318h85.098c5.319 0 9.578-4.164 10.638-8.318l8.518-55.117c12.757-5.2 24.464-12.482 36.16-20.801l53.187 20.801c5.318 2.071 10.637 0 12.767-4.164l42.549-71.765c2.129-4.153 1.06-10.399-2.13-13.518l-46.8-34.317zm-158.499 52c-41.489 0-74.46-32.235-74.46-72.8s32.971-72.8 74.46-72.8 74.461 32.235 74.461 72.8-32.972 72.8-74.461 72.8z",
                },
                child: [],
            },
        ],
    })(s);
}
const Qn = ({ primaryColor: s, label: S, onClick: x }) => {
    const { state: r } = ht(),
        M = r?.tables?.lang ?? {};
    return b.jsxs("div", {
        onClick: x,
        className: `${S === M.openMap ? "cursor-pointer" : ""}  w-[100%] h-[100%] bg-[#FFFFFF26] gap-[1vh] flex justify-start items-center pl-[2vh]`,
        children: [
            b.jsx(Ah, { style: { color: s }, className: "text-[1.7vh]" }),
            b.jsx("p", { className: "text-[1.4vh] text-white font-[500]", children: S }),
        ],
    });
};
function Oh(s) {
    return ql({
        attr: { viewBox: "0 0 24 24" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M12.97 2.59a1.5 1.5 0 0 0-1.94 0l-7.5 6.363A1.5 1.5 0 0 0 3 10.097V19.5A1.5 1.5 0 0 0 4.5 21h4.75a.75.75 0 0 0 .75-.75V14h4v6.25c0 .414.336.75.75.75h4.75a1.5 1.5 0 0 0 1.5-1.5v-9.403a1.5 1.5 0 0 0-.53-1.144l-7.5-6.363Z",
                },
                child: [],
            },
        ],
    })(s);
}
function Er(s) {
    return ql({
        attr: { viewBox: "0 0 256 256", fill: "currentColor" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M228.92,49.69a8,8,0,0,0-6.86-1.45L160.93,63.52,99.58,32.84a8,8,0,0,0-5.52-.6l-64,16A8,8,0,0,0,24,56V200a8,8,0,0,0,9.94,7.76l61.13-15.28,61.35,30.68A8.15,8.15,0,0,0,160,224a8,8,0,0,0,1.94-.24l64-16A8,8,0,0,0,232,200V56A8,8,0,0,0,228.92,49.69ZM96,176a8,8,0,0,0-1.94.24L40,189.75V62.25L95.07,48.48l.93.46Zm120,17.75-55.07,13.77-.93-.46V80a8,8,0,0,0,1.94-.23L216,66.25Z",
                },
                child: [],
            },
        ],
    })(s);
}
function pr(s) {
    return ql({
        attr: { viewBox: "0 0 256 256", fill: "currentColor" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M172,120a44,44,0,1,1-44-44A44.05,44.05,0,0,1,172,120Zm60,8A104,104,0,1,1,128,24,104.11,104.11,0,0,1,232,128Zm-16,0a88.09,88.09,0,0,0-91.47-87.93C77.43,41.89,39.87,81.12,40,128.25a87.65,87.65,0,0,0,22.24,58.16A79.71,79.71,0,0,1,84,165.1a4,4,0,0,1,4.83.32,59.83,59.83,0,0,0,78.28,0,4,4,0,0,1,4.83-.32,79.71,79.71,0,0,1,21.79,21.31A87.62,87.62,0,0,0,216,128Z",
                },
                child: [],
            },
        ],
    })(s);
}
function Mh(s) {
    return ql({
        attr: { viewBox: "0 0 640 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M524.531,69.836a1.5,1.5,0,0,0-.764-.7A485.065,485.065,0,0,0,404.081,32.03a1.816,1.816,0,0,0-1.923.91,337.461,337.461,0,0,0-14.9,30.6,447.848,447.848,0,0,0-134.426,0,309.541,309.541,0,0,0-15.135-30.6,1.89,1.89,0,0,0-1.924-.91A483.689,483.689,0,0,0,116.085,69.137a1.712,1.712,0,0,0-.788.676C39.068,183.651,18.186,294.69,28.43,404.354a2.016,2.016,0,0,0,.765,1.375A487.666,487.666,0,0,0,176.02,479.918a1.9,1.9,0,0,0,2.063-.676A348.2,348.2,0,0,0,208.12,430.4a1.86,1.86,0,0,0-1.019-2.588,321.173,321.173,0,0,1-45.868-21.853,1.885,1.885,0,0,1-.185-3.126c3.082-2.309,6.166-4.711,9.109-7.137a1.819,1.819,0,0,1,1.9-.256c96.229,43.917,200.41,43.917,295.5,0a1.812,1.812,0,0,1,1.924.233c2.944,2.426,6.027,4.851,9.132,7.16a1.884,1.884,0,0,1-.162,3.126,301.407,301.407,0,0,1-45.89,21.83,1.875,1.875,0,0,0-1,2.611,391.055,391.055,0,0,0,30.014,48.815,1.864,1.864,0,0,0,2.063.7A486.048,486.048,0,0,0,610.7,405.729a1.882,1.882,0,0,0,.765-1.352C623.729,277.594,590.933,167.465,524.531,69.836ZM222.491,337.58c-28.972,0-52.844-26.587-52.844-59.239S193.056,219.1,222.491,219.1c29.665,0,53.306,26.82,52.843,59.239C275.334,310.993,251.924,337.58,222.491,337.58Zm195.38,0c-28.971,0-52.843-26.587-52.843-59.239S388.437,219.1,417.871,219.1c29.667,0,53.307,26.82,52.844,59.239C470.715,310.993,447.538,337.58,417.871,337.58Z",
                },
                child: [],
            },
        ],
    })(s);
}
function Nh(s) {
    return ql({
        attr: { viewBox: "0 0 616 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M602 118.6L537.1 15C531.3 5.7 521 0 510 0H106C95 0 84.7 5.7 78.9 15L14 118.6c-33.5 53.5-3.8 127.9 58.8 136.4 4.5.6 9.1.9 13.7.9 29.6 0 55.8-13 73.8-33.1 18 20.1 44.3 33.1 73.8 33.1 29.6 0 55.8-13 73.8-33.1 18 20.1 44.3 33.1 73.8 33.1 29.6 0 55.8-13 73.8-33.1 18.1 20.1 44.3 33.1 73.8 33.1 4.7 0 9.2-.3 13.7-.9 62.8-8.4 92.6-82.8 59-136.4zM529.5 288c-10 0-19.9-1.5-29.5-3.8V384H116v-99.8c-9.6 2.2-19.5 3.8-29.5 3.8-6 0-12.1-.4-18-1.2-5.6-.8-11.1-2.1-16.4-3.6V480c0 17.7 14.3 32 32 32h448c17.7 0 32-14.3 32-32V283.2c-5.4 1.6-10.8 2.9-16.4 3.6-6.1.8-12.1 1.2-18.2 1.2z",
                },
                child: [],
            },
        ],
    })(s);
}
function Ar(s) {
    return ql({
        attr: { viewBox: "0 0 448 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M224 256c70.7 0 128-57.3 128-128S294.7 0 224 0 96 57.3 96 128s57.3 128 128 128zm89.6 32h-16.7c-22.2 10.2-46.9 16-72.9 16s-50.6-5.8-72.9-16h-16.7C60.2 288 0 348.2 0 422.4V464c0 26.5 21.5 48 48 48h352c26.5 0 48-21.5 48-48v-41.6c0-74.2-60.2-134.4-134.4-134.4z",
                },
                child: [],
            },
        ],
    })(s);
}
function _h(s) {
    return ql({
        attr: { viewBox: "0 0 512 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M461.2 128H80c-8.84 0-16-7.16-16-16s7.16-16 16-16h384c8.84 0 16-7.16 16-16 0-26.51-21.49-48-48-48H64C28.65 32 0 60.65 0 96v320c0 35.35 28.65 64 64 64h397.2c28.02 0 50.8-21.53 50.8-48V176c0-26.47-22.78-48-50.8-48zM416 336c-17.67 0-32-14.33-32-32s14.33-32 32-32 32 14.33 32 32-14.33 32-32 32z",
                },
                child: [],
            },
        ],
    })(s);
}
const Dh = "https://prism_pausemenu",
    yr = { method: "POST", headers: { "Content-Type": "application/json; charset=UTF-8" } },
    jh = {
        async send(s, S = {}, x = {}) {
            try {
                const r = `${Dh}/${s}`,
                    M = {
                        ...yr,
                        ...x,
                        headers: { ...yr.headers, ...x.headers },
                        body: x.method === "GET" ? void 0 : JSON.stringify(S),
                    },
                    H = await fetch(r, M);
                if (!H.ok) {
                    const W = await H.text();
                    throw new Error(`Error ${H.status}: ${W || "request failed"}`);
                }
                if (H.status === 204) return null;
                const V = H.headers.get("content-type");
                return V && V.includes("application/json") ? await H.json() : await H.text();
            } catch (r) {
                throw (console.error(`Error ${s}:`, r.message), r);
            }
        },
    },
    Tu = async (s, S = {}, x, r) => {
        try {
            return await jh.send(s, S);
        } catch (M) {
            return console.error(`NUI event failed: ${s}`, M), null;
        }
    },
    Uh = () => {
        const { state: s } = ht(),
            S = s?.tables?.style?.primaryColor ?? "#ffffff",
            x = s?.tables?.lang ?? {},
            r = [
                { name: x?.home, icon: Oh },
                { name: x?.map, icon: Er, onClick: () => Tu("open_map", {}) },
                { name: x?.settings, icon: zh, onClick: () => Tu("open_settings", {}) },
                // {
                //     name: x?.tebex,
                //     icon: Nh,
                //     onClick: () => window.invokeNative("openUrl", s?.tables?.links?.tebex ?? "https://tebex.io"),
                // },
                {
                    name: x?.discord,
                    icon: Mh,
                    onClick: () => window.invokeNative("openUrl", s?.tables?.links?.discord ?? "https://discord.gg"),
                },
                { name: x?.exit, icon: ph, onClick: () => Tu("exit", {}) },
            ];
        return b.jsx("div", {
            className: "w-full h-[4.5vh] bg-[#FFFFFF14] rounded-[1vh] flex justify-around",
            children: r.map(({ name: M, icon: H, onClick: V }, W) => {
                const D = M === x?.home,
                    z = H;
                return b.jsx(
                    Eh,
                    {
                        style: D ? { borderBottomColor: S } : {},
                        onClick: V,
                        children: b.jsxs("div", {
                            className: "flex items-center gap-[1vh] justify-center min-w-0",
                            children: [
                                b.jsx(z, {
                                    style: { color: D ? S : "#ffffff83" },
                                    className: "text-[1.6vh] leading-[2vh] flex-shrink-0",
                                }),
                                b.jsx("p", {
                                    className: `${D ? "text-white" : "text-[#ffffff83]"} text-[1.6vh] font-[400] leading-[2vh] truncate`,
                                    children: M,
                                }),
                            ],
                        }),
                    },
                    W
                );
            }),
        });
    },
    Rh = () => {
        const { state: s } = ht(),
            S = s?.tables?.style?.primaryColor ?? "#ffffff",
            x = s?.tables?.style?.primaryColorBackground ?? "transparent",
            r = s?.tables?.lang ?? {};
        return b.jsxs("div", {
            className: "w-[100%] h-[50%] bg-[#FFFFFF14] rounded-[1vh] overflow-hidden flex flex-col",
            children: [
                b.jsx("div", {
                    style: { backgroundImage: "url(./images/Map.png)" },
                    className: "w-[100%] h-[85%] bg-cover flex justify-start",
                    children: b.jsx("div", {
                        className: "w-auto h-[100%] flex justify-start items-start",
                        children: b.jsx("div", {
                            className: "w-auto flex pt-[3vh] pl-[3vh]",
                            children: b.jsx(Xn, {
                                primaryColor: S,
                                icon: Er,
                                primaryColorBackground: x,
                                reverse: !0,
                                title: r.map,
                                description: r.mapDescription,
                            }),
                        }),
                    }),
                }),
                b.jsx("div", {
                    className: "w-[100%] h-[15%] flex",
                    children: b.jsx(Qn, { onClick: () => Tu("open_map", {}), primaryColor: S, label: r.openMap }),
                }),
            ],
        });
    };
function Hh(s) {
    return ql({
        attr: { viewBox: "0 0 24 24", fill: "currentColor" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M12.0049 22.0027C6.48204 22.0027 2.00488 17.5256 2.00488 12.0027C2.00488 6.4799 6.48204 2.00275 12.0049 2.00275C17.5277 2.00275 22.0049 6.4799 22.0049 12.0027C22.0049 17.5256 17.5277 22.0027 12.0049 22.0027ZM8.50488 14.0027V16.0027H11.0049V18.0027H13.0049V16.0027H14.0049C15.3856 16.0027 16.5049 14.8835 16.5049 13.5027C16.5049 12.122 15.3856 11.0027 14.0049 11.0027H10.0049C9.72874 11.0027 9.50488 10.7789 9.50488 10.5027C9.50488 10.2266 9.72874 10.0027 10.0049 10.0027H15.5049V8.00275H13.0049V6.00275H11.0049V8.00275H10.0049C8.62417 8.00275 7.50488 9.12203 7.50488 10.5027C7.50488 11.8835 8.62417 13.0027 10.0049 13.0027H14.0049C14.281 13.0027 14.5049 13.2266 14.5049 13.5027C14.5049 13.7789 14.281 14.0027 14.0049 14.0027H8.50488Z",
                },
                child: [],
            },
        ],
    })(s);
}
function Bh(s) {
    return ql({
        attr: { viewBox: "0 0 576 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M256 32c-17.7 0-32 14.3-32 32l0 2.3 0 99.6c0 5.6-4.5 10.1-10.1 10.1c-3.6 0-7-1.9-8.8-5.1L157.1 87C83 123.5 32 199.8 32 288l0 64 512 0 0-66.4c-.9-87.2-51.7-162.4-125.1-198.6l-48 83.9c-1.8 3.2-5.2 5.1-8.8 5.1c-5.6 0-10.1-4.5-10.1-10.1l0-99.6 0-2.3c0-17.7-14.3-32-32-32l-64 0zM16.6 384C7.4 384 0 391.4 0 400.6c0 4.7 2 9.2 5.8 11.9C27.5 428.4 111.8 480 288 480s260.5-51.6 282.2-67.5c3.8-2.8 5.8-7.2 5.8-11.9c0-9.2-7.4-16.6-16.6-16.6L16.6 384z",
                },
                child: [],
            },
        ],
    })(s);
}
function mr(s) {
    return ql({
        attr: { viewBox: "0 0 640 512" },
        child: [
            {
                tag: "path",
                attr: {
                    d: "M579.8 267.7c56.5-56.5 56.5-148 0-204.5c-50-50-128.8-56.5-186.3-15.4l-1.6 1.1c-14.4 10.3-17.7 30.3-7.4 44.6s30.3 17.7 44.6 7.4l1.6-1.1c32.1-22.9 76-19.3 103.8 8.6c31.5 31.5 31.5 82.5 0 114L422.3 334.8c-31.5 31.5-82.5 31.5-114 0c-27.9-27.9-31.5-71.8-8.6-103.8l1.1-1.6c10.3-14.4 6.9-34.4-7.4-44.6s-34.4-6.9-44.6 7.4l-1.1 1.6C206.5 251.2 213 330 263 380c56.5 56.5 148 56.5 204.5 0L579.8 267.7zM60.2 244.3c-56.5 56.5-56.5 148 0 204.5c50 50 128.8 56.5 186.3 15.4l1.6-1.1c14.4-10.3 17.7-30.3 7.4-44.6s-30.3-17.7-44.6-7.4l-1.6 1.1c-32.1 22.9-76 19.3-103.8-8.6C74 372 74 321 105.5 289.5L217.7 177.2c31.5-31.5 82.5-31.5 114 0c27.9 27.9 31.5 71.8 8.6 103.9l-1.1 1.6c-10.3 14.4-6.9 34.4 7.4 44.6s34.4 6.9 44.6-7.4l1.1-1.6C433.5 260.8 427 182 377 132c-56.5-56.5-148-56.5-204.5 0L60.2 244.3z",
                },
                child: [],
            },
        ],
    })(s);
}
const Ch = () => {
    const { state: s } = ht(),
        S = s?.tables?.style?.primaryColor ?? "#ffffff",
        x = s?.tables?.style?.primaryColorBackground ?? "transparent",
        r = s?.tables?.lang ?? {};
    return b.jsxs("div", {
        className: "w-[100%] h-[100%] bg-[#FFFFFF14] overflow-hidden rounded-[1vh]",
        children: [
            b.jsxs("div", {
                className: "w-[100%] h-[85%] flex flex-col items-center justify-center p-[2vh]",
                children: [
                    b.jsx(Xn, {
                        primaryColor: S,
                        icon: Hh,
                        primaryColorBackground: x,
                        title: r.donate,
                        description: r.donateDescription,
                    }),
                    // b.jsxs("button", {
                    //     onClick: () => window.invokeNative("openUrl", s?.tables?.links?.tebex ?? "https://tebex.io"),
                    //     className:
                    //         "cursor-pointer bg-[#FFFFFF14] w-[100%] pl-[1vh] pr-[1vh]  h-[4vh] mt-[1.5vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] grid grid-cols-3 items-center",
                    //     children: [
                    //         b.jsx(mr, { style: { color: S }, className: "text-[1.7vh]" }),
                    //         b.jsx("p", {
                    //             className: "text-center text-white text-[1.3vh] font-[500]",
                    //             children: r.store,
                    //         }),
                    //     ],
                    // }),
                    b.jsxs("button", {
                        onClick: () =>
                            fetch(`https://${GetParentResourceName()}/executeDonate`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                body: JSON.stringify({})
                            }),
                        className:
                            "cursor-pointer bg-[#FFFFFF14] w-[100%] pl-[1vh] pr-[1vh] h-[4vh] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] grid grid-cols-3 items-center",
                        children: [
                            b.jsx(mr, { style: { color: S }, className: "text-[1.7vh]" }),
                            b.jsx("p", {
                                className: "text-center text-white text-[1.3vh] font-[500]",
                                children: "Ủng hộ",
                            }),
                        ],
                    }),
                ],
            }),
            b.jsx("div", {
                className: "w-[100%] h-[15%] flex",
                children: b.jsx(Qn, { primaryColor: S, label: r.donate }),
            }),
        ],
    });
};
function zr(s) {
    return s.toLocaleString("en-US", { style: "currency", currency: "USD" });
}
const qh = () => {
        const { state: s } = ht(),
            S = s?.tables?.style?.primaryColor ?? "#ffffff",
            x = s?.tables?.style?.primaryColorBackground ?? "transparent",
            r = s?.tables?.lang ?? {},
            M = s?.tables?.personalData ?? {};
        return b.jsxs("div", {
            className: "backdrop--sm bg-[#FFFFFF14] w-[100%] h-[100%]  overflow-hidden rounded-[1vh] flex flex-col",
            children: [
                b.jsxs("div", {
                    className: "w-[100%] h-[85%] flex flex-col items-center justify-center p-[2vh]",
                    children: [
                        b.jsx(Xn, {
                            primaryColor: S,
                            icon: pr,
                            primaryColorBackground: x,
                            title: r.statistics,
                            description: r.statisticsDescription,
                        }),
                        b.jsxs("div", {
                            className: "w-[100%] h-[4vh] mt-[1.5vh] flex justify-start gap-[1vh]",
                            children: [
                                b.jsxs("div", {
                                    className:
                                        "w-[80%] h-[100%] bg-[#FFFFFF14] gap-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex justify-start items-center pl-[1vh] pr-[1vh]",
                                    children: [
                                        b.jsx(Ar, { style: { color: S }, className: "text-[1.7vh]" }),
                                        b.jsx("p", {
                                            className: "text-white text-[1.3vh] font-[500] w-auto",
                                            children: M.name,
                                        }),
                                    ],
                                }),
                                b.jsx("div", {
                                    className:
                                        "w-[20%] h-[100%] bg-[#FFFFFF14] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex items-center justify-center",
                                    children: b.jsx("p", {
                                        className: "text-[#ffffff65] text-[1.3vh] font-[500]",
                                        children: M.source,
                                    }),
                                }),
                            ],
                        }),
                        b.jsxs("div", {
                            className:
                                "w-[100%] h-[4vh] bg-[#FFFFFF14] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex justify-between items-center pl-[1vh] pr-[1vh]",
                            children: [
                                b.jsxs("div", {
                                    className: "flex justify-start items-center gap-[1vh]",
                                    children: [
                                        b.jsx(_h, { style: { color: S }, className: "text-[1.7vh]" }),
                                        b.jsx("p", {
                                            className: "text-white text-[1.3vh] font-[500] w-auto",
                                            children: r.cash,
                                        }),
                                    ],
                                }),
                                b.jsx("p", {
                                    className: "text-white text-[1.3vh] font-[500] w-auto",
                                    children: zr(M.cash),
                                }),
                            ],
                        }),
                    ],
                }),
                b.jsx("div", {
                    className: "w-[100%] h-[15%] flex",
                    children: b.jsx(Qn, { primaryColor: S, label: r.statistics }),
                }),
            ],
        });
    },
    Yh = () => {
        const { state: s } = ht(),
            S = s?.tables?.style?.primaryColor ?? "#ffffff",
            x = s?.tables?.style?.primaryColorBackground ?? "transparent",
            r = s?.tables?.lang ?? {},
            M = s?.tables?.personalData ?? {};
        return b.jsxs("div", {
            className: "w-[30%] h-[100%] bg-[#FFFFFF14] overflow-hidden rounded-[1vh]",
            children: [
                b.jsxs("div", {
                    className: "w-[100%] h-[93%] p-[2vh] flex flex-col items-center justify-center",
                    children: [
                        b.jsx(Xn, {
                            primaryColor: S,
                            reverse: !0,
                            icon: pr,
                            primaryColorBackground: x,
                            title: r.personal,
                            description: r.information,
                        }),
                        b.jsx("p", {
                            className: "text-[#ffffff65] text-[1.3vh] mt-[0.5vh] text-start w-[100%]",
                            children: r.personalDescription,
                        }),
                        b.jsxs("div", {
                            className:
                                " gap-[1vh] bg-[#FFFFFF14] w-[100%] pl-[1vh] pr-[1vh] h-[6vh] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex justify-start items-center",
                            children: [
                                b.jsx("div", {
                                    style: { backgroundColor: S },
                                    className: "w-[3vh] h-[3vh] rounded-[0.7vh] flex items-center justify-center",
                                    children: b.jsx(Ar, { className: "text-[1.5vh]" }),
                                }),
                                b.jsxs("div", {
                                    className: "w-auto flex flex-col leading-none gap-[0.5vh]",
                                    children: [
                                        b.jsx("p", { className: "text-white text-[1.4vh]", children: r.gang }),
                                        b.jsx("p", { className: "text-[#ffffff65] text-[1.3vh]", children: M.gang }),
                                    ],
                                }),
                            ],
                        }),
                        b.jsxs("div", {
                            className:
                                " gap-[1vh] bg-[#FFFFFF14] w-[100%] pl-[1vh] pr-[1vh] h-[6vh] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex justify-start items-center",
                            children: [
                                b.jsx("div", {
                                    style: { backgroundColor: S },
                                    className: "w-[3vh] h-[3vh] rounded-[0.7vh] flex items-center justify-center",
                                    children: b.jsx(Bh, { className: "text-[1.5vh]" }),
                                }),
                                b.jsxs("div", {
                                    className: "w-auto flex flex-col leading-none gap-[0.5vh]",
                                    children: [
                                        b.jsx("p", { className: "text-white text-[1.4vh]", children: r.job }),
                                        b.jsx("p", { className: "text-[#ffffff65] text-[1.3vh]", children: M.job }),
                                    ],
                                }),
                            ],
                        }),
                        b.jsxs("div", {
                            className:
                                "w-full h-[15vh] bg-[#FFFFFF14] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex flex-col justify-around p-[1vh]",
                            children: [
                                b.jsxs("div", {
                                    className: "w-[100%] h-auto flex justify-between",
                                    children: [
                                        b.jsx("p", {
                                            className: "text-white text-[1.3vh] font-[400]",
                                            children: M.name,
                                        }),
                                        b.jsx("p", {
                                            className: "text-[#ffffff65] text-[1.3vh] font-[400]",
                                            children: r.bankName,
                                        }),
                                    ],
                                }),
                                b.jsx("div", {
                                    className: "w-[100%] flex justify-start break-all",
                                    children: b.jsx("p", {
                                        className: "text-white text-[1.8vh] font-[500]",
                                        children: zr(M.bank),
                                    }),
                                }),
                                b.jsxs("div", {
                                    className: "w-[100%] h-auto flex justify-between",
                                    children: [
                                        b.jsx("p", {
                                            className: "text-white text-[1.3vh] font-[400]",
                                            children: r.valid,
                                        }),
                                        b.jsx("p", {
                                            className: "text-[#ffffff65] text-[1.3vh] font-[400]",
                                            children: "07/20",
                                        }),
                                    ],
                                }),
                                b.jsxs("div", {
                                    className: "w-[100%] h-auto flex justify-between",
                                    children: [
                                        b.jsx("p", {
                                            style: { color: S },
                                            className: "text-[1.3vh] font-[300]",
                                            children: r.creditCard,
                                        }),
                                        b.jsx("p", {
                                            style: { color: S },
                                            className: "text-[1.3vh] font-[300]",
                                            children: "EXP",
                                        }),
                                    ],
                                }),
                            ],
                        }),
                        b.jsxs("div", {
                            className:
                                "w-[100%] h-[4vh] bg-[#FFFFFF14] mt-[1vh] border-[0.1vh] border-[#FFFFFF0A] rounded-[0.7vh] flex justify-between items-center pl-[1vh] pr-[1vh]",
                            children: [
                                b.jsxs("div", {
                                    className: "flex justify-start items-center gap-[1vh]",
                                    children: [
                                        b.jsx(Th, { style: { color: S }, className: "text-[1.7vh]" }),
                                        b.jsx("p", {
                                            className: "text-white text-[1.3vh] font-[500] w-auto",
                                            children: r.playTime,
                                        }),
                                    ],
                                }),
                                b.jsx("p", {
                                    className: "text-white text-[1.3vh] font-[500] w-auto",
                                    children: M.playTime,
                                }),
                            ],
                        }),
                    ],
                }),
                b.jsx("div", {
                    className: "w-[100%] h-[7%] flex",
                    children: b.jsx(Qn, { primaryColor: S, label: r.personal }),
                }),
            ],
        });
    },
    Or = () =>
        b.jsxs("div", {
            className: "w-[89.25vh] h-[55vh] flex flex-col justify-start gap-[1.5vh] ",
            children: [
                b.jsx("div", { className: "w-[100%] h-[4.5vh] flex", children: b.jsx(Uh, {}) }),
                b.jsxs("div", {
                    className: "w-[100%] h-[100%] flex justify-start gap-[1.5vh] ",
                    children: [
                        b.jsxs("div", {
                            className: "w-[70%] h-[100%] flex flex-col gap-[1.5vh]",
                            children: [
                                b.jsx(Rh, {}),
                                b.jsxs("div", {
                                    className: "w-[100%] h-[50%] grid grid-cols-2 gap-[1.5vh]",
                                    children: [b.jsx(Ch, {}), b.jsx(qh, {})],
                                }),
                            ],
                        }),
                        b.jsx(Yh, {}),
                    ],
                }),
            ],
        }),
    Gh = () => {
        const [s, S] = dt.useState(!1);
        return (
            dt.useEffect(() => {
                const x = setTimeout(() => {
                    S(!0);
                }, 100);
                return () => clearTimeout(x);
            }, []),
            b.jsxs("div", {
                className: "w-[100%] h-[100%] flex",
                children: [
                    b.jsx(oh, {}),
                    b.jsxs("div", {
                        className: "w-[100%] h-[100%] absolute flex flex-col",
                        children: [
                            b.jsx("div", {
                                className: "w-[100%] h-[13vh] flex justify-start pl-[3vh]",
                                children: b.jsx(xr, {}),
                            }),
                            b.jsx("div", {
                                className: "w-[100%] h-[75vh] flex items-center justify-center relative",
                                children: b.jsx("div", {
                                    style: {
                                        transform: s ? "translateY(0)" : "translateY(-100%)",
                                        opacity: s ? 1 : 0,
                                        transition: "transform 1s ease, opacity 0.6s ease",
                                    },
                                    children: b.jsx(Or, {}),
                                }),
                            }),
                            b.jsx("div", {
                                className: "w-[100%] h-[13vh] grid grid-cols-3",
                                children: b.jsx("div", {
                                    className: "w-[100%] h-[100%] pl-[3vh] flex items-center",
                                    children: b.jsx(Tr, {}),
                                }),
                            }),
                        ],
                    }),
                ],
            })
        );
    },
    Xh = () => {
        const [s, S] = dt.useState(!1);
        return (
            dt.useEffect(() => {
                const x = setTimeout(() => {
                    S(!0);
                }, 100);
                return () => clearTimeout(x);
            }, []),
            b.jsxs("div", {
                className: "w-[100%] h-[100%] flex",
                children: [
                    b.jsx(dh, {}),
                    b.jsxs("div", {
                        className: "w-[100%] h-[100%] absolute flex flex-col justify-start",
                        children: [
                            b.jsxs("div", {
                                className: "w-[100%] h-[18vh] flex flex-col justify-start",
                                children: [
                                    b.jsx("div", {
                                        className: "w-[100%] h-[68%] flex justify-end items-end pr-[5vh]",
                                        children: b.jsx(Tr, { reverse: !0 }),
                                    }),
                                    b.jsx("div", {
                                        className: "w-[100%] pl-[10vh] h-[20%] flex justify-start items-end pr-[5vh]",
                                        children: b.jsx(xr, {}),
                                    }),
                                ],
                            }),
                            b.jsx("div", {
                                className: "w-[100%] h-[100%] flex justify-start items-start pl-[10vh] pt-[3vh]",
                                children: b.jsx("div", {
                                    style: {
                                        transform: s ? "translateX(0)" : "translateX(-100%)",
                                        opacity: s ? 1 : 0,
                                        transition: "transform 1s ease, opacity 0.6s ease",
                                    },
                                    children: b.jsx(Or, {}),
                                }),
                            }),
                        ],
                    }),
                ],
            })
        );
    };
function Qh() {
    const { setTableData: s } = ht(),
        [S, x] = dt.useState("");
    return (
        dt.useEffect(() => {
            const r = (M) => {
                const { type: H, data: V } = M.data || {};
                H
                    ? (s("style", V.style || {}),
                      s("lang", V.lang || {}),
                      s("links", V.links || {}),
                      s("strings", V.strings || {}),
                      s("personalData", V.personalData || {}),
                      x(V.show))
                    : x("");
            };
            return (
                window.addEventListener("message", r),
                () => {
                    window.removeEventListener("message", r);
                }
            );
        }, [s]),
        dt.useEffect(() => {
            const r = (M) => {
                M.key === "Escape" && (Tu("close", {}), x(""));
            };
            return (
                window.addEventListener("keydown", r),
                () => {
                    window.removeEventListener("keydown", r);
                }
            );
        }, []),
        b.jsxs("div", {
            className: "w-[100%] h-[100vh] flex ",
            children: [S === "center" && b.jsx(Gh, {}), S === "side" && b.jsx(Xh, {})],
        })
    );
}
ch.createRoot(document.getElementById("root")).render(
    b.jsx(dt.StrictMode, { children: b.jsx(rh, { children: b.jsx(Qh, {}) }) })
);
