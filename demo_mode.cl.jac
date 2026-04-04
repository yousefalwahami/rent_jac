cl import from shared { panel_classes, empty_state }

def:pub demo_mode_view(
    demo_incidents: list, 
    selected: any, 
    set_selected: any, 
    scenario: str, 
    set_scenario: any, 
    incoming_text: str, 
    set_incoming_text: any, 
    demo_stage: int, 
    set_demo_stage: any
) -> JsxElement {
    
    def generate_demo_scenario() -> None {
        set_demo_stage(1);
    }
    
    def owner_approve_demo() -> None {
        set_demo_stage(2);
    }

    def reset_demo() -> None {
        set_demo_stage(0);
        set_incoming_text("The sink in Unit 4B is leaking and water is getting on the floor.");
        set_scenario("Plumbing");
    }

    return (
        <div className="flex w-full flex-col p-8 bg-slate-50 min-h-full">
            <div className="mb-8 flex justify-between items-end">
                <div>
                    <div className="inline-flex items-center gap-2 rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-indigo-700 mb-4">
                        <span className="h-1.5 w-1.5 rounded-full bg-indigo-600 animate-pulse"></span>
                        Local Simulation Sandbox
                    </div>
                    <h1 className="text-2xl font-semibold tracking-tight text-slate-900 mb-2">Simulate Operations Flow</h1>
                    <p className="text-base text-slate-500 max-w-2xl">
                        Demo Mode is fully isolated from production Twilio data. Inject fake SMS messages here to preview AI parsing, owner alerts, and triage workflow behavior.
                    </p>
                </div>
                <button onClick={reset_demo} className="text-sm font-medium text-slate-500 hover:text-slate-900 border border-slate-200 px-3 py-1.5 rounded-md hover:bg-slate-100 transition">Reset Sandbox</button>
            </div>

            <div className="grid grid-cols-[1fr_1.5fr] gap-6">
                
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 p-6 shadow-sm"}>
                    <h2 className="text-sm font-semibold tracking-tight text-slate-900 mb-6 border-b border-slate-100 pb-4">Mock Injection Rules</h2>
                    
                    <div className="space-y-4">
                        <div>
                            <label className="block text-xs font-medium text-slate-700 mb-1.5">Scenario Type</label>
                            <select 
                                value={scenario}
                                onChange={lambda e: any -> None { set_scenario(e.target.value); }}
                                className="w-full text-sm border-slate-200 rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                            >
                                <option value="Plumbing">Water Leak / Plumbing (High Urgency)</option>
                                <option value="Noise">Noise Complaint (Low Urgency)</option>
                                <option value="Safety">Safety / Smell (Critical)</option>
                            </select>
                        </div>
                        
                        <div>
                            <label className="block text-xs font-medium text-slate-700 mb-1.5">Simulate Tenant SMS</label>
                            <textarea 
                                value={incoming_text}
                                onChange={lambda e: any -> None { set_incoming_text(e.target.value); }}
                                rows={4}
                                className="w-full text-sm border-slate-200 rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 font-mono text-slate-600"
                            ></textarea>
                            <p className="mt-1 text-xs text-slate-400">Values are passed to the AI parser identically to a live Twilio webhook payload.</p>
                        </div>

                        <div className="pt-4 border-t border-slate-100">
                            <button 
                                onClick={generate_demo_scenario}
                                disabled={demo_stage > 0}
                                className={"w-full py-2.5 rounded-md text-sm font-semibold text-white shadow-sm flex items-center justify-center gap-2 " + (demo_stage == 0 and "bg-indigo-600 hover:bg-indigo-700" or "bg-slate-300 cursor-not-allowed")}
                            >
                                {demo_stage == 0 and "Fire Mock Webhook" or "Scenario Running..."}
                            </button>
                        </div>
                    </div>
                </div>

                
                <div className={"flex flex-col bg-white rounded-lg border border-slate-200 overflow-hidden shadow-sm"}>
                    <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
                        <div className="flex items-center gap-2">
                            <h3 className="text-sm font-semibold tracking-tight text-slate-900">Sandbox Processing Output</h3>
                        </div>
                    </div>
                    
                    <div className="flex-1 p-5 overflow-y-auto space-y-6 bg-slate-50/30">
                        {demo_stage == 0 and empty_state("Ready for Simulation", "Configure the mock injection rules and fire the webhook to observe system behavior.", False) or (
                            <div>
                                
                                <div className="border border-slate-200 rounded-lg p-4 bg-white shadow-sm">
                                    <div className="flex items-center gap-3 mb-2">
                                        <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
                                        <p className="text-sm font-semibold text-slate-900">Twilio Payload Received</p>
                                    </div>
                                    <div className="bg-slate-900 text-slate-300 p-3 rounded text-xs font-mono break-all leading-relax mt-3">
                                        “{incoming_text}”
                                    </div>
                                </div>

                                
                                <div className={"border border-slate-200 rounded-lg p-4 bg-white shadow-sm transition-opacity duration-500 " + (demo_stage >= 1 and "opacity-100" or "opacity-0")}>
                                    <div className="flex justify-between items-start">
                                        <div className="flex items-center gap-3">
                                            <span className="w-2 h-2 rounded-full bg-indigo-500 shadow-[0_0_8px_rgba(99,102,241,0.6)] animate-pulse"></span>
                                            <p className="text-sm font-semibold text-slate-900">AI Triage Classification</p>
                                        </div>
                                    </div>
                                    <div className="mt-4 grid grid-cols-2 gap-4">
                                        <div className="bg-slate-50 border border-slate-100 p-3 rounded">
                                            <p className="text-[10px] uppercase font-bold text-slate-500 mb-1">Issue Category</p>
                                            <p className="text-sm font-medium text-slate-900">{scenario}</p>
                                        </div>
                                        <div className="bg-rose-50 border border-red-100 p-3 rounded">
                                            <p className="text-[10px] uppercase font-bold text-rose-500 mb-1">Urgency</p>
                                            <p className="text-sm font-medium text-rose-900">Critical_Escalation</p>
                                        </div>
                                    </div>
                                </div>
                                
                                
                                <div className={"border border-slate-200 rounded-lg p-4 bg-white shadow-sm transition-opacity duration-1000 " + (demo_stage >= 1 and "opacity-100" or "opacity-0 hidden")}>
                                    <div className="flex items-center justify-between mb-4">
                                        <div className="flex items-center gap-3">
                                            {demo_stage == 1 and <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse shadow-[0_0_8px_rgba(245,158,11,0.5)]"></span> or <span className="w-2 h-2 rounded-full bg-slate-300"></span>}
                                            <p className="text-sm font-semibold text-slate-900">Simulate Owner Action</p>
                                        </div>
                                    </div>
                                    <p className="text-xs text-slate-500 mb-3">Owner Notification: Tenant reported a {scenario} incident requiring immediate intervention.</p>
                                    
                                    <div className="flex gap-3">
                                        <button onClick={owner_approve_demo} disabled={demo_stage == 2} className={"text-xs font-semibold px-4 py-2 rounded shadow-sm " + (demo_stage == 1 and "bg-slate-900 text-white hover:bg-slate-800" or "bg-slate-100 text-slate-400 cursor-not-allowed")}>
                                            Reply: "Approved, dispatch plumber"
                                        </button>
                                    </div>
                                </div>

                                
                                {demo_stage == 2 and (
                                    <div className="border border-emerald-200 rounded-lg p-4 bg-emerald-50 shadow-sm animate-in fade-in slide-in-from-bottom-2 duration-500">
                                        <div className="flex items-center gap-3 mb-2">
                                            <span className="text-emerald-600">✓</span>
                                            <p className="text-sm font-semibold text-emerald-900">Operation Successful</p>
                                        </div>
                                        <p className="text-xs text-emerald-700">The simulated workflow resolved. A response text was dispatched back to the tenant.</p>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
