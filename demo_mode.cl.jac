def:pub panel_classes() -> str { return "max-w-4xl mx-auto p-4 md:p-8 space-y-8"; }
def:pub urgency_classes() -> str { return "text-red-500 font-semibold"; }

# Top-level functional component
def:pub WorkflowNode(title: str, desc: str, status: str) -> JsxElement {
    if status == "complete" {
        return (
            <div className="flex w-full gap-4 items-start relative z-10 group">
                <div className="w-6 h-6 rounded-full flex items-center justify-center shrink-0 ring-4 mt-1 ring-emerald-200 bg-emerald-100 text-emerald-600">
                    <span className="text-[10px] font-bold">✓</span>
                </div>
                <div className="flex-1 rounded-md p-3 border transition-colors border-emerald-200 bg-emerald-50">
                    <p className="text-xs font-bold text-slate-800 uppercase tracking-wide">{title}</p>
                    <p className="text-xs text-slate-500 mt-0.5">{desc}</p>
                </div>
            </div>
        );
    }
    if status == "running" {
        return (
            <div className="flex w-full gap-4 items-start relative z-10 group">
                <div className="w-6 h-6 rounded-full flex items-center justify-center shrink-0 ring-4 mt-1 ring-blue-500 bg-blue-500 text-white shadow-lg animate-pulse">
                    <span className="text-[10px] font-bold">⋯</span>
                </div>
                <div className="flex-1 rounded-md p-3 border transition-colors border-blue-200 bg-blue-50">
                    <p className="text-xs font-bold text-slate-800 uppercase tracking-wide">{title}</p>
                    <p className="text-xs text-slate-500 mt-0.5">{desc}</p>
                </div>
            </div>
        );
    }
    return (
        <div className="flex w-full gap-4 items-start relative z-10 group">
            <div className="w-6 h-6 rounded-full flex items-center justify-center shrink-0 ring-4 mt-1 ring-slate-100 bg-white text-slate-300">
                <span className="text-[10px] font-bold">○</span>
            </div>
            <div className="flex-1 rounded-md p-3 border transition-colors border-slate-100 bg-white opacity-50">
                <p className="text-xs font-bold text-slate-800 uppercase tracking-wide">{title}</p>
                <p className="text-xs text-slate-500 mt-0.5">{desc}</p>
            </div>
        </div>
    );
}

def:pub AIPipeline(demo_stage: int, current_scenario: str, property_name: str, tenant_unit: str) -> JsxElement {
    n0_status = "pending";
    if demo_stage > 0 { n0_status = "complete"; }

    n1_status = "pending";
    if demo_stage == 1 { n1_status = "running"; }
    if demo_stage >= 2 { n1_status = "complete"; }

    n2_status = "pending";
    if demo_stage == 2 { n2_status = "running"; }
    if demo_stage >= 3 { n2_status = "complete"; }

    n3_status = "pending";
    if demo_stage == 3 { n3_status = "running"; }
    if demo_stage >= 4 { n3_status = "complete"; }
    
    n4_status = "pending";
    n4_desc = "Awaiting landlord decision";
    if demo_stage == 4 { 
        n4_status = "complete"; 
        n4_desc = "Auto-scheduled " + current_scenario + " Dispatch.";
    }
    if demo_stage == 5 { 
        n4_status = "complete"; 
        n4_desc = "Canceled auto-schedule. Sent to manual queue.";
    }

    sequence_complete = null;
    if demo_stage == 4 {
        sequence_complete = (
            <div className="w-full mt-6 bg-emerald-50 border border-emerald-200 p-5 rounded-xl shadow-sm text-left">
                <h4 className="text-xs font-bold text-emerald-800 uppercase tracking-widest mb-1">Sequence Complete</h4>
                <p className="text-sm text-emerald-600 leading-snug">The autonomous pipeline has finished operations for this incident. No further action needed.</p>
            </div>
        );
    }
    if demo_stage == 5 {
        sequence_complete = (
            <div className="w-full mt-6 bg-amber-50 border border-amber-200 p-5 rounded-xl shadow-sm text-left">
                <h4 className="text-xs font-bold text-amber-800 uppercase tracking-widest mb-1">Processing Halted</h4>
                <p className="text-sm text-amber-600 leading-snug">AI halted by property manager override. Transitioned to manual review loop.</p>
            </div>
        );
    }

    return (
        <div className="flex-1 flex flex-col p-8 bg-white overflow-y-auto">
            <div className="mb-8 flex justify-between items-center bg-slate-50 border border-slate-200 px-6 py-4 rounded-xl shadow-sm">
                <div>
                    <h3 className="text-sm font-bold text-slate-800 tracking-tight uppercase">AI Autonomy Timeline</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Real-time system operations</p>
                </div>
            </div>

            <div className="flex-1 flex flex-col items-center justify-start mt-4 px-4 w-full max-w-sm mx-auto gap-4 relative">
                {WorkflowNode("1. Ingestion", "Received Twilio SMS payload", n0_status)}
                {WorkflowNode("2. NLP Parser", {"Classified intent: " + current_scenario}, n1_status)}
                {WorkflowNode("3. Policy Check", "Matched rules for Unit 4B", n2_status)}
                {WorkflowNode("4. Vendor & Owner Alert", {n4_desc}, n3_status)}
                {sequence_complete}
            </div>
        </div>
    );
}

def:pub TenantPhone(demo_stage: int, incoming_text: str, set_incoming: any, trigger_simulation: any, tenant_name: str, property_name: str, current_scenario: str) -> JsxElement {
    chat_active = null;
    if demo_stage > 0 {
        chat_active = (
            <div className="self-end bg-[#0A84FF] text-white rounded-2xl rounded-tr-sm px-4 py-2.5 max-w-[85%] text-[15px] shadow-sm leading-snug">
                {incoming_text}
            </div>
        );
    }

    chat_received = null;
    if demo_stage >= 2 {
        chat_received = (
            <div className="self-start bg-slate-200 text-slate-800 rounded-2xl rounded-tl-sm px-4 py-2.5 max-w-[85%] text-[15px] shadow-sm leading-snug">
                Thanks, {tenant_name}. We've received your message and our AI agent is reviewing the request now.
            </div>
        );
    }

    chat_approved = null;
    if demo_stage == 4 {
        v = "your requested vendor";
        if current_scenario == "Plumbing" { v = "Harbor Plumbing Co."; }
        if current_scenario == "HVAC" { v = "Apex Heating API"; }
        if current_scenario == "Electrical" { v = "Volt Dynamics"; }
        if current_scenario == "Pest Control" { v = "Critter Getters"; }
        if current_scenario == "Lockout" { v = "24/7 Locksmiths"; }
        chat_approved = (
            <div className="self-start bg-slate-200 text-slate-800 rounded-2xl rounded-tl-sm px-4 py-3 max-w-[85%] text-[15px] shadow-sm leading-snug mt-2">
                <b>Update:</b><br/>Your maintenance issue was approved. A technician from {v} has been tentatively scheduled between 3-5 PM.
            </div>
        );
    }
    
    chat_rejected = null;
    if demo_stage == 5 {
        chat_rejected = (
            <div className="self-start bg-slate-200 text-slate-800 rounded-2xl rounded-tl-sm px-4 py-3 max-w-[85%] text-[15px] shadow-sm leading-snug mt-2">
                <b>Update:</b><br/>The management team has placed a hold on automatic dispatch to review the request personally. We will text back shortly.
            </div>
        );
    }

    input_area = null;
    if demo_stage == 0 {
        input_area = (
            <div className="flex flex-col gap-3">
                <textarea 
                    value={incoming_text}
                    onChange={lambda e: any -> None { set_incoming(e.target.value); }}
                    className="w-full text-sm border-0 bg-slate-50 rounded-xl px-4 py-3 outline-none min-h-[50px] resize-none focus:ring-2 focus:ring-blue-500 text-slate-900"
                />
                <button onClick={trigger_simulation} className="w-full bg-[#0A84FF] text-white rounded-xl py-3 text-sm font-semibold shadow-sm hover:bg-blue-600 transition">
                    Send Message
                </button>
            </div>
        );
    }
    if demo_stage != 0 {
        input_area = (
            <div className="w-full text-sm font-medium bg-slate-100 text-slate-400 rounded-xl px-4 py-3 text-center cursor-not-allowed">
                Simulation active...
            </div>
        );
    }

    return (
        <div className="flex flex-col bg-white rounded-[2rem] shadow-xl border-[12px] border-slate-900 overflow-hidden relative h-[650px] w-full max-w-[340px] mx-auto">
            <div className="bg-slate-900 text-white text-center py-2 text-[10px] font-bold tracking-widest uppercase relative z-10 flex justify-between px-6 pt-3">
                <span>9:41</span>
                <span className="opacity-80">5G</span>
            </div>
            <div className="bg-white border-b border-slate-100 py-3 text-center z-10 shadow-sm">
                <p className="text-sm font-bold text-slate-800">Rentora AI</p>
                <p className="text-[10px] text-slate-400">{property_name}</p>
            </div>
            <div className="flex-1 bg-[#F8FAFC] p-4 overflow-y-auto flex flex-col pt-6 gap-4">
                <div className="text-[10px] text-center text-slate-400 font-medium mb-2">Today 9:41 AM</div>
                {chat_active}
                {chat_received}
                {chat_approved}
                {chat_rejected}
            </div>
            <div className="bg-white p-4 border-t border-slate-100 relative z-10">
                {input_area}
            </div>
        </div>
    );
}

def:pub LandlordPhone(demo_stage: int, incoming_text: str, tenant_name: str, property_name: str, current_scenario: str) -> JsxElement {
    empty_state = null;
    if demo_stage < 3 {
        empty_state = (
            <div className="flex flex-col items-center justify-center h-full opacity-40 mt-20 gap-4">
                <div className="w-12 h-12 rounded-full border-2 border-slate-500 flex items-center justify-center text-xl">🔔</div>
                <p className="text-sm text-slate-300 font-medium">Listening for AI alerts...</p>
            </div>
        );
    }

    alert_card = null;
    if demo_stage >= 3 {
        action_buttons = null;
        if demo_stage == 3 {
            action_buttons = (
                <div className="space-y-3 mt-4">
                    <div className="bg-blue-500/10 border border-blue-500/30 p-3 rounded-xl">
                        <p className="text-xs text-blue-400 font-medium leading-snug">AI proposed automated dispatch. Cost roughly $180.</p>
                    </div>
                </div>
            );
        }

        status_footer = null;
        if demo_stage == 3 {
             status_footer = (
                <div className="mt-4 pt-4 border-t border-slate-700">
                    <p className="text-xs font-medium text-slate-400 text-center animate-pulse">Use top right controls to reply...</p>
                </div>
             );
        }
        if demo_stage == 4 {
             status_footer = (
                <div className="mt-4 pt-4 border-t border-slate-700">
                    <p className="text-xs font-bold text-emerald-400 text-center">✓ Automatically Dispatched</p>
                </div>
             );
        }
        if demo_stage == 5 {
             status_footer = (
                <div className="mt-4 pt-4 border-t border-slate-700">
                    <p className="text-xs font-bold text-amber-400 text-center">⏸ Overridden. Manual Queue.</p>
                </div>
             );
        }

        alert_card = (
            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-5 shadow-xl relative mt-4">
                <div className="flex justify-between items-center mb-4">
                    <span className="bg-red-500/20 text-red-400 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-widest border border-red-500/30">Action Required</span>
                    <span className="text-xs text-slate-500 tracking-tight">Just now</span>
                </div>
                
                <h3 className="text-white font-medium text-lg mb-1">{current_scenario} Incident</h3>
                <p className="text-slate-400 text-sm mb-4 leading-relaxed"><b>{tenant_name}</b> (Unit 4B)</p>
                
                <div className="bg-slate-900/50 p-3 rounded-xl border border-slate-700 mb-2 inline-block w-full">
                    <p className="text-[13px] text-slate-300 italic">"{incoming_text}"</p>
                </div>
                
                {action_buttons}
                {status_footer}
            </div>
        );
    }

    return (
        <div className="flex flex-col bg-slate-950 rounded-[2rem] shadow-xl border-[12px] border-slate-900 overflow-hidden relative h-[650px] w-full max-w-[340px] mx-auto">
            <div className="bg-slate-900 text-slate-400 text-center py-2 text-[10px] font-bold tracking-widest uppercase relative z-10 flex justify-between px-6 pt-3">
                <span>9:41</span>
                <span className="opacity-80">5G</span>
            </div>
            <div className="bg-slate-950 border-b border-slate-800 py-3 text-center z-10 shadow-sm">
                <p className="text-sm font-bold text-white">Owner Connect</p>
                <p className="text-[10px] text-slate-500">{property_name}</p>
            </div>
            <div className="flex-1 p-4 overflow-y-auto flex flex-col gap-4">
                {empty_state}
                {alert_card}
            </div>
        </div>
    );
}

def:pub demo_mode_view(demo_incidents: list, selected: any, set_selected: any, current_scenario: str, set_scenario: any, incoming_text: str, set_incoming: any, demo_stage: int, set_demo_stage: any) -> JsxElement {
    
    control_panel = null;
    if demo_stage == 0 {
        control_panel = (
            <div className="bg-white border rounded-xl shadow-sm p-4 flex gap-3 opacity-50">
                <button disabled={True} className="px-4 py-2 bg-slate-100 text-slate-500 rounded-md text-sm font-bold">Waiting for Tenant SMS...</button>
            </div>
        );
    }
    if demo_stage == 3 {
        control_panel = (
            <div className="bg-white border rounded-xl shadow-sm p-4 flex gap-3 shadow-lg ring-2 ring-blue-500/20">
                <button onClick={lambda -> None { set_demo_stage(4); }} className="px-4 py-2 bg-emerald-500 text-white rounded-md text-sm font-bold hover:bg-emerald-600 transition">Landlord: Approve AI</button>
                <button onClick={lambda -> None { set_demo_stage(5); }} className="px-4 py-2 bg-amber-500 text-white rounded-md text-sm font-bold hover:bg-amber-600 transition">Landlord: Manual Review</button>
            </div>
        );
    }
    if demo_stage >= 4 {
        control_panel = (
            <div className="bg-white border rounded-xl shadow-sm p-4 flex gap-3">
                <button onClick={lambda -> None { set_demo_stage(0); set_incoming("The sink is leaking."); }} className="px-4 py-2 bg-slate-800 text-white rounded-md text-sm font-bold">Reset Demo</button>
            </div>
        );
    }

    return (
        <div className="flex w-full flex-col h-[calc(100vh-80px)] font-sans overscroll-none overflow-hidden text-slate-900 border-x border-slate-200 bg-slate-100">
            
            <div className="px-8 py-6 flex justify-between items-end border-b border-slate-200 bg-white shadow-sm z-20 shrink-0">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-900 mb-1">Interactive Demo</h1>
                    <p className="text-[13px] text-slate-500 font-medium">Step-through functional pipeline without corrupting production data.</p>
                </div>
                <div className="flex flex-col items-end gap-3 text-right">
                    <div className="flex items-center gap-4">
                        <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">Scenario</span>
                        <select 
                            value={current_scenario}
                            onChange={lambda e: any -> None { set_scenario(e.target.value); if e.target.value == "Plumbing" { set_incoming("The sink is leaking under the cabinet."); } elif e.target.value == "Electrical" { set_incoming("The breaker keeps tripping in the kitchen."); } elif e.target.value == "Pest Control" { set_incoming("We found a mice nest near the garage door."); } elif e.target.value == "Lockout" { set_incoming("I accidentally locked myself out of the unit!"); } else { set_incoming("My heater broke overnight!"); } }}
                            className="bg-slate-50 border border-slate-200 text-sm font-medium py-1.5 px-3 rounded-md outline-none"
                        >
                            <option value="Plumbing">Plumbing</option>
                            <option value="HVAC">HVAC</option>
                            <option value="Electrical">Electrical</option>
                            <option value="Pest Control">Pest Control</option>
                            <option value="Lockout">Lockout</option>
                            <option value="Noise">Noise</option>
                        </select>
                    </div>
                    {control_panel}
                </div>
            </div>

            <div className="flex w-full flex-1 overflow-hidden p-6 gap-6 relative justify-center">
                <div className="shrink-0 w-[350px]">
                    {TenantPhone(demo_stage, incoming_text, set_incoming, lambda -> None { set_demo_stage(3); }, "Sarah Jenkins", "418 King St W", current_scenario)}
                </div>
                
                <div className="flex-1 max-w-[450px] shadow-xl rounded-[2rem] overflow-hidden border-[12px] border-slate-200">
                    {AIPipeline(demo_stage, current_scenario, "418 King St W", "4B")}
                </div>
                
                <div className="shrink-0 w-[350px]">
                    {LandlordPhone(demo_stage, incoming_text, "Sarah Jenkins", "418 King St W", current_scenario)}
                </div>
            </div>
        </div>
    );
}

