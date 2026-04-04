cl import from shared { IncidentRecord, metric_card, panel_classes, incident_row, empty_state }

def:pub dashboard_view(incidents: list, selected: IncidentRecord, set_selected: any) -> JsxElement {
    return (
        <div className="flex w-full flex-col p-8 bg-slate-50 min-h-full">
            
            <div className="mb-8">
                <h1 className="text-2xl font-semibold tracking-tight text-slate-900 mb-2">Operations Dashboard</h1>
                <p className="text-base text-slate-500 max-w-2xl">
                    Live system state. Monitor automated triage, active incidents, and inbound SMS event pipelines.
                </p>
            </div>

            
            <div className="grid grid-cols-4 gap-4 mb-8">
                {metric_card("Live Incidents", str(len(incidents)), "-", "Active SMS threads")}
                {metric_card("Pending AI", "0", "-", "Processing queue empty")}
                {metric_card("Delivery Health", "100%", "OK", "Webhook latency < 50ms")}
                {metric_card("System Status", "OK", "Online", "All systems operational")}
            </div>

            
            <div className="grid grid-cols-[1.5fr_1fr] gap-6 flex-1 min-h-[600px]">
                
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 overflow-hidden shadow-sm"}>
                    <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
                        <div className="flex items-center gap-2">
                            <h3 className="text-sm font-semibold tracking-tight text-slate-900">Live Incident Feed</h3>
                            <span className="bg-slate-100 text-slate-600 text-xs px-2 py-0.5 rounded-full border border-slate-200 font-medium">Production</span>
                        </div>
                    </div>
                    
                    <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-slate-50/30">
                        {len(incidents) == 0 and empty_state("Waiting for live data", "The incident feed is empty. No SMS messages have been received by the Twilio webhook yet.", True) or incidents.map(lambda incident: IncidentRecord -> JsxElement {
                            return incident_row(incident, selected != None and incident.id == selected.id, lambda -> None { set_selected(incident); });
                        })}
                    </div>
                </div>

                
                <div className={"flex flex-col bg-slate-900 text-slate-300 rounded-lg shadow-sm border border-slate-800 overflow-hidden relative"}>
                    <div className="absolute top-0 right-0 p-4 opacity-10 pointer-events-none">
                        <svg className="w-48 h-48" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M100 200C155.228 200 200 155.228 200 100C200 44.7715 155.228 0 100 0C44.7715 0 0 44.7715 0 100C0 155.228 44.7715 200 100 200ZM100 190C149.706 190 190 149.706 190 100C190 50.2944 149.706 10 100 10C50.2944 10 10 50.2944 10 100C10 149.706 50.2944 190 100 190Z" fill="currentColor"/>
                        </svg>
                    </div>

                    <div className="px-5 py-4 border-b border-slate-800 flex items-center justify-between relative z-10 bg-slate-900/50 backdrop-blur-sm">
                        <div className="flex items-center gap-3">
                            <div className="w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_rgba(52,211,153,0.8)] animate-pulse"></div>
                            <h3 className="text-sm font-medium tracking-tight text-white">Event Stream</h3>
                        </div>
                        <div className="text-[10px] uppercase tracking-wider font-mono text-slate-500">AWAITING WEBHOOK</div>
                    </div>

                    <div className="flex-1 p-5 relative z-10 flex flex-col justify-center items-center">
                        <svg className="w-8 h-8 text-slate-700 mb-4 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                        </svg>
                        <p className="text-slate-400 text-sm font-mono text-center">Listening for /api/v1/tel/inbound...</p>
                        <p className="text-slate-600 text-xs mt-2 text-center max-w-[200px]">System is online. Live logs will appear here when tenants text the platform.</p>
                    </div>
                    
                    
                    <div className="border-t border-slate-800 px-4 py-2 flex items-center justify-between text-xs font-mono text-slate-500 bg-slate-900/80">
                        <span>TCP: connected</span>
                        <span>Uptime: 99.98%</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
