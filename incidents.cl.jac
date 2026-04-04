cl import from shared { IncidentRecord, panel_classes, incident_row, timeline_step }

def:pub incidents_view(incidents: list, selected: IncidentRecord, set_selected: any, search: str, set_search: any, urgency_filter: str, set_urgency: any, category_filter: str, set_category: any) -> JsxElement {
    filtered = [
        item for item in incidents
        if ((search == "") or (search.lower() in item.tenant.lower()) or (search.lower() in item.property.lower()) or (search.lower() in item.unit.lower()) or (search.lower() in item.category.lower()))
        and ((urgency_filter == "All") or (item.urgency == urgency_filter))
        and ((category_filter == "All") or (item.category == category_filter))
    ];

    return (
        <div className="grid grid-cols-[1.3fr_0.9fr] gap-6">
            <div className={panel_classes() + " p-6"}>
                <div className="flex items-start justify-between gap-4">
                    <div>
                        <p className="text-sm font-semibold text-slate-500">Incident operations</p>
                        <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">All incidents</h1>
                    </div>
                    <div className="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600">{len(filtered)} visible</div>
                </div>
                <div className="mt-6 grid grid-cols-[1.4fr_0.8fr_0.8fr] gap-3">
                    <input value={search} onChange={lambda e: any -> None { set_search(e.target.value); }} placeholder="Search tenant, property, unit, or category" className="h-12 rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-blue-400 focus:bg-white" />
                    <select value={urgency_filter} onChange={lambda e: any -> None { set_urgency(e.target.value); }} className="h-12 rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-blue-400 focus:bg-white">
                        <option value="All">All urgency</option>
                        <option value="Critical">Critical</option>
                        <option value="High">High</option>
                        <option value="Medium">Medium</option>
                        <option value="Low">Low</option>
                    </select>
                    <select value={category_filter} onChange={lambda e: any -> None { set_category(e.target.value); }} className="h-12 rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-blue-400 focus:bg-white">
                        <option value="All">All categories</option>
                        <option value="Electrical">Electrical</option>
                        <option value="Plumbing">Plumbing</option>
                        <option value="HVAC">HVAC</option>
                        <option value="Appliance">Appliance</option>
                        <option value="Noise">Noise</option>
                    </select>
                </div>
                <div className="mt-6 space-y-3">
                    {[incident_row(item, selected.id == item.id, lambda -> None { set_selected(item); }) for item in filtered]}
                </div>
            </div>
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Incident detail</p>
                <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">{selected.id}</h2>
                <div className="mt-5 space-y-4">
                    <div className="rounded-[24px] bg-slate-950 p-5 text-white">
                        <p className="text-xs uppercase tracking-[0.12em] text-white/50">Inbound SMS</p>
                        <p className="mt-3 text-base leading-7">{selected.message}</p>
                    </div>
                </div>
            </div>
        </div>
    );
}
