import from "@jac/runtime" { __doFuncFetch }
cl import from shared { panel_classes }

def _res(raw: any, key: str) -> any {
    if raw and raw[key] { return raw[key]; }
    if raw and raw["data"] and raw["data"]["result"] and raw["data"]["result"][key] { return raw["data"]["result"][key]; }
    return None;
}

def:pub TenantsPropertiesView() -> JsxElement {
    has properties: list = [];
    has tenants: list = [];
    has tab: str = "Properties";
    has loading: bool = False;
    has error_msg: str = "";
    has show_prop_modal: bool = False;
    has show_tenant_modal: bool = False;

    has form_prop_name: str = "";
    has form_prop_address: str = "";
    has form_tenant_name: str = "";
    has form_tenant_phone: str = "";
    has form_tenant_unit: str = "";
    has form_tenant_prop_id: str = "";
    has form_tenant_rent: str = "1200";

    has _loaded: bool = False;

    async def reload() -> None {
        loading = True;
        error_msg = "";
        try {
            pr = await __doFuncFetch("fetch_properties", {});
            props_raw = _res(pr, "properties");
            properties = props_raw if props_raw else [];

            tr = await __doFuncFetch("fetch_tenants", {});
            ten_raw = _res(tr, "tenants");
            tenants = ten_raw if ten_raw else [];

            # Mirror to localStorage so triage phone matching works
            localStorage.setItem("rentora_tenants", JSON.stringify(tenants));
        } except Exception as e {
            error_msg = "Failed to load data: " + str(e);
        }
        loading = False;
    }

    if not _loaded {
        _loaded = True;
        reload();
    }

    async def save_property() -> None {
        if not form_prop_name {
            error_msg = "Property name is required.";
            return;
        }
        error_msg = "";
        loading = True;
        try {
            r = await __doFuncFetch("save_property_data", {"name": form_prop_name, "address": form_prop_address});
            res = _res(r, "status") or (r["status"] if r and r["status"] else None);
            if res == "error" {
                msg = _res(r, "message") or (r["message"] if r and r["message"] else "Unknown error");
                error_msg = str(msg);
            } else {
                show_prop_modal = False;
                form_prop_name = "";
                form_prop_address = "";
                await reload();
            }
        } except Exception as e {
            error_msg = "Failed to add property: " + str(e);
        }
        loading = False;
    }

    async def delete_property(p_id: str) -> None {
        if window.confirm("Delete this property and all its tenants?") {
            error_msg = "";
            loading = True;
            try {
                await __doFuncFetch("delete_property_data", {"property_id": p_id});
                await reload();
            } except Exception as e {
                error_msg = "Failed to delete: " + str(e);
            }
            loading = False;
        }
    }

    async def save_tenant() -> None {
        if not form_tenant_name or not form_tenant_phone or not form_tenant_unit {
            error_msg = "Name, phone, and unit are required.";
            return;
        }
        if not form_tenant_prop_id {
            error_msg = "Please select a property. Add one first if needed.";
            return;
        }
        prop_name = "";
        for p in properties {
            if p["id"] == form_tenant_prop_id {
                prop_name = p["name"];
                break;
            }
        }
        rent_f = 0.0;
        try { rent_f = float(form_tenant_rent); } except Exception {}
        error_msg = "";
        loading = True;
        try {
            r = await __doFuncFetch("save_tenant_data", {
                "tenant_name": form_tenant_name,
                "tenant_phone": form_tenant_phone,
                "unit_number": form_tenant_unit,
                "rent_amount": rent_f,
                "property_name": prop_name
            });
            status_val = (r["status"] if r and r["status"] else None) or _res(r, "status");
            if status_val == "error" {
                msg_val = (r["message"] if r and r["message"] else "") or _res(r, "message") or "Unknown error";
                error_msg = str(msg_val);
            } else {
                show_tenant_modal = False;
                form_tenant_name = "";
                form_tenant_phone = "";
                form_tenant_unit = "";
                form_tenant_prop_id = "";
                form_tenant_rent = "1200";
                await reload();
            }
        } except Exception as e {
            error_msg = "Failed to add tenant: " + str(e);
        }
        loading = False;
    }

    async def delete_tenant(t_id: str) -> None {
        if window.confirm("Remove this tenant?") {
            error_msg = "";
            loading = True;
            try {
                await __doFuncFetch("delete_tenant_data", {"tenant_id": t_id});
                await reload();
            } except Exception as e {
                error_msg = "Failed to delete: " + str(e);
            }
            loading = False;
        }
    }

    return (
        <div className="p-8 max-w-5xl mx-auto h-full overflow-y-auto">
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-2xl font-semibold text-slate-900 tracking-tight">Tenants & Properties</h1>
                    <p className="text-sm text-slate-500 mt-1">Stored in graph. Tenant phones are used for automatic SMS triage matching.</p>
                </div>
                <div className="flex gap-3">
                    <button onClick={lambda -> None { form_prop_name = ""; form_prop_address = ""; error_msg = ""; show_prop_modal = True; }} className="bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-50 transition">
                        Add Property
                    </button>
                    <button onClick={lambda -> None {
                        if len(properties) == 0 {
                            error_msg = "Add a property first before adding tenants.";
                            return;
                        }
                        form_tenant_name = ""; form_tenant_phone = ""; form_tenant_unit = ""; form_tenant_prop_id = properties[0]["id"]; form_tenant_rent = "1200"; error_msg = ""; show_tenant_modal = True;
                    }} className="bg-slate-900 text-white px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-800 transition">
                        Add Tenant
                    </button>
                </div>
            </div>

            {error_msg and (
                <div className="mb-5 bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm flex items-center justify-between">
                    <span>{error_msg}</span>
                    <button onClick={lambda -> None { error_msg = ""; }} className="ml-4 text-red-400 hover:text-red-700 font-bold text-lg leading-none">&times;</button>
                </div>
            )}

            <div className="flex gap-6 border-b border-slate-200 mb-6">
                <button onClick={lambda -> None { tab = "Properties"; }} className={"pb-3 text-sm font-medium transition-colors border-b-2 " + (tab == "Properties" and "border-slate-900 text-slate-900" or "border-transparent text-slate-500 hover:text-slate-700")}>
                    Properties ({len(properties)})
                </button>
                <button onClick={lambda -> None { tab = "Tenants"; }} className={"pb-3 text-sm font-medium transition-colors border-b-2 " + (tab == "Tenants" and "border-slate-900 text-slate-900" or "border-transparent text-slate-500 hover:text-slate-700")}>
                    Tenants ({len(tenants)})
                </button>
            </div>

            {loading and (
                <div className="flex items-center justify-center py-12 text-slate-400 text-sm gap-2">
                    <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10" opacity="0.25"/><path d="M12 2a10 10 0 0 1 10 10" strokeLinecap="round"/></svg>
                    Loading...
                </div>
            )}

            {not loading and tab == "Properties" and (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    {len(properties) == 0 and (
                        <div className="col-span-full bg-slate-50 border border-dashed border-slate-300 rounded-xl p-12 flex flex-col items-center justify-center text-center">
                            <h3 className="text-slate-900 font-medium mb-1">No properties yet</h3>
                            <p className="text-slate-500 text-sm mb-4">Add your first property to start managing tenants.</p>
                            <button onClick={lambda -> None { form_prop_name = ""; form_prop_address = ""; error_msg = ""; show_prop_modal = True; }} className="text-sm font-medium text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">Add Property</button>
                        </div>
                    )}
                    {properties.map(lambda p: any -> JsxElement {
                        t_count = len([t for t in tenants if t["property_id"] == p["id"]]);
                        return (
                            <div key={p["id"]} className={panel_classes() + " p-5 flex flex-col group relative hover:border-slate-300 transition"}>
                                <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button onClick={lambda -> None { delete_property(p["id"]); }} className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded" title="Delete">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                    </button>
                                </div>
                                <h3 className="font-semibold text-slate-900 pr-8 mb-2">{p["name"]}</h3>
                                <p className="text-sm text-slate-500 mb-6">{p["address"] if p["address"] else "No address"}</p>
                                <div className="mt-auto pt-4 border-t border-slate-100 flex justify-between items-center text-xs font-medium text-slate-600">
                                    <span>{t_count} {t_count == 1 and "Tenant" or "Tenants"}</span>
                                    <button onClick={lambda -> None { tab = "Tenants"; }} className="text-slate-500 hover:text-slate-900">View &rarr;</button>
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}

            {not loading and tab == "Tenants" and (
                <div className={panel_classes() + " overflow-hidden"}>
                    {len(tenants) == 0 and (
                        <div className="p-12 text-center flex flex-col items-center bg-slate-50 m-2 rounded-lg border border-dashed border-slate-200">
                            <h3 className="text-slate-900 font-medium mb-1">No tenants yet</h3>
                            <p className="text-slate-500 text-sm mb-4">
                                {len(properties) == 0 and "Add a property first, then add tenants." or "Add a tenant to enable automatic SMS matching."}
                            </p>
                            <button onClick={lambda -> None {
                                if len(properties) == 0 { error_msg = "Add a property first."; tab = "Properties"; return; }
                                form_tenant_name = ""; form_tenant_phone = ""; form_tenant_unit = ""; form_tenant_prop_id = properties[0]["id"]; form_tenant_rent = "1200"; error_msg = ""; show_tenant_modal = True;
                            }} className="text-sm font-medium text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">Add Tenant</button>
                        </div>
                    )}
                    {len(tenants) > 0 and (
                        <table className="w-full text-left text-sm">
                            <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                                <tr className="border-b border-slate-200">
                                    <th className="px-6 py-3 font-medium">Tenant</th>
                                    <th className="px-6 py-3 font-medium">Phone</th>
                                    <th className="px-6 py-3 font-medium">Unit</th>
                                    <th className="px-6 py-3 font-medium">Property</th>
                                    <th className="px-6 py-3 font-medium">Rent</th>
                                    <th className="px-6 py-3"></th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {tenants.map(lambda t: any -> JsxElement {
                                    return (
                                        <tr key={t["id"]} className="hover:bg-slate-50/50 group">
                                            <td className="px-6 py-4 font-medium text-slate-900">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-7 h-7 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center text-xs font-semibold shrink-0">
                                                        {t["full_name"][0].toUpperCase() if t["full_name"] else "?"}
                                                    </div>
                                                    {t["full_name"]}
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 font-mono text-slate-500 text-xs">{t["phone_number"]}</td>
                                            <td className="px-6 py-4"><span className="px-2 py-0.5 rounded bg-slate-100 border border-slate-200 text-xs font-mono font-medium">{t["unit_number"]}</span></td>
                                            <td className="px-6 py-4 text-slate-600 text-xs">{t["property_name"] if t["property_name"] else "—"}</td>
                                            <td className="px-6 py-4 text-slate-600 text-xs">${t["rent"]}/mo</td>
                                            <td className="px-6 py-4 text-right">
                                                <button onClick={lambda -> None { delete_tenant(t["id"]); }} className="p-1.5 text-slate-300 hover:text-red-600 hover:bg-red-50 rounded opacity-0 group-hover:opacity-100 transition-opacity" title="Remove">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                </button>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    )}
                </div>
            )}

            {show_prop_modal and (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className={"w-full max-w-md shadow-xl " + panel_classes() + " p-6"}>
                        <h2 className="text-lg font-semibold text-slate-900 mb-5">Add New Property</h2>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Property Name</label>
                                <input value={form_prop_name} onChange={lambda e: any -> None { form_prop_name = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 transition-shadow" placeholder="e.g. Harbor Point Residences" autoFocus={True} />
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Street Address</label>
                                <input value={form_prop_address} onChange={lambda e: any -> None { form_prop_address = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 transition-shadow" placeholder="123 Main St" />
                            </div>
                        </div>
                        <div className="mt-6 flex gap-3 justify-end">
                            <button onClick={lambda -> None { show_prop_modal = False; error_msg = ""; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
                            <button onClick={save_property} disabled={not form_prop_name} className="px-4 py-2 rounded-md text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 transition disabled:opacity-50">Save</button>
                        </div>
                    </div>
                </div>
            )}

            {show_tenant_modal and (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className={"w-full max-w-md shadow-xl " + panel_classes() + " p-6"}>
                        <h2 className="text-lg font-semibold text-slate-900 mb-5">Add Tenant</h2>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Full Name</label>
                                <input value={form_tenant_name} onChange={lambda e: any -> None { form_tenant_name = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 transition-shadow" placeholder="e.g. Maya Chen" autoFocus={True} />
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Phone Number</label>
                                <input value={form_tenant_phone} onChange={lambda e: any -> None { form_tenant_phone = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 font-mono transition-shadow" placeholder="+15551234567" />
                                <p className="text-[10px] text-slate-400 mt-1">Must match exactly the number they text from. Use +1 format.</p>
                            </div>
                            <div className="flex gap-3">
                                <div className="flex-1">
                                    <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Unit</label>
                                    <input value={form_tenant_unit} onChange={lambda e: any -> None { form_tenant_unit = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 font-mono transition-shadow" placeholder="3D" />
                                </div>
                                <div className="flex-1">
                                    <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Monthly Rent ($)</label>
                                    <input type="number" value={form_tenant_rent} onChange={lambda e: any -> None { form_tenant_rent = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 transition-shadow" placeholder="1200" />
                                </div>
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Property</label>
                                <select value={form_tenant_prop_id} onChange={lambda e: any -> None { form_tenant_prop_id = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 bg-white transition-shadow">
                                    <option value="">Select property...</option>
                                    {properties.map(lambda p: any -> JsxElement {
                                        return <option key={p["id"]} value={p["id"]}>{p["name"]}</option>;
                                    })}
                                </select>
                            </div>
                        </div>
                        <div className="mt-6 flex gap-3 justify-end">
                            <button onClick={lambda -> None { show_tenant_modal = False; error_msg = ""; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
                            <button onClick={save_tenant} disabled={not form_tenant_name or not form_tenant_phone or not form_tenant_unit} className="px-4 py-2 rounded-md text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 transition disabled:opacity-50">Save Tenant</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
