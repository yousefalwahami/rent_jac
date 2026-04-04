cl import from shared { IncidentRecord, panel_classes, incident_row, category_dot, empty_state, nav_button_classes }

def:pub incidents_view(incidents: list, selected: any, set_selected: any, search: str, set_search: any, urgency_filter: str, set_urgency: any, category_filter: str, set_category: any) -> JsxElement {
    
    def filtered_incidents() -> list {
        res = [];
        for item in incidents {
            if (search.lower() in item.tenant.lower() or search.lower() in item.id.lower() or search.lower() in item.property.lower()) {
                if (urgency_filter == "All" or item.urgency == urgency_filter) {
                    if (category_filter == "All" or item.category == category_filter) {
                        res.append(item);
                    }
                }
            }
        }
        return res;
    }

    filtered = filtered_incidents();

    return (
        <div className="flex w-full flex-col p-8 bg-slate-50 min-h-full">
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-semibold tracking-tight text-slate-900 mb-2">Active Incidents</h1>
                    <p className="text-base text-slate-500 max-w-2xl">
                        Triage and monitor all incoming SMS issues in real-time.
                    </p>
                </div>
            </div>

            <div className="grid grid-cols-[1.5fr_1fr] gap-6 flex-1">
                {/* Left Stream: Feed and Filters */}
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 overflow-hidden shadow-sm"}>
                    <div className="p-4 border-b border-slate-100 bg-slate-50/50 grid grid-cols-3 gap-3">
                        <input
                            type="text"
                            placeholder="Search tenants or units..."
                            value={search}
                            onChange={lambda e: any -> None { set_search(e.target.value); }}
                            className="w-full text-sm border-slate-200 rounded-md focus:border-indigo-500 focus:ring-indigo-500 shadow-sm"
                        />
                        <select value={urgency_filter} onChange={lambda e: any -> None { set_urgency(e.target.value); }} className="text-sm border-slate-200 rounded-md focus:border-indigo-500 focus:ring-indigo-500 shadow-sm">
                            <option value="All">All Urgencies</option>
                            <option value="Critical">Critical</option>
                            <option value="High">High</option>
                            <option value="Medium">Medium</option>
                            <option value="Low">Low</option>
                        </select>
                        <select value={category_filter} onChange={lambda e: any -> None { set_category(e.target.value); }} className="text-sm border-slate-200 rounded-md focus:border-indigo-500 focus:ring-indigo-500 shadow-sm">
                            <option value="All">All Categories</option>
                            <option value="Plumbing">Plumbing</option>
                            <option value="Electrical">Electrical</option>
                            <option value="HVAC">HVAC</option>
                            <option value="Noise">Noise</option>
                            <option value="Safety">Safety</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    
                    <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-slate-50/30">
                        {len(filtered) == 0 and empty_state("No incidents match criteria", "Adjust your filters or wait for a new inbound Twilio message.", False) or filtered.map(lambda incident: IncidentRecord -> JsxElement {
                            return incident_row(incident, selected != None and incident.id == selected.id, lambda -> None { set_selected(incident); });
                        })}
                    </div>
                </div>

                {/* Right Panel: Incident Master Detail */}
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 overflow-hidden shadow-sm"}>
                    {selected == None and (
                        <div className="flex flex-col items-center justify-center h-full p-16 text-center bg-slate-50/50">
                            <div className="w-12 h-12 rounded-full border border-slate-200 bg-slate-100 flex items-center justify-center mb-4">
                                <svg className="w-5 h-5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                            </div>
                            <h3 className="text-sm font-semibold text-slate-900">No Target Selected</h3>
                            <p className="mt-1 text-sm text-slate-500 max-w-xs">Select an incident from the queue to view full SMS threads and AI triage history.</p>
                        </div>
                    ) or (
                        <div>
                            <div className="px-6 py-5 border-b border-slate-100 bg-slate-50/50">
                                <div className="flex justify-between items-start">
                                    <div className="flex items-center gap-3">
                                        <span className={"w-2 h-2 rounded-full " + category_dot(selected.category)}></span>
                                        <div>
                                            <h3 className="text-base font-semibold text-slate-900">{selected.property}, Unit {selected.unit}</h3>
                                            <p className="text-xs text-slate-500 mt-0.5">Tenant: {selected.tenant} · {selected.phone}</p>
                                        </div>
                                    </div>
                                    <div className="text-right">
                                        <span className="text-xs font-mono text-slate-400 block mb-1">{selected.id}</span>
                                        <button className="text-xs font-medium text-indigo-600 bg-indigo-50 border border-indigo-100 px-2 py-1 rounded hover:bg-indigo-100 transition">Contact Owner</button>
                                    </div>
                                </div>
                            </div>
                            <div className="p-6">
                                <p className="text-xs uppercase font-semibold tracking-wider text-slate-500 mb-3">Inbound Summary</p>
                                <div className="bg-slate-900 text-slate-300 p-4 rounded-lg font-mono text-sm leading-relaxed mb-6 whitespace-pre-wrap">
                                    {selected.message}
                                </div>
                                
                                <p className="text-xs uppercase font-semibold tracking-wider text-slate-500 mb-3">Escalation Status</p>
                                <div className="flex items-center gap-3 bg-rose-50 border border-red-100 px-4 py-3 rounded-lg text-sm text-rose-900">
                                    <div className="w-2 h-2 rounded-full bg-red-400 animate-pulse"></div>
                                    Waiting for Owner Response
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
