import from "@jac/runtime" { __doFuncFetch }
cl import from shared { panel_classes }

def:pub TenantsPropertiesView() -> JsxElement {
    has properties: list = [];
    has tenants: list = [];
    has loading: bool = False;
    has tab: str = "Properties";
    has show_prop_modal: bool = False;
    has show_tenant_modal: bool = False;
    has initial_load: bool = False;

    has form_prop_id: str = "";
    has form_prop_name: str = "";
    has form_prop_address: str = "";
    has form_tenant_id: str = "";
    has form_tenant_name: str = "";
    has form_tenant_phone: str = "";
    has form_tenant_prop_id: str = "";

    async def load_data() -> None {
        loading = True;
        try {
            res_p = await __doFuncFetch("get_properties", {});
            res_t = await __doFuncFetch("get_tenants", {});
            
            p_list = [];
            if res_p and "properties" in res_p { p_list = res_p["properties"]; }
            elif res_p and "data" in res_p and res_p["data"] and "result" in res_p["data"] and res_p["data"]["result"] and "properties" in res_p["data"]["result"] { p_list = res_p["data"]["result"]["properties"]; }
            
            t_list = [];
            if res_t and "tenants" in res_t { t_list = res_t["tenants"]; }
            elif res_t and "data" in res_t and res_t["data"] and "result" in res_t["data"] and res_t["data"]["result"] and "tenants" in res_t["data"]["result"] { t_list = res_t["data"]["result"]["tenants"]; }
            
            properties = p_list if p_list else [];
            tenants = t_list if t_list else [];
        } except Exception as e {
            console.error(e);
        }
        loading = False;
    }

    if not initial_load {
        initial_load = True;
        setTimeout(load_data, 100);
    }

    async def save_property() -> None {
        if form_prop_id {
            await __doFuncFetch("update_property", {"prop": {"id": form_prop_id, "property_name": form_prop_name, "street_address": form_prop_address}});
        } else {
            await __doFuncFetch("add_property", {"prop": {"property_name": form_prop_name, "street_address": form_prop_address}});
        }
        show_prop_modal = False;
        form_prop_id = "";
        form_prop_name = "";
        form_prop_address = "";
        await load_data();
    }

    async def delete_property(p_id: str) -> None {
        if window.confirm("Are you sure you want to delete this property?") {
            await __doFuncFetch("delete_property", {"prop_id": p_id});
            await load_data();
        }
    }

    def edit_property(p: dict) -> None {
        form_prop_id = p["id"];
        form_prop_name = p["property_name"];
        form_prop_address = p["street_address"];
        show_prop_modal = True;
    }

    async def save_tenant() -> None {
        if form_tenant_id {
            await __doFuncFetch("update_tenant", {"tenant": {"id": form_tenant_id, "full_name": form_tenant_name, "phone_number": form_tenant_phone, "property_id": form_tenant_prop_id}});
        } else {
            await __doFuncFetch("add_tenant", {"tenant": {"full_name": form_tenant_name, "phone_number": form_tenant_phone, "property_id": form_tenant_prop_id}});
        }
        show_tenant_modal = False;
        form_tenant_id = "";
        form_tenant_name = "";
        form_tenant_phone = "";
        form_tenant_prop_id = "";
        await load_data();
    }

    async def delete_tenant(t_id: str) -> None {
        if window.confirm("Are you sure you want to delete this tenant?") {
            await __doFuncFetch("delete_tenant", {"tenant_id": t_id});
            await load_data();
        }
    }

    def edit_tenant(t: dict) -> None {
        form_tenant_id = t["id"];
        form_tenant_name = t["full_name"];
        form_tenant_phone = t["phone_number"];
        form_tenant_prop_id = t["property_id"];
        show_tenant_modal = True;
    }

    def get_prop_name(prop_id: str) -> str {
        for p in properties {
            if p["id"] == prop_id {
                return p["property_name"];
            }
        }
        return "Unknown Property";
    }

    return (
        <div className="p-8 max-w-5xl mx-auto h-full overflow-y-auto">
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-2xl font-semibold text-slate-900 tracking-tight">Tenants & Properties</h1>
                    <p className="text-sm text-slate-500 mt-1">Manage your portfolio to automatically match incoming SMS.</p>
                </div>
                <div className="flex gap-3">
                    <button onClick={lambda -> None { form_prop_id = ""; form_prop_name = ""; form_prop_address = ""; show_prop_modal = True; }} className="bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-50 transition">
                        Add Property
                    </button>
                    <button onClick={lambda -> None { form_tenant_id = ""; form_tenant_name = ""; form_tenant_phone = ""; form_tenant_prop_id = ""; show_tenant_modal = True; }} className="bg-slate-900 text-white px-4 py-2 rounded-md shadow-sm text-sm font-medium hover:bg-slate-800 transition">
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

            {loading and <div className="p-12 text-center text-slate-500">Loading...</div>}

            {tab == "Properties" and not loading and (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    {len(properties) == 0 and (
                        <div className="col-span-full bg-slate-50 border border-dashed border-slate-300 rounded-xl p-12 flex flex-col items-center justify-center text-center">
                            <h3 className="text-slate-900 font-medium mb-1">No properties yet</h3>
                            <p className="text-slate-500 text-sm mb-4">Add your first property to start matching inbound tenant messages.</p>
                            <button onClick={lambda -> None { form_prop_id = ""; form_prop_name = ""; form_prop_address = ""; show_prop_modal = True; }} className="text-sm font-medium tracking-tight text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">
                                Add Property
                            </button>
                        </div>
                    )}
                    {properties.map(lambda p: any -> JsxElement {
                        t_count = 0;
                        for t in tenants {
                            if t["property_id"] == p["id"] {
                                t_count += 1;
                            }
                        }
                        return (
                            <div key={p["id"]} className={panel_classes() + " p-5 flex flex-col transition hover:border-slate-300 relative group"}>
                                <div className="absolute top-4 right-4 flex opacity-0 group-hover:opacity-100 transition-opacity gap-1">
                                    <button onClick={lambda -> None { edit_property(p); }} className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded" title="Edit">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    </button>
                                    <button onClick={lambda -> None { delete_property(p["id"]); }} className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded" title="Delete">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                    </button>
                                </div>
                                <div className="flex items-start justify-between mb-3 pr-10">
                                    <h3 className="font-semibold text-slate-900 leading-tight">{p["property_name"]}</h3>
                                </div>
                                <span className="text-[10px] bg-slate-100 text-slate-600 font-mono px-2 py-1 rounded tracking-wider w-fit mb-3">{p["id"]}</span>
                                <p className="text-sm text-slate-500 mb-6">{p["street_address"]}</p>
                                <div className="mt-auto pt-4 border-t border-slate-100 flex justify-between items-center text-xs font-medium text-slate-600">
                                    <span>{t_count} {t_count == 1 and "Tenant" or "Tenants"}</span>
                                    <button onClick={lambda -> None { tab = "Tenants"; }} className="text-slate-500 hover:text-slate-900">View &rarr;</button>
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}

            {tab == "Tenants" and not loading and (
                <div className={panel_classes() + " overflow-hidden"}>
                    {len(tenants) == 0 and (
                        <div className="p-12 text-center flex flex-col items-center justify-center bg-slate-50 m-2 rounded-lg border border-dashed border-slate-200">
                            <h3 className="text-slate-900 font-medium mb-1">No tenants saved</h3>
                            <p className="text-slate-500 text-sm mb-4">Add a tenant linked to a property to enable SMS matching from Twilio.</p>
                            <button onClick={lambda -> None { form_tenant_id = ""; form_tenant_name = ""; form_tenant_phone = ""; form_tenant_prop_id = ""; show_tenant_modal = True; }} className="text-sm font-medium tracking-tight text-slate-900 bg-white border border-slate-200 px-4 py-2 rounded-md shadow-sm">
                                Add Tenant
                            </button>
                        </div>
                    )}
                    {len(tenants) > 0 and (
                        <table className="w-full text-left text-sm whitespace-nowrap">
                            <thead className="bg-slate-50 text-slate-500">
                                <tr className="border-b border-slate-200">
                                    <th className="px-6 py-3 font-medium">Tenant Name</th>
                                    <th className="px-6 py-3 font-medium">Phone Number</th>
                                    <th className="px-6 py-3 font-medium">Property</th>
                                    <th className="px-6 py-3 font-medium text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {tenants.map(lambda t: any -> JsxElement {
                                    return (
                                        <tr key={t["id"]} className="hover:bg-slate-50/50 transition-colors group">
                                            <td className="px-6 py-4 font-medium text-slate-900 flex items-center gap-3">
                                                <div className="w-6 h-6 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center text-xs">
                                                    {str(t["full_name"])[0] if len(str(t["full_name"])) > 0 else "?"}
                                                </div>
                                                {t["full_name"]}
                                            </td>
                                            <td className="px-6 py-4 font-mono text-slate-500 text-xs">{t["phone_number"]}</td>
                                            <td className="px-6 py-4">
                                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-slate-100 border border-slate-200 text-xs text-slate-600 font-medium">
                                                    {get_prop_name(t["property_id"])}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                    <button onClick={lambda -> None { edit_tenant(t); }} className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded" title="Edit">
                                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                    </button>
                                                    <button onClick={lambda -> None { delete_tenant(t["id"]); }} className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded" title="Delete">
                                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                    </button>
                                                </div>
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
                        <h2 className="text-lg font-semibold text-slate-900 mb-5">{form_prop_id and "Edit Property" or "Add New Property"}</h2>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Property Name</label>
                                <input value={form_prop_name} onChange={lambda e: any -> None { form_prop_name = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-slate-900 transition-shadow" placeholder="e.g. Harbor Point Residences" autoFocus={True} />
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Street Address</label>
                                <input value={form_prop_address} onChange={lambda e: any -> None { form_prop_address = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-slate-900 transition-shadow" placeholder="123 Main St" />
                            </div>
                        </div>
                        <div className="mt-8 flex gap-3 justify-end">
                            <button onClick={lambda -> None { show_prop_modal = False; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
                            <button onClick={save_property} className="px-4 py-2 rounded-md text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 transition">Save Property</button>
                        </div>
                    </div>
                </div>
            )}

            {show_tenant_modal and (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className={"w-full max-w-md shadow-xl " + panel_classes() + " p-6"}>
                        <h2 className="text-lg font-semibold text-slate-900 mb-5">{form_tenant_id and "Edit Tenant" or "Add New Tenant"}</h2>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Full Name</label>
                                <input value={form_tenant_name} onChange={lambda e: any -> None { form_tenant_name = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-slate-900 transition-shadow" placeholder="e.g. Maya Chen" autoFocus={True} />
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Phone Number</label>
                                <input value={form_tenant_phone} onChange={lambda e: any -> None { form_tenant_phone = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-slate-900 transition-shadow font-mono" placeholder="+1..." />
                                <p className="text-[10px] text-slate-500 mt-1.5">Required for SMS mapping tracking. Use international format if possible.</p>
                            </div>
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Property Profile</label>
                                <select value={form_tenant_prop_id} onChange={lambda e: any -> None { form_tenant_prop_id = e.target.value; }} className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-slate-900 transition-shadow bg-white pb-2.5">
                                    <option value="">Select Property...</option>
                                    {properties.map(lambda p: any -> JsxElement {
                                        return <option key={p["id"]} value={p["id"]}>{p["property_name"]}</option>;
                                    })}
                                </select>
                            </div>
                        </div>
                        <div className="mt-8 flex gap-3 justify-end">
                            <button onClick={lambda -> None { show_tenant_modal = False; }} className="px-4 py-2 rounded-md font-medium text-slate-600 hover:bg-slate-100 text-sm transition">Cancel</button>
                            <button onClick={save_tenant} className="px-4 py-2 rounded-md text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 transition disabled:opacity-50" disabled={not form_tenant_name or not form_tenant_phone or not form_tenant_prop_id}>Save Tenant</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
