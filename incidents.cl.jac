import from shared { IncidentRecord, panel_classes, empty_state, category_dot, urgency_classes, status_classes }

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
                <p className="text-sm text-slate-400">Select a node in the graph to view execution details.</p>
            </div>
        );
    }

    input_label = "Payload";
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
    if inc_node and inc_node["metadata"] {
        data_items = [];
        _meta = inc_node["metadata"];
        if "Platform" in _meta { data_items.append("Platform: " + str(_meta["Platform"])); }
        if "Format" in _meta { data_items.append("Format: " + str(_meta["Format"])); }
        if "Model" in _meta { data_items.append("Model: " + str(_meta["Model"])); }
        if "Tokens" in _meta { data_items.append("Tokens: " + str(_meta["Tokens"])); }
        if "DB" in _meta { data_items.append("DB: " + str(_meta["DB"])); }
        if "Lookup" in _meta { data_items.append("Lookup: " + str(_meta["Lookup"])); }
        if "Strategy" in _meta { data_items.append("Strategy: " + str(_meta["Strategy"])); }
        if "Stage" in _meta { data_items.append("Stage: " + str(_meta["Stage"])); }
        if "Integration" in _meta { data_items.append("Integration: " + str(_meta["Integration"])); }
        if "Risk" in _meta { data_items.append("Risk: " + str(_meta["Risk"])); }
        if "Vendor" in _meta { data_items.append("Vendor: " + str(_meta["Vendor"])); }
        if "Cost" in _meta { data_items.append("Est. Cost: " + str(_meta["Cost"])); }

        metadata_block = (
            <div>
                <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Execution Metadata</h3>
                <div className="bg-slate-100 rounded-md p-3 text-xs font-mono text-slate-700 whitespace-pre-wrap">
                    {", ".join(data_items)}
                </div>
            </div>
        );
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

# ── SMS Card for the grid ─────────────────────────────────────
def:pub SmsCard(incident: IncidentRecord, on_click: any) -> JsxElement {
    cat_color = category_dot(incident.category);

    urgency_col = "bg-slate-100 text-slate-600";
    if incident.urgency == "Critical" { urgency_col = "bg-rose-100 text-rose-700"; }
    elif incident.urgency == "High" { urgency_col = "bg-orange-100 text-orange-700"; }
    elif incident.urgency == "Medium" { urgency_col = "bg-amber-100 text-amber-700"; }

    status_col = "bg-slate-100 text-slate-600";
    if incident.status == "Resolved" or incident.status == "resolved" { status_col = "bg-emerald-100 text-emerald-700"; }
    elif (incident.status or "").includes("pending") or (incident.status or "").includes("Owner") { status_col = "bg-amber-100 text-amber-700"; }
    elif (incident.status or "").includes("dispatch") or (incident.status or "").includes("Dispatch") { status_col = "bg-blue-100 text-blue-700"; }
    elif incident.status == "Open" { status_col = "bg-indigo-100 text-indigo-700"; }

    disp_time = incident.time if incident.time else "Just now";

    return (
        <div
            onClick={lambda -> None { on_click(incident); }}
            className="cursor-pointer bg-white rounded-xl border border-slate-200 p-5 hover:border-slate-300 hover:shadow-md transition-all duration-200 flex flex-col gap-3 group"
        >
            <div className="flex items-start justify-between">
                <div className="flex items-center gap-2">
                    <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-sm font-bold text-slate-600 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-colors">
                        {str(incident.phone)[0:2] if incident.phone else "?"}
                    </div>
                    <div>
                        <p className="text-sm font-semibold text-slate-900">{incident.tenant if incident.tenant != incident.phone else incident.phone}</p>
                        <p className="text-xs text-slate-400">{disp_time}</p>
                    </div>
                </div>
                <span className={"text-[10px] font-bold px-2 py-0.5 rounded-md uppercase tracking-wider " + urgency_col}>{incident.urgency}</span>
            </div>

            <div className="rounded-lg bg-slate-50 border border-slate-100 px-4 py-3">
                <p className="text-sm leading-relaxed text-slate-700 line-clamp-3">{incident.message}</p>
            </div>

            <div className="flex items-center justify-between mt-auto pt-1">
                <div className="flex items-center gap-2">
                    <span className={"w-2 h-2 rounded-full " + cat_color}></span>
                    <span className="text-[11px] font-medium text-slate-500">{incident.category}</span>
                    {incident.property != "Unknown Property" and (
                        <span className="text-[11px] text-slate-400 ml-1">{incident.property} {incident.unit}</span>
                    )}
                </div>
                <span className={"text-[10px] font-semibold px-2 py-0.5 rounded-md " + status_col}>{incident.status}</span>
            </div>
        </div>
    );
}

# ── Full-screen AI Flow detail view ─────────────────────────────────
def:pub AiFlowDetailView(incident: IncidentRecord, on_back: any) -> JsxElement {
    has selected_node: str = "n1";

    def select_node(node_id: str) -> None {
        selected_node = node_id;
    }

    def get_incident_nodes(inc: IncidentRecord) -> dict {
        if not inc {
            return {"nodes": [], "by_id": {}};
        }

        is_awaiting = inc.status == "Needs Owner" or inc.status == "Owner reviewing" or inc.status == "pending_approval";
        is_dispatched = inc.status == "dispatched" or inc.status == "Dispatching vendor";
        is_resolved = inc.status == "Resolved" or inc.status == "resolved" or inc.status == "Scheduled";
        has_triage = inc.category and inc.category != "Incoming SMS" and inc.category != "";

        n1_stat = "complete";
        n2_stat = "complete" if has_triage else "running";
        n3_stat = "complete" if has_triage else "queued";
        n4_stat = "complete" if (is_resolved or is_dispatched or is_awaiting) else ("running" if has_triage else "queued");
        n5_stat = "running" if is_awaiting else ("complete" if (is_resolved or is_dispatched) else "queued");
        n6_stat = "complete" if is_resolved else ("running" if is_dispatched else "queued");

        nodes = [
            {
                "id": "n1", "label": "Twilio SMS Ingestion", "type": "trigger", "status": n1_stat, "duration": "14ms",
                "output_summary": "Received from " + inc.phone,
                "input_summary": inc.message,
                "desc": "Ingests raw webhook data from Twilio and normalizes metadata.",
                "metadata": {"Platform": "Twilio", "Format": "SMS"}
            },
            {
                "id": "n2", "label": "AI Triage Walker", "type": "llm", "status": n2_stat, "duration": "1.2s" if has_triage else "-",
                "output_summary": (inc.category + " / " + inc.urgency) if has_triage else "Awaiting classification...",
                "input_summary": inc.message,
                "desc": "Classifies the inbound message via by llm() and routes to the correct handler walker.",
                "metadata": {"Model": "GPT-4o-mini", "Tokens": "~200"}
            },
            {
                "id": "n3", "label": "Context Resolver", "type": "action", "status": n3_stat, "duration": "88ms" if has_triage else "-",
                "output_summary": ("Mapped to " + inc.property + " " + inc.unit) if has_triage else "Pending...",
                "input_summary": "Phone lookup against tenant graph nodes.",
                "desc": "Traverses the property graph to resolve tenant, unit, lease, and payment context by phone number.",
                "metadata": {"DB": "Jac Graph Store", "Lookup": "Phone -> Tenant -> Unit"}
            },
            {
                "id": "n4", "label": "Maintenance Walker", "type": "llm", "status": n4_stat, "duration": "2.8s" if has_triage else "-",
                "output_summary": (inc.summary if inc.summary else "Diagnosis + vendor selection complete") if has_triage else "Queued...",
                "input_summary": "Unit history, lease context, vendor graph.",
                "desc": "Diagnoses issue, assesses risk, selects best vendor from the property's vendor graph, and creates a Ticket node.",
                "metadata": {"Model": "GPT-4o-mini", "Strategy": "Risk-aware dispatch", "Risk": inc.urgency if has_triage else "-"}
            },
            {
                "id": "n5", "label": "Owner Approval Gate", "type": "condition", "status": n5_stat, "duration": "-",
                "output_summary": "Waiting for owner approval" if is_awaiting else ("Approved" if (is_resolved or is_dispatched) else "Pending upstream"),
                "input_summary": inc.owner_notification if inc.owner_notification else "Draft summary from maintenance walker.",
                "desc": "Pauses pipeline until landlord approves or rejects vendor dispatch via the dashboard.",
                "metadata": {"Stage": "Blocked" if is_awaiting else ("Passed" if (is_resolved or is_dispatched) else "Waiting")}
            },
            {
                "id": "n6", "label": "Vendor Dispatch", "type": "action", "status": n6_stat, "duration": "85ms" if is_resolved else "-",
                "output_summary": ("Dispatched to " + inc.assignee) if (is_resolved or is_dispatched) else "Awaiting approval",
                "input_summary": "Approved dispatch context with vendor details.",
                "desc": "Sends SMS to vendor and tenant via Twilio, updates ticket status, logs to graph.",
                "metadata": {"Integration": "Twilio SMS", "Vendor": inc.assignee if inc.assignee else "-"}
            }
        ];

        by_id = {};
        for n in nodes {
            by_id[n["id"]] = n;
        }

        return {"nodes": nodes, "by_id": by_id};
    }

    graph_data = get_incident_nodes(incident);
    nodes = graph_data["nodes"];
    node_by_id = graph_data["by_id"];
    active_node = node_by_id[selected_node] if selected_node in node_by_id else (nodes[0] if len(nodes) > 0 else None);

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
        <div className="flex w-full h-[calc(100vh-56px)] overflow-hidden">
            <div className="flex-1 flex flex-col h-full bg-[#F8FAFC]">
                <div className="h-[110px] px-8 py-5 border-b border-slate-200 bg-white/80 backdrop-blur-md sticky top-0 z-10 shadow-sm shrink-0 flex justify-between items-center">
                    <div className="flex items-center gap-4">
                        <button
                            onClick={on_back}
                            className="flex items-center gap-2 text-sm font-medium text-slate-600 hover:text-slate-900 bg-white border border-slate-200 rounded-lg px-3 py-2 hover:bg-slate-50 transition shadow-sm"
                        >
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5"></path><path d="M12 19l-7-7 7-7"></path></svg>
                            Back
                        </button>
                        <div>
                            <div className="flex gap-3 items-center mb-1">
                                <div className="px-2 py-0.5 bg-indigo-100 text-indigo-700 text-[10px] font-bold rounded uppercase tracking-wider">AI Operations Graph</div>
                                <span className="text-xs text-slate-500 font-mono">{incident.id}</span>
                            </div>
                            <h1 className="text-xl font-bold tracking-tight text-slate-900 leading-snug">{incident.category} — {incident.tenant}</h1>
                        </div>
                    </div>
                    <div className="flex text-sm text-slate-600 gap-6 border border-slate-200 bg-white shadow-sm px-4 py-2 rounded-lg">
                        <div className="flex flex-col">
                            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider">Urgency</span>
                            <span className="font-semibold text-rose-600 border-b border-rose-200">{incident.urgency}</span>
                        </div>
                        <div className="w-px bg-slate-200"></div>
                        <div className="flex flex-col">
                            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider">Property</span>
                            <span className="font-semibold text-slate-800">{incident.property} {incident.unit}</span>
                        </div>
                        <div className="w-px bg-slate-200"></div>
                        <div className="flex flex-col">
                            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider">Status</span>
                            <span className="font-semibold text-slate-800">{incident.status}</span>
                        </div>
                    </div>
                </div>

                <div className="flex-1 overflow-auto p-12" style={{"backgroundImage": "radial-gradient(#e2e8f0 1.5px, transparent 1.5px)", "backgroundSize": "30px 30px"}}>
                    <div className="flex items-center min-w-max h-full pb-10">
                        {graph_comp}
                    </div>
                </div>
            </div>
            {WalkerDetailPanel(active_node)}
        </div>
    );
}

# ── Main Incidents View — card grid with detail drill-in ─────────────
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

    has viewing_detail: bool = False;

    def open_detail(incident: IncidentRecord) -> None {
        set_selected(incident);
        viewing_detail = True;
    }

    def close_detail() -> None {
        viewing_detail = False;
    }

    # If viewing detail, show full-screen AI flow
    if viewing_detail and selected {
        return <AiFlowDetailView incident={selected} on_back={close_detail} />;
    }

    # Otherwise show the SMS card grid
    def filtered_incidents() -> list {
        res = [];
        for item in incidents {
            tenant_s = (item.tenant or "").toLowerCase();
            id_s = (item.id or "").toLowerCase();
            prop_s = (item.property or "").toLowerCase();
            phone_s = (item.phone or "").toLowerCase();
            msg_s = (item.message or "").toLowerCase();
            sl = (search or "").toLowerCase();
            if (tenant_s.includes(sl) or id_s.includes(sl) or prop_s.includes(sl) or phone_s.includes(sl) or msg_s.includes(sl)) {
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

    # Collect unique categories for filter
    categories = ["All"];
    for inc in incidents {
        if inc.category and inc.category not in categories {
            categories.append(inc.category);
        }
    }

    return (
        <div className="flex flex-col w-full h-[calc(100vh-56px)] overflow-hidden bg-slate-50">
            <div className="px-8 py-6 bg-white border-b border-slate-200 shrink-0">
                <div className="flex items-center justify-between mb-4">
                    <div>
                        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">Incidents</h1>
                        <p className="text-sm text-slate-500 mt-1">Incoming SMS messages and AI triage results. Click a card to view the AI pipeline.</p>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                        <div className="bg-indigo-50 text-indigo-700 border border-indigo-200 px-3 py-1.5 rounded-lg font-semibold">
                            {str(len(filtered))} incident{("s" if len(filtered) != 1 else "")}
                        </div>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <input
                        type="text"
                        placeholder="Search by tenant, phone, message..."
                        value={search}
                        onChange={lambda e: any -> None { set_search(e.target.value); }}
                        className="flex-1 max-w-md text-sm border border-slate-200 rounded-lg px-4 py-2 focus:border-indigo-500 focus:ring-indigo-500 shadow-sm bg-white"
                    />
                    <select
                        value={urgency_filter}
                        onChange={lambda e: any -> None { set_urgency(e.target.value); }}
                        className="text-sm border border-slate-200 rounded-lg px-3 py-2 shadow-sm bg-white text-slate-700"
                    >
                        <option value="All">All Urgencies</option>
                        <option value="Critical">Critical</option>
                        <option value="High">High</option>
                        <option value="Medium">Medium</option>
                        <option value="Normal">Normal</option>
                        <option value="Low">Low</option>
                    </select>
                    <select
                        value={category_filter}
                        onChange={lambda e: any -> None { set_category(e.target.value); }}
                        className="text-sm border border-slate-200 rounded-lg px-3 py-2 shadow-sm bg-white text-slate-700"
                    >
                        {[<option key={c} value={c}>{c if c != "All" else "All Categories"}</option> for c in categories]}
                    </select>
                </div>
            </div>

            <div className="flex-1 overflow-y-auto p-8">
                {len(filtered) == 0 and (
                    <div className="flex flex-col items-center justify-center py-20">
                        {empty_state("No incidents found", "No SMS messages match your filters. Messages will appear as they arrive via Twilio.", True)}
                    </div>
                )}

                {len(filtered) > 0 and (
                    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                        {[<SmsCard key={inc.id} incident={inc} on_click={open_detail} /> for inc in filtered]}
                    </div>
                )}
            </div>
        </div>
    );
}
