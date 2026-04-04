cl import from shared { IncidentRecord, panel_classes, urgency_classes, workflow_node }

def:pub ai_activity_view(incidents: list, selected: IncidentRecord, set_selected: any) -> JsxElement {
    return (
        <div className="grid grid-cols-[380px_1fr] gap-6 max-h-[85vh]">
            <div className={"flex flex-col gap-4 overflow-y-auto " + panel_classes() + " p-6"}>
                <div>
                    <h2 className="text-2xl font-bold tracking-tight text-slate-900">{selected.id}</h2>
                    <span className={"mt-2 inline-flex rounded-full px-2.5 py-1 text-xs font-semibold " + urgency_classes(selected.urgency)}>{selected.urgency}</span>
                </div>
                
                <div className="mt-2 rounded-2xl bg-slate-900 p-4 text-white shadow-inner relative">
                    <div className="absolute -left-2 top-4 w-4 h-4 bg-slate-900 rotate-45"></div>
                    <p className="text-[10px] font-semibold tracking-widest text-slate-400 uppercase">Tenant SMS ({selected.category})</p>
                    <p className="mt-2 text-sm leading-relaxed text-slate-100">"{selected.message}"</p>
                </div>

                <div className="mt-2 rounded-xl border border-slate-200 bg-white p-4">
                    <p className="text-[10px] font-semibold tracking-widest text-slate-400 uppercase">AI Summary</p>
                    <p className="mt-2 text-sm leading-relaxed text-slate-700">{selected.summary}</p>
                </div>
                
                <div className="mt-auto pt-4 border-t border-slate-100 flex flex-col gap-2">
                    <p className="text-xs font-semibold text-slate-500 uppercase">Simulate Incident View</p>
                    <select value={selected.id} onChange={lambda e: any -> None { 
                        for item in incidents {
                            if item.id == e.target.value { set_selected(item); }
                        }
                    }} className="w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm font-semibold text-slate-700 outline-none hover:border-slate-300">
                        {[<option key={item.id} value={item.id}>{item.category} - Unit {item.unit}</option> for item in incidents]}
                    </select>
                </div>
            </div>

            <div className={"flex flex-col overflow-hidden relative " + panel_classes()}>
                <div className="absolute inset-0 bg-[radial-gradient(#cbd5e1_1px,transparent_1px)] [background-size:24px_24px] opacity-40"></div>
                
                <div className="relative z-10 flex items-center justify-between p-8 pb-0">
                    <div>
                        <h1 className="text-3xl font-bold tracking-tight text-slate-950 pb-1">Agentic Operations Canvas</h1>
                    </div>
                </div>

                <div className="relative z-10 flex flex-1 items-center justify-center p-8 overflow-x-auto">
                    <div className="flex items-center gap-4 py-8">
                        <div className="flex flex-col gap-2 items-center">
                            {workflow_node("Inbound SMS", "Twilio Received", "complete", False)}
                            <div className="h-4 w-[2px] bg-slate-300"></div>
                            {workflow_node("Target Matcher", "Property line: " + selected.property_code, "complete", False)}
                        </div>

                        <div className="h-[2px] w-6 bg-slate-300"></div>

                        {workflow_node("Context Parser", "Extract intent & meta", "complete", False)}

                        <div className="h-[2px] w-6 bg-slate-300 relative">
                            <div className="absolute -top-4 w-16 left-1/2 -translate-x-1/2 flex items-center justify-center"><div className="bg-slate-100 rounded-full px-2 py-0.5 text-[9px] font-bold text-slate-500 uppercase">Spawn</div></div>
                        </div>

                        {workflow_node("Action Planner", "Generate response logic", selected.status == "Resolved" and "complete" or "running", selected.status != "Resolved")}

                        <div className="h-[2px] w-6 bg-slate-300"></div>

                        <div className="flex flex-col gap-4 w-56">
                            <div className={"rounded-2xl p-4 border shadow-sm " + (selected.status == "Resolved" and "border-emerald-200 bg-emerald-50" or "border-white bg-white")}>
                                <p className="text-[10px] uppercase tracking-wide font-bold text-slate-400">Yield: Owner Alert</p>
                                <p className="mt-1 text-xs text-slate-800 line-clamp-3 leading-relaxed">{selected.owner_notification}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
