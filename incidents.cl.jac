import from shared { IncidentRecord, panel_classes, empty_state, category_dot }

def:pub FlowEdge(active: bool) -> JsxElement {
    color = "border-indigo-500" if active else "border-slate-200";
    return (
        <div className="flex items-center mx-2 shrink-0">
            <div className={"w-8 border-t-2 border-dashed " + color}></div>
            <div className={"w-2 h-2 rounded-full -ml-1 border-2 bg-white " + color}></div>
        </div>
    );
}

def:pub FlowNodeCard(inc_node: dict, selected_id: str, on_select: any) -> JsxElement {
    is_selected = inc_node["id"] == selected_id;
    status = inc_node["status"];
    
    bg_color = "bg-white";
    border_color = "border-slate-200";
    icon_color = "text-slate-400";
    status_text = "text-slate-500";
    shadow = "shadow-sm";
    pulse = "";
    
    if status == "complete" {
        border_color = "border-emerald-300";
        icon_color = "text-emerald-500";
        status_text = "text-emerald-600";
    } elif status == "running" {
        border_color = "border-indigo-400 ring-2 ring-indigo-400/20";
        icon_color = "text-indigo-500";
        status_text = "text-indigo-600";
        pulse = "animate-pulse";
    } elif status == "queued" {
        bg_color = "bg-slate-50 opacity-60";
    } elif status == "failed" {
        border_color = "border-rose-400";
        icon_color = "text-rose-500";
        status_text = "text-rose-600";
    }
    
    if is_selected {
        border_color = "border-slate-800 ring-4 ring-slate-800/10";
        shadow = "shadow-md scale-[1.02] transform transition-all";
    }

    icon_svg = null;
    if inc_node["type"] == "trigger" { icon_svg = <path d="M22 12h-4l-3 9L9 3l-3 9H2" />; }
    elif inc_node["type"] == "llm" { icon_svg = <path d="M12 2a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2 2 2 0 0 1-2-2V4a2 2 0 0 1 2-2zm0 16a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2zM4 12a2 2 0 0 1-2-2 2 2 0 0 1 2-2h2a2 2 0 0 1 2 2 2 2 0 0 1-2 2H4zm16 0a2 2 0 0 1-2-2 2 2 0 0 1 2-2h2a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-2z" />; }
    elif inc_node["type"] == "condition" { icon_svg = <path d="M12 2l10 10-10 10L2 12 12 2z" />; }
    else { icon_svg = <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />; }

    return (
        <div 
            onClick={lambda -> None { on_select(inc_node["id"]); }} 
            className={"cursor-pointer shrink-0 w-[240px] rounded-xl border-2 p-4 transition-all relative z-10 flex flex-col gap-3 " + bg_color + " " + border_color + " " + shadow}
        >
            <div className="flex justify-between items-start">
                <div className={"p-1.5 rounded-lg bg-slate-100 " + icon_color}>
                    <svg className={"w-4 h-4 " + pulse} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        {icon_svg}
                    </svg>
                </div>
                <div className={"text-[10px] font-bold uppercase tracking-wider " + status_text}>{status}</div>
            </div>
            <div>
                <h4 className="text-sm font-bold text-slate-800 mb-1">{inc_node["label"]}</h4>
                <p className="text-xs text-slate-500 font-mono truncate">{inc_node["duration"]} | {inc_node["output_summary"]}</p>
            </div>
        </div>
    );
}

def:pub WalkerDetailPanel(inc_node: dict) -> JsxElement {
    if not inc_node {
        return (
            <div className="w-[340px] shrink-0 bg-white border-l border-slate-200 flex flex-col items-center justify-center p-8 text-center h-full">
                <p className="text-sm text-slate-400">Select a inc_node in the graph to view execution details.</p>
            </div>
        );
    }
    
    input_label = "Payload Payload";
    if inc_node["type"] != "trigger" { input_label = "Input Context"; }

    status_text_color = "text-slate-500";
    if inc_node["status"] == "complete" { status_text_color = "text-emerald-600"; }
    elif inc_node["status"] == "running" { status_text_color = "text-indigo-600"; }

    output_box_cls = "bg-indigo-50 border-indigo-100 text-indigo-900";
    output_text = inc_node["output_summary"];
    if inc_node["status"] == "queued" {
        output_box_cls = "bg-white border-slate-200 text-slate-400";
        output_text = "Awaiting upstream completion...";
    }

    metadata_block = null;
    if inc_node {
        if inc_node["metadata"] {
            data_items = [];
            _meta = inc_node["metadata"];
            
            # Simple manual keys instead of iteration
            if "Platform" in _meta { data_items.append("Platform: " + str(_meta["Platform"])); }
            if "Format" in _meta { data_items.append("Format: " + str(_meta["Format"])); }
            if "Model" in _meta { data_items.append("Model: " + str(_meta["Model"])); }
            if "Tokens" in _meta { data_items.append("Tokens: " + str(_meta["Tokens"])); }
            if "DB" in _meta { data_items.append("DB: " + str(_meta["DB"])); }
            if "Lookup" in _meta { data_items.append("Lookup: " + str(_meta["Lookup"])); }
            if "Strategy" in _meta { data_items.append("Strategy: " + str(_meta["Strategy"])); }
            if "Stage" in _meta { data_items.append("Stage: " + str(_meta["Stage"])); }
            if "Integration" in _meta { data_items.append("Integration: " + str(_meta["Integration"])); }

            metadata_block = (
                <div>
                    <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Execution Metadata</h3>
                    <div className="bg-slate-100 rounded-md p-3 text-xs font-mono text-slate-700 whitespace-pre-wrap">
                        {", ".join(data_items)}
                    </div>
                </div>
            );
        }
    }

    return (
        <div className="w-[340px] shrink-0 h-full bg-white border-l border-slate-200 flex flex-col shadow-[-10px_0_15px_-3px_rgba(0,0,0,0.05)] z-20">
            <div className="px-6 py-5 border-b border-slate-100 bg-slate-50/50 flex-none h-[110px]">
                <div className="inline-flex px-2 py-1 rounded bg-slate-200 text-slate-600 text-[10px] font-bold uppercase tracking-widest mb-3">
                    Walker Detail
                </div>
                <h2 className="text-lg font-bold text-slate-900">{inc_node["label"]}</h2>
                <div className="flex items-center justify-between mt-2">
                    <span className={"text-xs font-semibold capitalize " + status_text_color}>{inc_node["status"]}</span>
                    <span className="text-xs font-mono text-slate-400">{inc_node["duration"]} elapsed</span>
                </div>
            </div>
            
            <div className="flex-1 overflow-y-auto p-6 space-y-6 pb-20">
                <div>
                    <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Primary Responsibility</h3>
                    <p className="text-sm text-slate-700 leading-snug">{inc_node["desc"]}</p>
                </div>
                
                <div>
                    <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">{input_label}</h3>
                    <div className="bg-slate-50 border border-slate-200 rounded-lg p-4 text-xs font-mono text-slate-800 break-words whitespace-pre-wrap shadow-inner leading-relaxed">
                        {inc_node["input_summary"]}
                    </div>
                </div>

                <div>
                    <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Walker Output State</h3>
                    <div className={"rounded-lg p-4 text-sm font-medium border break-words shadow-sm " + output_box_cls}>
                        {output_text}
                    </div>
                </div>
                
                {metadata_block}
            </div>
        </div>
    );
}

def:pub EmptyCenterPane() -> JsxElement {
    return (
        <div className="flex flex-col items-center justify-center h-full opacity-60 w-full col-span-2">
            <div className="w-16 h-16 bg-white border border-slate-200 rounded-2xl shadow-sm flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
            </div>
            <h2 className="text-lg font-bold text-slate-700">AI Incident Flow</h2>
            <p className="text-sm text-slate-500 mt-1 max-w-sm text-center leading-relaxed">Select an incident from the queue to introspect its live orchestration graph.</p>
        </div>
    );
}

def:pub GraphCenterPane(selected: any, nodes: list, selected_node: str, select_node: any, active_node: dict) -> JsxElement {
    graph_comp = null;
    if len(nodes) > 0 {
        graph_comp = (
            <div className="flex items-center">
                {FlowNodeCard(nodes[0], selected_node, select_node)}
                {FlowEdge(nodes[1]["status"] != "queued")}
                {FlowNodeCard(nodes[1], selected_node, select_node)}
                {FlowEdge(nodes[2]["status"] != "queued")}
                {FlowNodeCard(nodes[2], selected_node, select_node)}
                {FlowEdge(nodes[3]["status"] != "queued")}
                <div className="flex flex-col gap-8 shrink-0">
                    <div className="flex items-center">
                        {FlowNodeCard(nodes[3], selected_node, select_node)}
                        {FlowEdge(nodes[4]["status"] != "queued")}
                        {FlowNodeCard(nodes[4], selected_node, select_node)}
                        {FlowEdge(nodes[5]["status"] != "queued")}
                        {FlowNodeCard(nodes[5], selected_node, select_node)}
                    </div>
                </div>
            </div>
        );
    }
    
    return (
        <div className="h-full flex w-full relative">
            <div className="flex-1 flex flex-col h-full bg-[#F8FAFC]">
                <div className="h-[110px] px-8 py-5 border-b border-slate-200 bg-white/80 backdrop-blur-md sticky top-0 z-10 shadow-sm shrink-0 flex justify-between items-center">
                    <div>
                        <div className="flex gap-3 items-center mb-1">
                            <div className="px-2 py-0.5 bg-indigo-100 text-indigo-700 text-[10px] font-bold rounded uppercase tracking-wider">AI Operations Graph</div>
                            <span className="text-xs text-slate-500 font-mono">{selected.id}</span>
                        </div>
                        <h1 className="text-xl font-bold tracking-tight text-slate-900 leading-snug">{selected.category} Escalation</h1>
                    </div>
                    <div className="flex text-sm text-slate-600 gap-6 border border-slate-200 bg-white shadow-sm px-4 py-2 rounded-lg">
                        <div className="flex flex-col">
                            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider">Urgency</span>
                            <span className="font-semibold text-rose-600 border-b border-rose-200">{selected.urgency}</span>
                        </div>
                        <div className="w-px bg-slate-200"></div>
                        <div className="flex flex-col">
                            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider">Property</span>
                            <span className="font-semibold text-slate-800">{selected.property} {selected.unit}</span>
                        </div>
                    </div>
                </div>

                <div className="flex-1 overflow-auto p-12 custom-graph-bg" style={{"backgroundImage": "radial-gradient(#e2e8f0 1.5px, transparent 1.5px)", "backgroundSize": "30px 30px"}}>
                    <div className="flex items-center min-w-max h-full pb-10 hover:cursor-grab active:cursor-grabbing">
                        {graph_comp}
                    </div>
                </div>
            </div>
            {WalkerDetailPanel(active_node)}
        </div>
    );
}

def:pub IncidentsView(props: dict) -> JsxElement {
    incidents = props["incidents"];
    selected = props["selected"];
    set_selected = props["set_selected"];
    search = props["search"];
    set_search = props["set_search"];
    urgency_filter = props["urgency_filter"];
    set_urgency = props["set_urgency"];
    category_filter = props["category_filter"];
    set_category = props["set_category"];
    
    has selected_node: str = "n1";

    def select_node(node_id: str) -> None {
        selected_node = node_id;
    }

    def get_incident_nodes(inc: IncidentRecord) -> dict {
        if not inc {
            return {"nodes": [], "by_id": {}};
        }
        
        is_awaiting = inc.status == "Needs Owner" or inc.status == "Action Required";
        is_resolved = inc.status == "Resolved" or inc.status == "Scheduled";
        
        n1_stat = "complete";
        n2_stat = "complete";
        n3_stat = "complete";
        n4_stat = "complete" if (is_resolved or is_awaiting) else "running";
        n5_stat = "running" if is_awaiting else ("complete" if is_resolved else "queued");
        n6_stat = "complete" if is_resolved else "queued";
        
        nodes = [
            {
                "id": "n1", "label": "Twilio SMS Ingestion", "type": "trigger", "status": n1_stat, "duration": "14ms", 
                "output_summary": "Extracted +1 " + inc.phone, "input_summary": inc.message, "desc": "Ingests raw webhook data from Twilio and normalizes metadata.", "metadata": {"Platform": "Twilio", "Format": "SMS"}
            },
            {
                "id": "n2", "label": "NLP Classifier", "type": "llm", "status": n2_stat, "duration": "412ms", 
                "output_summary": inc.category + " / " + inc.urgency, "input_summary": inc.message, "desc": "Generates semantic classification of maintenance requests to identify category and urgency score.", "metadata": {"Model": "GPT-4", "Tokens": "140"}
            },
            {
                "id": "n3", "label": "Context Resolver", "type": "action", "status": n3_stat, "duration": "88ms", 
                "output_summary": "Mapped to Unit " + inc.unit, "input_summary": "Phone lookup against active leases.", "desc": "Resolves incoming tenant details to active property management entities.", "metadata": {"DB": "Postgres", "Lookup": "Phone"}
            },
            {
                "id": "n4", "label": "Triage Workflow", "type": "action", "status": n4_stat, "duration": "105ms", 
                "output_summary": "Generated alert draft to owner", "input_summary": "Tenant context, NLP classification.", "desc": "Main strategy agent that determines whether to auto-dispatch vendor or alert the landlord.", "metadata": {"Strategy": "Approval Gate"}
            },
            {
                "id": "n5", "label": "Owner Approval Gate", "type": "condition", "status": n5_stat, "duration": "-", 
                "output_summary": "Waiting for explicit owner input via app." if is_awaiting else ("Approved by owner" if is_resolved else "Pending upstream."), "input_summary": "Draft summary created by Triage Workflow.", "desc": "Pauses execution until landlord provides explicit approval or rejection for vendor dispatch.", "metadata": {"Stage": "Blocked" if is_awaiting else "Passed"}
            },
            {
                "id": "n6", "label": "Vendor Dispatch", "type": "action", "status": n6_stat, "duration": "85ms" if is_resolved else "-", 
                "output_summary": "Dispatched to preferred contractor" if is_resolved else "Awaiting Condition", "input_summary": "Approved dispatch context.", "desc": "Contacts external vendor APIs and creates calendar invites.", "metadata": {"Integration": "Vendor API"}
            }
        ];
        
        by_id = {};
        for n in nodes {
            by_id[n["id"]] = n;
        }
        
        return {"nodes": nodes, "by_id": by_id};
    }

    graph_data = get_incident_nodes(selected);
    nodes = graph_data["nodes"];
    node_by_id = graph_data["by_id"];
    
    active_node = node_by_id[selected_node] if selected_node in node_by_id else (nodes[0] if len(nodes) > 0 else None);

    def filtered_incidents() -> list {
        res = [];
        for item in incidents {
            tenant_s = item.tenant.toLowerCase() if item.tenant else "";
            id_s = item.id.toLowerCase() if item.id else "";
            prop_s = item.property.toLowerCase() if item.property else "";
            sl = search.toLowerCase();
            if (tenant_s.includes(sl) or id_s.includes(sl) or prop_s.includes(sl)) {
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
    
    incident_list_items = [];
    if len(filtered) == 0 {
        incident_list_items.append(empty_state("No incidents", "No matches found.", False));
    } else {
        for incident in filtered {
            is_sel = selected != None and incident.id == selected.id;
            bg_cls = "bg-indigo-50/50 border-l-4 border-indigo-500 border-y border-r border-indigo-600" if is_sel else "bg-white border hover:bg-slate-50 border-slate-200 cursor-pointer";
            cat_color = category_dot(incident.category);
            incident_list_items.append(
                <div key={incident.id} onClick={lambda -> None { set_selected(incident); select_node("n1"); }} className={"px-4 py-3 mb-2 mx-2 rounded-lg transition-colors " + bg_cls}>
                    <div className="flex justify-between items-start mb-1">
                        <span className="text-[11px] font-semibold text-slate-800">{incident.property} · Unit {incident.unit}</span>
                        <span className={"w-2 h-2 mt-1 rounded-full " + cat_color}></span>
                    </div>
                    <p className="text-sm font-bold text-slate-900 mb-1 truncate">{incident.tenant}</p>
                    <p className="text-xs text-slate-500 truncate">{incident.message}</p>
                </div>
            );
        }
    }

    return (
        <div className="flex w-full h-[calc(100vh-80px)] overflow-hidden font-sans text-slate-900 bg-slate-100">
            <div className="w-[320px] h-full shrink-0 bg-white border-r border-slate-200 flex flex-col z-20 shadow-sm relative">
                <div className="p-4 border-b border-slate-100 bg-slate-50/50 flex flex-col gap-3 shrink-0 h-[110px]">
                    <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400">Incident Queue</h2>
                    <input
                        type="text"
                        placeholder="Search tenants..."
                        value={search}
                        onChange={lambda e: any -> None { set_search(e.target.value); }}
                        className="w-full text-sm border-slate-200 rounded-md focus:border-indigo-500 focus:ring-indigo-500 shadow-sm"
                    />
                </div>
                <div className="flex-1 overflow-y-auto w-full pt-2">
                    {incident_list_items}
                </div>
            </div>
            <div className="flex-1 overflow-hidden h-full flex">
                {EmptyCenterPane() if selected == None else GraphCenterPane(selected, nodes, selected_node, select_node, active_node)}
            </div>
        </div>
    );
}

