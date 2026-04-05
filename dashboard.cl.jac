cl import from shared { IncidentRecord, panel_classes, incident_row, empty_state }

def:pub dashboard_view(incidents: list, selected: IncidentRecord, set_selected: any, delete_incident: any = None) -> JsxElement {
    if len(incidents) == 0 {
        return (
            <div className="flex w-full flex-col p-10 bg-slate-50 min-h-full font-sans">
                <div className="mb-10">
                    <h1 className="text-3xl font-medium tracking-tight text-slate-900 mb-1">Overview</h1>
                    <p className="text-sm text-slate-500 max-w-2xl font-mono tracking-tight">
                        Inbound SMS and active AI triage.
                    </p>
                </div>
                <div className="grid grid-cols-[1fr_400px] gap-8 flex-1">
                    <div className="flex flex-col bg-white rounded-md border border-slate-200 shadow-sm">
                        <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                                <h3 className="text-sm font-medium tracking-tight text-slate-900">Live Incident Feed</h3>
                            </div>
                            <span className="text-[10px] font-mono uppercase tracking-widest text-slate-400">Activity Stream</span>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-2 bg-slate-50/50 min-h-[400px]">
                            {empty_state("Waiting for live data", "The incident feed is empty. No SMS messages have been received by the Twilio webhook yet.", True)}
                        </div>
                    </div>
                    <div className="flex flex-col bg-slate-900 text-slate-300 rounded-md shadow-sm border border-slate-800">
                        <div className="px-6 py-5 border-b border-slate-800 flex items-center justify-between bg-slate-900 z-10">
                            <h3 className="text-sm font-medium tracking-tight text-white">Pending AI Runs</h3>
                            <div className="text-[10px] uppercase tracking-widest font-mono text-slate-500">Queue</div>
                        </div>
                        <div className="flex-1 p-6 relative z-10 flex flex-col items-center justify-center min-h-[400px]">
                            <div className="flex flex-col items-center opacity-60">
                                <svg className="w-8 h-8 text-slate-500 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                                <p className="text-slate-400 text-xs font-mono text-center tracking-tight">System idle.</p>
                                <p className="text-slate-500 text-xs mt-1 text-center">Awaiting initial Twilio payload.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
    
    selected_cat = incidents[0].category;
    if selected != None {
        selected_cat = selected.category;
    }

    return (
        <div className="flex w-full flex-col p-10 bg-slate-50 min-h-full font-sans">
            <div className="mb-10">
                <h1 className="text-3xl font-medium tracking-tight text-slate-900 mb-1">Overview</h1>
                <p className="text-sm text-slate-500 max-w-2xl font-mono tracking-tight">
                    Inbound SMS and active AI triage.
                </p>
            </div>
            <div className="grid grid-cols-[1fr_400px] gap-8 flex-1">
                <div className="flex flex-col bg-white rounded-md border border-slate-200 shadow-sm">
                    <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></div>
                            <h3 className="text-sm font-medium tracking-tight text-slate-900">Live Incident Feed</h3>
                        </div>
                        <span className="text-[10px] font-mono uppercase tracking-widest text-slate-400">Activity Stream</span>
                    </div>
                    <div className="flex-1 overflow-y-auto p-4 space-y-2 bg-slate-50/50 min-h-[400px]">
                        {incidents.map(lambda incident: IncidentRecord -> JsxElement {
                            return incident_row(incident, selected != None and incident.id == selected.id, lambda -> None { set_selected(incident); }, delete_incident);
                        })}
                    </div>
                </div>
                <div className="flex flex-col bg-slate-900 text-slate-300 rounded-md shadow-sm border border-slate-800">
                    <div className="px-6 py-5 border-b border-slate-800 flex items-center justify-between bg-slate-900 z-10">
                        <h3 className="text-sm font-medium tracking-tight text-white">Pending AI Runs</h3>
                        <div className="text-[10px] uppercase tracking-widest font-mono text-slate-500">Queue</div>
                    </div>
                    <div className="flex-1 p-6 relative z-10 flex flex-col items-center justify-center min-h-[400px]">
                        <div className="w-full flex-col flex gap-4 h-full pt-2">
                            <div className="rounded border border-slate-700 bg-slate-800/50 p-4">
                                <p className="text-xs font-mono text-slate-400 uppercase tracking-widest mb-2">Processing Thread</p>
                                <p className="text-sm text-white font-medium truncate">{selected_cat}</p>
                                <div className="w-full bg-slate-700 h-1 mt-4 rounded overflow-hidden">
                                    <div className="bg-emerald-500 h-full w-[65%] animate-pulse"></div>
                                </div>
                                <p className="text-[10px] text-slate-500 mt-2 text-right">Drafting response...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
