cl import from shared { IncidentRecord, metric_card, panel_classes, incident_row }

def:pub dashboard_view(incidents: list, selected: IncidentRecord, set_selected: any) -> JsxElement {
    return (
        <div className="flex w-full flex-col p-8 bg-slate-50 min-h-full">
            
            <div className="mb-8">
                <h1 className="text-2xl font-semibold tracking-tight text-slate-900 mb-2">Platform Overview</h1>
                <p className="text-base text-slate-500 max-w-2xl">
                    Real-time property operations and automated incident triage. Monitor portfolio health, response times, and AI workflow performance entirely on inbound SMS.
                </p>
            </div>

            
            <div className="grid grid-cols-4 gap-4 mb-8">
                {metric_card("Active Incidents", "142", "+12% wk", "Since Monday")}
                {metric_card("Urgent Issues", "3", "Critical", "Requires manual intervention")}
                {metric_card("Avg. Assign Time", "1.4m", "-40% ms", "SLA: 15m")}
                {metric_card("AI Resolutions", "94.2%", "+2.1% wk", "Fully automated handling")}
            </div>

            
            <div className="grid grid-cols-[1.5fr_1fr] gap-6 flex-1 min-h-[600px]">
                
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 overflow-hidden shadow-sm"}>
                    <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
                        <div className="flex items-center gap-2">
                            <h3 className="text-sm font-semibold tracking-tight text-slate-900">Incident Stream</h3>
                            <span className="bg-slate-100 text-slate-600 text-xs px-2 py-0.5 rounded-full border border-slate-200 font-medium">Live Network</span>
                        </div>
                        <button className="text-xs font-medium text-slate-500 hover:text-slate-900 transition-colors">View all →</button>
                    </div>
                    
                    <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-slate-50/30">
                        {incidents.map(lambda incident: IncidentRecord -> JsxElement {
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
                            <h3 className="text-sm font-medium tracking-tight text-white">System Pipeline</h3>
                        </div>
                        <div className="text-[10px] uppercase tracking-wider font-mono text-slate-500">v2.4.0-stable</div>
                    </div>

                    <div className="flex-1 p-5 overflow-y-auto space-y-6 relative z-10">
                        
                        <div className="relative pl-6">
                            <div className="absolute left-0 top-1.5 w-2 h-2 rounded-full border-2 border-indigo-400 bg-slate-900 z-10"></div>
                            <div className="absolute left-[3px] top-4 w-[2px] h-full bg-slate-800"></div>
                            <div className="flex justify-between items-center mb-1">
                                <span className="text-xs uppercase tracking-wider font-semibold text-indigo-400">Webhook Intake</span>
                                <span className="text-xs font-mono text-slate-500">10:42:01.034ms</span>
                            </div>
                            <div className="p-3 bg-slate-800/50 rounded border border-slate-700/50 mt-2 font-mono text-xs text-slate-400 break-words hover:border-slate-600 transition-colors">
                                POST /api/v1/tel/inbound<br/>
                                {"{\n  \"From\": \"+15551234567\",\n  \"Body\": \"Water is leaking from the upstairs ceiling into my living room.\",\n  \"To\": \"+15559876543\"\n}"}
                            </div>
                        </div>

                        
                        <div className="relative pl-6">
                            <div className="absolute left-0 top-1.5 w-2 h-2 rounded-full border-2 border-emerald-400 bg-slate-900 z-10"></div>
                            <div className="absolute left-[3px] top-4 w-[2px] h-full bg-slate-800"></div>
                            <div className="flex justify-between items-center mb-1">
                                <span className="text-xs uppercase tracking-wider font-semibold text-emerald-400">AI Parser</span>
                                <span className="text-xs font-mono text-slate-500">10:42:01.402ms</span>
                            </div>
                            <div className="p-3 bg-slate-800/50 rounded border border-slate-700/50 mt-2 font-mono text-xs text-slate-400 transition-colors flex flex-col gap-1">
                                <span className="text-white">Classification: <span className="text-red-400">MAINTENANCE_URGENT</span></span>
                                <span className="text-white">Extracted Issue: <span className="text-emerald-300">Ceiling Leak</span></span>
                                <span className="text-white">Tenant ID: <span className="text-slate-400">TNT-9082</span></span>
                            </div>
                        </div>

                        
                        <div className="relative pl-6">
                            <div className="absolute left-0 top-1.5 w-2 h-2 rounded-full border-2 border-amber-400 bg-slate-900 shadow-[0_0_8px_rgba(251,191,36,0.6)] animate-pulse z-10"></div>
                            <div className="flex justify-between items-center mb-1">
                                <span className="text-xs uppercase tracking-wider font-semibold text-amber-400">Dispatch Queue</span>
                                <span className="text-xs font-mono text-slate-500">Processing...</span>
                            </div>
                            <div className="p-3 mt-2 font-mono text-xs text-slate-400 flex items-center gap-3">
                                <svg className="w-4 h-4 animate-spin text-amber-400" viewBox="0 0 24 24" fill="none">
                                    <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" className="opacity-25"></circle>
                                    <path d="M4 12a8 8 0 018-8v8H4z" fill="currentColor" className="opacity-75"></path>
                                </svg>
                                Identifying closest vendor matching skill: Plumbing
                            </div>
                        </div>
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
