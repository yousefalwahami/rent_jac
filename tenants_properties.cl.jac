cl import from shared { panel_classes }

def ls_load(key: str) -> list {
    try {
        raw = localStorage.getItem(key);
        return JSON.parse(raw) if raw else [];
    } except Exception { return []; }
}

def ls_save(key: str, val: list) -> None {
    localStorage.setItem(key, JSON.stringify(val));
}

def:pub TenantsPropertiesView() -> JsxElement {
    has properties: list = ls_load("rentora_properties");
    has tenants: list = ls_load("rentora_tenants");
    has tab: str = "Properties";
    has show_prop_modal: bool = False;
    has show_tenant_modal: bool = False;

    has form_prop_name: str = "";
    has form_prop_address: str = "";
    has form_tenant_name: str = "";
    has form_tenant_phone: str = "";
    has form_tenant_unit: str = "";
    has form_tenant_prop_id: str = "";
    has form_tenant_rent: str = "1200";

    def reload() -> None {
        properties = ls_load("rentora_properties");
        tenants = ls_load("rentora_tenants");
    }

    async def save_property() -> None {
        if not form_prop_name { return; }
        p = {"id": "P-" + str(Date.now()), "property_name": form_prop_name, "street_address": form_prop_address};
        all_p = ls_load("rentora_properties");
        all_p.append(p);
        ls_save("rentora_properties", all_p);
        show_prop_modal = False;
        form_prop_name = "";
        form_prop_address = "";
        reload();
        # Sync to graph for triage pipeline
        try { root spawn add_property_node(name=p["property_name"], address=p["street_address"]); } except Exception {}
    }

    async def delete_property(p_id: str) -> None {
        if window.confirm("Delete this property and its tenants?") {
            ls_save("rentora_properties", [p for p in ls_load("rentora_properties") if p["id"] != p_id]);
            ls_save("rentora_tenants", [t for t in ls_load("rentora_tenants") if t["property_id"] != p_id]);
            reload();
        }
    }

    async def save_tenant() -> None {
        if not form_tenant_name or not form_tenant_phone or not form_tenant_unit { return; }
        prop_name = "";
        for p in ls_load("rentora_properties") {
            if p["id"] == form_tenant_prop_id { prop_name = p["property_name"]; break; }
        }
        t = {
            "id": "T-" + str(Date.now()),
            "full_name": form_tenant_name,
            "phone_number": form_tenant_phone,
            "unit_number": form_tenant_unit,
            "property_id": form_tenant_prop_id,
            "property_name": prop_name,
            "rent": form_tenant_rent
        };
        all_t = ls_load("rentora_tenants");
        all_t.append(t);
        ls_save("rentora_tenants", all_t);
        show_tenant_modal = False;
        form_tenant_name = "";
        form_tenant_phone = "";
        form_tenant_unit = "";
        form_tenant_prop_id = "";
        form_tenant_rent = "1200";
        reload();
        # Sync to graph for triage phone matching
        try {
            rent_f = 0.0;
            try { rent_f = float(t["rent"]); } except Exception {}
            root spawn register_tenant(
                tenant_name=t["full_name"],
                tenant_phone=t["phone_number"],
                unit_number=t["unit_number"],
                rent_amount=rent_f,
                lease_start="2025-01-01",
                lease_end="2026-12-31",
                property_name=prop_name
            );
        } except Exception {}
    }

    async def delete_tenant(t_id: str) -> None {
        if window.confirm("Remove this tenant?") {
            ls_save("rentora_tenants", [t for t in ls_load("rentora_tenants") if t["id"] != t_id]);
            reload();
        }
    }

    return (
        <div className="p-8 max-w-5xl mx-auto h-full overflow-y-auto">
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-2xl font-semibold text-slate-900 tracking-tight">Tenants & Properties</h1>
                    <p className="text-sm text-slate-500 mt-1">Saved locally. Tenants are synced to the AI pipeline for automatic SMS matching.</p>
                </div>
                <div className="flex gap-3">
                    <button onClick={lambda -> None { form_prop_name = ""; form_prop_address = ""; show_prop_modal = True; }} className="bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-50 transition">
                        Add Property
                    </button>
                    <button onClick={lambda -> None { form_tenant_name = ""; form_tenant_phone = ""; form_tenant_unit = ""; form_tenant_prop_id = (properties[0]["id"] if len(properties) > 0 else ""); show_tenant_modal = True; }} className="bg-slate-900 text-white px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-800 transition">
                        Add Tenant
                    </button>
                </div>
            </div>

            <div className="flex gap-6 border-b border-slate-200 mb-6">
                <button onClick={lambda -> None { tab = "Properties"; }} className={"pb-3 text-sm font-medium transition-colors border-b-2 " + (tab == "Properties" and "border-slate-900 text-slate-900" or "border-transparent text-slate-500 hover:text-slate-700")}>
                    Properties ({len(properties)})
                </button>
                <button onClick={lambda -> None { tab = "Tenants"; }} className={"pb-3 text-sm font-medium transition-colors border-b-2 " + (tab == "Tenants" and "border-slate-900 text-slate-900" or "border-transparent text-slate-500 hover:text-slate-700")}>
                    Tenants ({len(tenants)})
                </button>
            </div>

            {tab == "Properties" and (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    {len(properties) == 0 and (
                        <div className="col-span-full bg-slate-50 border border-dashed border-slate-300 rounded-xl p-12 flex flex-col items-center justify-center text-center">
                            <h3 className="text-slate-900 font-medium mb-1">No properties yet</h3>
                            <p className="text-slate-500 text-sm mb-4">Add your first property to start managing tenants.</p>
                            <button onClick={lambda -> None { form_prop_name = ""; form_prop_address = ""; show_prop_modal = True; }} className="text-sm font-medium text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">Add Property</button>
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
                                <h3 className="font-semibold text-slate-900 pr-8 mb-2">{p["property_name"]}</h3>
                                <p className="text-sm text-slate-500 mb-6">{p["street_address"] if p["street_address"] else "No address"}</p>
                                <div className="mt-auto pt-4 border-t border-slate-100 flex justify-between items-center text-xs font-medium text-slate-600">
                                    <span>{t_count} {t_count == 1 and "Tenant" or "Tenants"}</span>
                                    <button onClick={lambda -> None { tab = "Tenants"; }} className="text-slate-500 hover:text-slate-900">View &rarr;</button>
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}

            {tab == "Tenants" and (
                <div className={panel_classes() + " overflow-hidden"}>
                    {len(tenants) == 0 and (
                        <div className="p-12 text-center flex flex-col items-center bg-slate-50 m-2 rounded-lg border border-dashed border-slate-200">
                            <h3 className="text-slate-900 font-medium mb-1">No tenants yet</h3>
                            <p className="text-slate-500 text-sm mb-4">Add a tenant to enable automatic SMS matching.</p>
                            <button onClick={lambda -> None { form_tenant_name = ""; form_tenant_phone = ""; form_tenant_unit = ""; form_tenant_prop_id = (properties[0]["id"] if len(properties) > 0 else ""); show_tenant_modal = True; }} className="text-sm font-medium text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">Add Tenant</button>
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
                                                        {t["full_name"][0].upper() if t["full_name"] else "?"}
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
                            <button onClick={lambda -> None { show_prop_modal = False; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
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
                                <p className="text-[10px] text-slate-400 mt-1">Must match the number they text from. Use +1 format.</p>
                            </div>
                            <div className="flex gap-3">
                                <div className="flex-1">
                                    <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Unit</label>
                                    <input value={form_tenant_unit} onChange={lambda e: any -> None { form_tenant_unit = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 font-mono transition-shadow" placeholder="1A" />
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
                                        return <option key={p["id"]} value={p["id"]}>{p["property_name"]}</option>;
                                    })}
                                </select>
                            </div>
                        </div>
                        <div className="mt-6 flex gap-3 justify-end">
                            <button onClick={lambda -> None { show_tenant_modal = False; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
                            <button onClick={save_tenant} disabled={not form_tenant_name or not form_tenant_phone or not form_tenant_unit} className="px-4 py-2 rounded-md text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 transition disabled:opacity-50">Save Tenant</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
