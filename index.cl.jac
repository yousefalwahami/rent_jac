
obj IncidentStep {
    has label: str = "";
    has detail: str = "";
    has time: str = "";
    has state: str = "done";
}

obj IncidentRecord {
    has id: str = "";
    has time: str = "";
    has tenant: str = "";
    has phone: str = "";
    has property: str = "";
    has unit: str = "";
    has category: str = "";
    has urgency: str = "";
    has status: str = "";
    has confidence: str = "";
    has summary: str = "";
    has message: str = "";
    has recommended_action: str = "";
    has owner_notification: str = "";
    has tenant_reply: str = "";
    has automation: str = "";
    has latency: str = "";
    has assignee: str = "";
    has property_code: str = "";
    has steps: list = [];
}

def status_classes(value: str) -> str {
    if value == "Resolved" {
        return "bg-emerald-50 text-emerald-700 border border-emerald-200";
    }
    if value == "Owner reviewing" {
        return "bg-amber-50 text-amber-700 border border-amber-200";
    }
    if value == "Dispatching vendor" {
        return "bg-blue-50 text-blue-700 border border-blue-200";
    }
    return "bg-slate-100 text-slate-700 border border-slate-200";
}

def urgency_classes(value: str) -> str {
    if value == "Critical" {
        return "bg-rose-50 text-rose-700 border border-rose-200";
    }
    if value == "High" {
        return "bg-orange-50 text-orange-700 border border-orange-200";
    }
    if value == "Medium" {
        return "bg-amber-50 text-amber-700 border border-amber-200";
    }
    return "bg-slate-100 text-slate-700 border border-slate-200";
}

def category_dot(value: str) -> str {
    if value == "Electrical" {
        return "bg-rose-500";
    }
    if value == "Plumbing" {
        return "bg-sky-500";
    }
    if value == "HVAC" {
        return "bg-violet-500";
    }
    if value == "Appliance" {
        return "bg-emerald-500";
    }
    if value == "Noise" {
        return "bg-amber-500";
    }
    return "bg-slate-500";
}

def nav_button_classes(active: bool) -> str {
    return (
        active
        and "bg-slate-950 text-white shadow-[0_12px_30px_rgba(15,23,40,0.18)]"
        or "text-slate-600 hover:bg-white hover:text-slate-950"
    );
}

def panel_classes() -> str {
    return "rounded-[28px] border border-white/70 bg-white/88 shadow-[0_18px_50px_rgba(15,23,40,0.08)] backdrop-blur";
}

def sample_incidents() -> list {
    return [
        IncidentRecord(
            id="INC-24018",
            time="2 min ago",
            tenant="Maya Chen",
            phone="(415) 555-0182",
            property="Harbor Point Residences",
            unit="4B",
            category="Plumbing",
            urgency="High",
            status="Owner reviewing",
            confidence="98%",
            summary="Active sink leak with water reaching flooring. AI flagged likely supply line issue and recommended same-day plumber dispatch.",
            message="The sink in Unit 4B is leaking and water is getting on the floor.",
            recommended_action="Send approved plumber to Unit 4B within 2 hours and instruct tenant to shut off under-sink valve if accessible.",
            owner_notification="SMS + email alert drafted for Olivia Bennett with leak severity, unit details, and vendor recommendation.",
            tenant_reply="We’ve marked this as high priority and are arranging a plumber now. If you can safely access the shutoff valve under the sink, please turn it off to limit water damage.",
            automation="92% automated",
            latency="11s",
            assignee="Olivia Bennett",
            property_code="HP-204",
            steps=[
                IncidentStep(label="Message received", detail="Inbound SMS matched to Harbor Point property line.", time="10:14 AM", state="done"),
                IncidentStep(label="Parsed successfully", detail="Unit 4B and leak keywords extracted with high confidence.", time="10:14 AM", state="done"),
                IncidentStep(label="Classified as plumbing", detail="Water damage risk elevated due to floor exposure.", time="10:14 AM", state="done"),
                IncidentStep(label="Urgency marked high", detail="Escalated for same-day dispatch recommendation.", time="10:14 AM", state="done"),
                IncidentStep(label="Owner alert prepared", detail="Notification queued for manager approval.", time="10:15 AM", state="live"),
                IncidentStep(label="Tenant response drafted", detail="Safety guidance included before vendor arrival.", time="10:15 AM", state="queued")
            ]
        ),
        IncidentRecord(
            id="INC-24017",
            time="7 min ago",
            tenant="Daniel Ortiz",
            phone="(646) 555-0127",
            property="Northline Flats",
            unit="12",
            category="Electrical",
            urgency="Critical",
            status="Dispatching vendor",
            confidence="99%",
            summary="Burning smell from outlet indicates potential electrical hazard. AI escalated to emergency protocol and advised immediate power isolation.",
            message="There’s a burning smell coming from the outlet in apartment 12.",
            recommended_action="Call emergency electrician immediately, notify tenant to avoid outlet, and consider temporary breaker shutoff if safe.",
            owner_notification="Critical alert sent to on-call manager and regional ops lead with emergency escalation tag.",
            tenant_reply="This may be an electrical hazard. Please stop using that outlet immediately and, if safe, switch off the breaker for that room. An emergency electrician is being dispatched now.",
            automation="96% automated",
            latency="8s",
            assignee="Marcus Hale",
            property_code="NF-112",
            steps=[
                IncidentStep(label="Message received", detail="Inbound SMS linked to Northline Flats resident record.", time="10:09 AM", state="done"),
                IncidentStep(label="Hazard phrase detected", detail="Burning smell triggered emergency electrical policy.", time="10:09 AM", state="done"),
                IncidentStep(label="Classified as electrical", detail="Critical severity threshold exceeded.", time="10:09 AM", state="done"),
                IncidentStep(label="Escalation launched", detail="Emergency electrician shortlist generated.", time="10:10 AM", state="live"),
                IncidentStep(label="Tenant safety reply sent", detail="Immediate safety instructions delivered.", time="10:10 AM", state="done")
            ]
        ),
        IncidentRecord(
            id="INC-24016",
            time="18 min ago",
            tenant="Aisha Thompson",
            phone="(312) 555-0194",
            property="Cedar Grove Homes",
            unit="7",
            category="HVAC",
            urgency="High",
            status="Dispatching vendor",
            confidence="95%",
            summary="Heating outage in occupied unit. AI recommended expedited HVAC dispatch due to cold-weather service level policy.",
            message="My heat stopped working in Unit 7.",
            recommended_action="Schedule HVAC technician for priority visit and send tenant troubleshooting checklist while dispatch is confirmed.",
            owner_notification="Priority HVAC outage summary sent to property manager with weather context and SLA timer.",
            tenant_reply="We’ve flagged this as a priority heating issue and are scheduling a technician now. If you’d like, we can also send a quick thermostat and breaker checklist while we confirm arrival time.",
            automation="88% automated",
            latency="14s",
            assignee="Priya Shah",
            property_code="CG-007",
            steps=[
                IncidentStep(label="Message received", detail="Tenant text matched to Cedar Grove Homes.", time="9:58 AM", state="done"),
                IncidentStep(label="Unit extracted", detail="Unit 7 identified from message body.", time="9:58 AM", state="done"),
                IncidentStep(label="Classified as HVAC", detail="No heat issue mapped to winter response policy.", time="9:58 AM", state="done"),
                IncidentStep(label="Vendor shortlist generated", detail="Preferred HVAC vendors ranked by response time.", time="9:59 AM", state="live")
            ]
        ),
        IncidentRecord(
            id="INC-24015",
            time="31 min ago",
            tenant="Jordan Lee",
            phone="(718) 555-0108",
            property="Maple Court",
            unit="9",
            category="Appliance",
            urgency="Medium",
            status="Owner reviewing",
            confidence="93%",
            summary="Refrigerator cooling failure likely requires appliance technician. AI suggested preserving food guidance and next-available service slot.",
            message="The fridge in Unit 9 is not cooling.",
            recommended_action="Offer next available appliance repair slot and advise tenant to move perishables if temperature is rising.",
            owner_notification="Repair recommendation prepared with appliance warranty lookup and vendor options.",
            tenant_reply="Thanks for reporting this. We’re reviewing the fastest repair option now. If the fridge temperature is rising, please move any perishables to prevent spoilage.",
            automation="84% automated",
            latency="16s",
            assignee="Elena Brooks",
            property_code="MC-309",
            steps=[
                IncidentStep(label="Message received", detail="Appliance issue detected from tenant SMS.", time="9:45 AM", state="done"),
                IncidentStep(label="Classified as appliance", detail="Cooling failure mapped to non-emergency appliance workflow.", time="9:45 AM", state="done"),
                IncidentStep(label="Warranty lookup started", detail="Asset record cross-check in progress.", time="9:46 AM", state="live")
            ]
        ),
        IncidentRecord(
            id="INC-24014",
            time="52 min ago",
            tenant="Sofia Ramirez",
            phone="(213) 555-0171",
            property="The Lark",
            unit="15A",
            category="Noise",
            urgency="Low",
            status="Resolved",
            confidence="90%",
            summary="Repeat after-hours noise complaint logged and routed to community policy workflow. AI suggested documented warning and quiet-hours follow-up.",
            message="The upstairs neighbors are blasting music again.",
            recommended_action="Send courtesy warning to resident in 16A and log repeat complaint for leasing follow-up.",
            owner_notification="Community manager notified with prior complaint history attached.",
            tenant_reply="We’ve documented the complaint and notified the on-site team to address the disturbance under quiet-hours policy.",
            automation="97% automated",
            latency="6s",
            assignee="Nina Patel",
            property_code="LK-815",
            steps=[
                IncidentStep(label="Message received", detail="Repeat complaint matched to prior resident history.", time="9:24 AM", state="done"),
                IncidentStep(label="Policy workflow applied", detail="Quiet-hours enforcement template selected.", time="9:24 AM", state="done"),
                IncidentStep(label="Resolution logged", detail="Courtesy warning sent and case closed.", time="9:25 AM", state="done")
            ]
        )
    ];
}

def metric_card(title: str, value: str, delta: str, note: str) -> JsxElement {
    return (
        <div className={panel_classes() + " p-5"}>
            <div className="flex items-start justify-between gap-4">
                <div>
                    <p className="text-sm font-medium text-slate-500">{title}</p>
                    <p className="mt-3 text-3xl font-semibold tracking-[-0.03em] text-slate-950">{value}</p>
                </div>
                <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600">{delta}</span>
            </div>
            <p className="mt-3 text-sm leading-6 text-slate-500">{note}</p>
        </div>
    );
}

def sidebar_item(label: str, active: bool, on_click: any, meta: str) -> JsxElement {
    return (
        <button
            onClick={on_click}
            className={"w-full rounded-2xl px-4 py-3 text-left transition-all duration-200 " + nav_button_classes(active)}
        >
            <div className="flex items-center justify-between gap-3">
                <span className="text-sm font-semibold tracking-[-0.01em]">{label}</span>
                <span className={active and "text-white/70 text-xs" or "text-slate-400 text-xs"}>{meta}</span>
            </div>
        </button>
    );
}

def incident_row(incident: IncidentRecord, active: bool, on_click: any) -> JsxElement {
    return (
        <button
            onClick={on_click}
            className={
                "grid w-full grid-cols-[0.9fr_1.1fr_1.2fr_1fr_0.9fr_1fr_0.8fr] items-center gap-3 rounded-2xl border px-4 py-4 text-left transition-all duration-200 "
                + (active
                    and "border-slate-900 bg-slate-950 text-white shadow-[0_18px_40px_rgba(15,23,40,0.18)]"
                    or "border-transparent bg-white hover:border-slate-200 hover:bg-slate-50")
            }
        >
            <div>
                <p className={active and "text-sm font-semibold text-white" or "text-sm font-semibold text-slate-900"}>{incident.time}</p>
                <p className={active and "mt-1 text-xs text-white/65" or "mt-1 text-xs text-slate-500"}>{incident.id}</p>
            </div>
            <div>
                <p className={active and "text-sm font-semibold text-white" or "text-sm font-semibold text-slate-900"}>{incident.tenant}</p>
                <p className={active and "mt-1 text-xs text-white/65" or "mt-1 text-xs text-slate-500"}>{incident.phone}</p>
            </div>
            <div>
                <p className={active and "text-sm font-semibold text-white" or "text-sm font-semibold text-slate-900"}>{incident.property}</p>
                <p className={active and "mt-1 text-xs text-white/65" or "mt-1 text-xs text-slate-500"}>Unit {incident.unit}</p>
            </div>
            <div className="flex items-center gap-2">
                <span className={"h-2.5 w-2.5 rounded-full " + category_dot(incident.category)}></span>
                <span className={active and "text-sm text-white" or "text-sm text-slate-700"}>{incident.category}</span>
            </div>
            <div>
                <span className={"inline-flex rounded-full px-2.5 py-1 text-xs font-semibold " + urgency_classes(incident.urgency)}>{incident.urgency}</span>
            </div>
            <div>
                <span className={"inline-flex rounded-full px-2.5 py-1 text-xs font-semibold " + status_classes(incident.status)}>{incident.status}</span>
            </div>
            <div>
                <p className={active and "text-sm font-semibold text-white" or "text-sm font-semibold text-slate-900"}>{incident.confidence}</p>
                <p className={active and "mt-1 text-xs text-white/65" or "mt-1 text-xs text-slate-500"}>AI confidence</p>
            </div>
        </button>
    );
}

def timeline_step(step: IncidentStep) -> JsxElement {
    return (
        <div className="flex gap-3">
            <div className="flex flex-col items-center">
                <span className={
                    "mt-1 flex h-3.5 w-3.5 rounded-full border-2 border-white shadow "
                    + (step.state == "live"
                        and "bg-blue-600"
                        or (step.state == "queued" and "bg-slate-300" or "bg-emerald-500"))
                }></span>
                <span className="mt-2 h-full w-px bg-slate-200"></span>
            </div>
            <div className="pb-5">
                <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold text-slate-900">{step.label}</p>
                    <span className={
                        "rounded-full px-2 py-0.5 text-[11px] font-semibold uppercase tracking-[0.08em] "
                        + (step.state == "live"
                            and "bg-blue-50 text-blue-700"
                            or (step.state == "queued" and "bg-slate-100 text-slate-500" or "bg-emerald-50 text-emerald-700"))
                    }>{step.state}</span>
                </div>
                <p className="mt-1 text-sm leading-6 text-slate-500">{step.detail}</p>
                <p className="mt-2 text-xs font-medium text-slate-400">{step.time}</p>
            </div>
        </div>
    );
}

def dashboard_view(incidents: list, selected: IncidentRecord, set_selected: any) -> JsxElement {
    return (
        <div className="space-y-6">
            <div className={panel_classes() + " overflow-hidden p-8"}>
                <div className="flex items-start justify-between gap-8">
                    <div className="max-w-3xl">
                        <div className="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.12em] text-blue-700">
                            <span className="h-2 w-2 rounded-full bg-blue-600"></span>
                            Live operations overview
                        </div>
                        <h1 className="mt-5 text-5xl font-semibold tracking-[-0.05em] text-slate-950">From tenant text to action in seconds.</h1>
                        <p className="mt-4 max-w-2xl text-base leading-7 text-slate-600">
                            Rentora gives property teams a live command center for inbound SMS incidents, AI triage, escalation decisions, and owner-ready actions.
                        </p>
                    </div>
                    <div className="grid min-w-[320px] gap-3 rounded-[24px] border border-slate-200 bg-slate-950 p-5 text-white shadow-[0_20px_50px_rgba(15,23,40,0.24)]">
                        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-white/60">Twilio-ready event stream</p>
                        <div className="flex items-center justify-between rounded-2xl bg-white/8 px-4 py-3">
                            <span className="text-sm text-white/70">Inbound SMS</span>
                            <span className="text-sm font-semibold">Connected schema</span>
                        </div>
                        <div className="flex items-center justify-between rounded-2xl bg-white/8 px-4 py-3">
                            <span className="text-sm text-white/70">Owner alerts</span>
                            <span className="text-sm font-semibold">Stateful previews</span>
                        </div>
                        <div className="flex items-center justify-between rounded-2xl bg-white/8 px-4 py-3">
                            <span className="text-sm text-white/70">Live updates</span>
                            <span className="text-sm font-semibold">Event-driven UI</span>
                        </div>
                    </div>
                </div>
                <div className="mt-8 grid grid-cols-6 gap-4">
                    {metric_card("Total Incidents", "184", "+12%", "Across 42 active properties this week.")}
                    {metric_card("Urgent Issues", "9", "2 critical", "Electrical, leak, and no-heat incidents requiring fast action.")}
                    {metric_card("Resolved Today", "27", "+6", "Closed with owner confirmation and tenant follow-up.")}
                    {metric_card("Avg Response Time", "38 sec", "-14%", "From inbound text to first owner-ready recommendation.")}
                    {metric_card("Active Properties", "42", "6 regions", "Portfolio coverage with centralized incident visibility.")}
                    {metric_card("AI Automation Rate", "91%", "+4 pts", "Incidents triaged without manual intake work.")}
                </div>
            </div>

            <div className="grid grid-cols-[1.45fr_0.95fr] gap-6">
                <div className={panel_classes() + " p-6"}>
                    <div className="flex items-end justify-between gap-4 border-b border-slate-100 pb-4">
                        <div>
                            <p className="text-sm font-semibold text-slate-500">Real-time incident feed</p>
                            <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Live triage queue</h2>
                        </div>
                        <div className="flex items-center gap-2 rounded-full bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700">
                            <span className="h-2 w-2 rounded-full bg-emerald-500"></span>
                            Sync healthy
                        </div>
                    </div>
                    <div className="mt-4 grid grid-cols-[0.9fr_1.1fr_1.2fr_1fr_0.9fr_1fr_0.8fr] gap-3 px-4 text-[11px] font-semibold uppercase tracking-[0.12em] text-slate-400">
                        <span>Time</span>
                        <span>Tenant</span>
                        <span>Property / Unit</span>
                        <span>Category</span>
                        <span>Urgency</span>
                        <span>Status</span>
                        <span>AI</span>
                    </div>
                    <div className="mt-3 space-y-3">
                        {[incident_row(item, selected.id == item.id, lambda -> None { set_selected(item); }) for item in incidents]}
                    </div>
                </div>

                <div className="space-y-6">
                    <div className={panel_classes() + " p-6"}>
                        <div className="flex items-start justify-between gap-4">
                            <div>
                                <p className="text-sm font-semibold text-slate-500">Selected incident</p>
                                <h3 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">{selected.property} · Unit {selected.unit}</h3>
                            </div>
                            <span className={"inline-flex rounded-full px-3 py-1 text-xs font-semibold " + urgency_classes(selected.urgency)}>{selected.urgency}</span>
                        </div>
                        <div className="mt-5 rounded-[24px] bg-slate-950 p-5 text-white">
                            <p className="text-xs font-semibold uppercase tracking-[0.12em] text-white/55">Original tenant message</p>
                            <p className="mt-3 text-lg leading-8 tracking-[-0.02em]">“{selected.message}”</p>
                            <div className="mt-5 grid grid-cols-2 gap-3 text-sm text-white/72">
                                <div className="rounded-2xl bg-white/8 p-4">
                                    <p className="text-xs uppercase tracking-[0.12em] text-white/45">Property line</p>
                                    <p className="mt-2 font-semibold text-white">{selected.property_code}</p>
                                </div>
                                <div className="rounded-2xl bg-white/8 p-4">
                                    <p className="text-xs uppercase tracking-[0.12em] text-white/45">Latency</p>
                                    <p className="mt-2 font-semibold text-white">{selected.latency}</p>
                                </div>
                            </div>
                        </div>
                        <div className="mt-5 grid gap-4">
                            <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                                <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">AI summary</p>
                                <p className="mt-3 text-sm leading-7 text-slate-700">{selected.summary}</p>
                            </div>
                            <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                                <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Recommended action</p>
                                <p className="mt-3 text-sm leading-7 text-slate-700">{selected.recommended_action}</p>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                                    <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Owner notification</p>
                                    <p className="mt-3 text-sm leading-7 text-slate-700">{selected.owner_notification}</p>
                                </div>
                                <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                                    <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Tenant reply</p>
                                    <p className="mt-3 text-sm leading-7 text-slate-700">{selected.tenant_reply}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className={panel_classes() + " p-6"}>
                        <div className="flex items-center justify-between gap-4">
                            <div>
                                <p className="text-sm font-semibold text-slate-500">AI activity timeline</p>
                                <h3 className="mt-1 text-xl font-semibold tracking-[-0.03em] text-slate-950">Visible, live, and demo-ready</h3>
                            </div>
                            <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-700">{selected.automation}</span>
                        </div>
                        <div className="mt-5">
                            {[timeline_step(step) for step in selected.steps]}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

def incidents_view(incidents: list, selected: IncidentRecord, set_selected: any, search: str, set_search: any, urgency_filter: str, set_urgency: any, category_filter: str, set_category: any) -> JsxElement {
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
                    <div className="grid grid-cols-2 gap-3">
                        <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-4">
                            <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Category</p>
                            <p className="mt-2 text-sm font-semibold text-slate-900">{selected.category}</p>
                        </div>
                        <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-4">
                            <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Status</p>
                            <p className="mt-2 text-sm font-semibold text-slate-900">{selected.status}</p>
                        </div>
                    </div>
                    <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                        <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Recommended action</p>
                        <p className="mt-3 text-sm leading-7 text-slate-700">{selected.recommended_action}</p>
                    </div>
                    <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                        <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Action history</p>
                        <div className="mt-4">{[timeline_step(step) for step in selected.steps]}</div>
                    </div>
                </div>
            </div>
        </div>
    );
}

def ai_activity_view(incidents: list) -> JsxElement {
    return (
        <div className="grid grid-cols-[1.05fr_0.95fr] gap-6">
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">AI workflow visibility</p>
                    <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">Agent activity</h1>
                    <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600">A clean operational view of how Rentora parses inbound texts, classifies incidents, escalates risk, and prepares owner-ready actions without exposing chain-of-thought.</p>
                    <div className="mt-6 grid grid-cols-3 gap-4">
                        {metric_card("Median latency", "9.4s", "-1.2s", "Across the last 50 processed incidents.")}
                        {metric_card("Escalations", "14", "3 critical", "Triggered by hazard phrases, water damage, or no-heat policy.")}
                        {metric_card("Successful automations", "47", "94%", "Incidents completed with owner-ready drafts and tenant replies.")}
                    </div>
                </div>
                <div className={panel_classes() + " p-6"}>
                    <div className="flex items-center justify-between gap-4">
                        <div>
                            <p className="text-sm font-semibold text-slate-500">Recent incidents processed by AI</p>
                            <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Decision summaries</h2>
                        </div>
                        <span className="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">Pipeline healthy</span>
                    </div>
                    <div className="mt-5 space-y-4">
                        {[
                            <div key={item.id} className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                                <div className="flex items-start justify-between gap-4">
                                    <div>
                                        <p className="text-sm font-semibold text-slate-900">{item.id} · {item.property} Unit {item.unit}</p>
                                        <p className="mt-1 text-sm text-slate-500">{item.summary}</p>
                                    </div>
                                    <span className={"inline-flex rounded-full px-2.5 py-1 text-xs font-semibold " + urgency_classes(item.urgency)}>{item.urgency}</span>
                                </div>
                                <div className="mt-4 flex items-center gap-3 text-xs text-slate-500">
                                    <span>{item.category}</span>
                                    <span>•</span>
                                    <span>{item.latency}</span>
                                    <span>•</span>
                                    <span>{item.automation}</span>
                                </div>
                            </div>
                            for item in incidents
                        ]}
                    </div>
                </div>
            </div>
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Current live processing</p>
                    <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Now handling</h2>
                    <div className="mt-5 space-y-4">
                        <div className="rounded-[24px] bg-slate-950 p-5 text-white">
                            <div className="flex items-center justify-between gap-3">
                                <div>
                                    <p className="text-sm font-semibold">INC-24018 · Harbor Point Residences</p>
                                    <p className="mt-1 text-sm text-white/65">Owner alert prepared · awaiting approval</p>
                                </div>
                                <span className="rounded-full bg-white/10 px-3 py-1 text-xs font-semibold">11s</span>
                            </div>
                            <div className="mt-5 space-y-3">
                                <div className="h-2 rounded-full bg-white/10"><div className="h-2 w-[84%] rounded-full bg-blue-500"></div></div>
                                <div className="flex items-center justify-between text-xs text-white/55">
                                    <span>Workflow progress</span>
                                    <span>84%</span>
                                </div>
                            </div>
                        </div>
                        <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                            <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Event log</p>
                            <div className="mt-4 space-y-4 text-sm text-slate-600">
                                <div className="flex items-start justify-between gap-4"><span>10:14:02 · SMS received from property line HP-204</span><span className="text-emerald-600">ok</span></div>
                                <div className="flex items-start justify-between gap-4"><span>10:14:05 · Leak severity model returned high urgency</span><span className="text-emerald-600">ok</span></div>
                                <div className="flex items-start justify-between gap-4"><span>10:14:08 · Owner alert draft generated</span><span className="text-emerald-600">ok</span></div>
                                <div className="flex items-start justify-between gap-4"><span>10:14:11 · Awaiting manager approval state entered</span><span className="text-blue-600">live</span></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Escalation history</p>
                    <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Risk-aware decisions</h2>
                    <div className="mt-5 space-y-4">
                        <div className="rounded-[24px] border border-rose-200 bg-rose-50 p-5">
                            <p className="text-sm font-semibold text-rose-800">Electrical hazard escalation</p>
                            <p className="mt-2 text-sm leading-7 text-rose-700">Burning smell from outlet in Northline Flats Unit 12 triggered emergency electrician dispatch and tenant safety instructions.</p>
                        </div>
                        <div className="rounded-[24px] border border-amber-200 bg-amber-50 p-5">
                            <p className="text-sm font-semibold text-amber-800">Heating outage priority routing</p>
                            <p className="mt-2 text-sm leading-7 text-amber-700">No-heat incident in Cedar Grove Homes Unit 7 escalated under cold-weather SLA with preferred HVAC vendor shortlist.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

def demo_mode_view(incidents: list, selected: IncidentRecord, set_selected: any, scenario: str, set_scenario: any, incoming_text: str, set_incoming_text: any, demo_stage: int, set_demo_stage: any) -> JsxElement {
    scenario_message = (
        scenario == "Plumbing"
        and "The sink in Unit 4B is leaking and water is getting on the floor."
        or (scenario == "Electrical"
            and "There’s a burning smell coming from the outlet in apartment 12."
            or (scenario == "HVAC"
                and "My heat stopped working in Unit 7."
                or (scenario == "Appliance"
                    and "The fridge in Unit 9 is not cooling."
                    or (scenario == "Noise"
                        and "The upstairs neighbors are blasting music again."
                        or "There is water pouring from the ceiling in Unit 3A and it’s spreading fast."))))
    );

    progress_width = (
        demo_stage == 0 and "w-[12%]"
        or (demo_stage == 1 and "w-[34%]"
            or (demo_stage == 2 and "w-[58%]"
                or (demo_stage == 3 and "w-[82%]" or "w-full")))
    );

    return (
        <div className="grid grid-cols-[1fr_1fr] gap-6">
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Demo mode</p>
                    <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">Simulate inbound tenant texts</h1>
                    <p className="mt-3 text-sm leading-7 text-slate-600">Built for live demos before Twilio is connected. Inject realistic SMS scenarios, replay the AI workflow, and show status changes with confidence.</p>
                    <div className="mt-6 grid gap-4">
                        <div>
                            <label className="mb-2 block text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Scenario</label>
                            <select value={scenario} onChange={lambda e: any -> None { set_scenario(e.target.value); set_incoming_text(e.target.value == "Plumbing" and "The sink in Unit 4B is leaking and water is getting on the floor." or (e.target.value == "Electrical" and "There’s a burning smell coming from the outlet in apartment 12." or (e.target.value == "HVAC" and "My heat stopped working in Unit 7." or (e.target.value == "Appliance" and "The fridge in Unit 9 is not cooling." or (e.target.value == "Noise" and "The upstairs neighbors are blasting music again." or "There is water pouring from the ceiling in Unit 3A and it’s spreading fast."))))); }} className="h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-blue-400 focus:bg-white">
                                <option value="Plumbing">Plumbing leak</option>
                                <option value="Electrical">Electrical hazard</option>
                                <option value="HVAC">HVAC outage</option>
                                <option value="Appliance">Appliance issue</option>
                                <option value="Noise">Noise complaint</option>
                                <option value="Emergency">Emergency water intrusion</option>
                            </select>
                        </div>
                        <div>
                            <label className="mb-2 block text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Inbound text preview</label>
                            <textarea value={incoming_text} onChange={lambda e: any -> None { set_incoming_text(e.target.value); }} rows={6} className="w-full rounded-[24px] border border-slate-200 bg-slate-50 px-4 py-4 text-sm leading-7 text-slate-900 outline-none transition focus:border-blue-400 focus:bg-white"></textarea>
                        </div>
                        <div className="flex gap-3">
                            <button onClick={lambda -> None { set_demo_stage(0); }} className="h-11 rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 transition hover:bg-slate-50">Reset replay</button>
                            <button onClick={lambda -> None { set_demo_stage((demo_stage + 1) if demo_stage < 4 else 4); set_selected(incidents[0]); }} className="h-11 rounded-2xl bg-slate-950 px-5 text-sm font-semibold text-white transition hover:opacity-92">Advance workflow</button>
                        </div>
                    </div>
                </div>
                <div className={panel_classes() + " p-6"}>
                    <div className="flex items-center justify-between gap-4">
                        <div>
                            <p className="text-sm font-semibold text-slate-500">Replay progress</p>
                            <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">AI workflow playback</h2>
                        </div>
                        <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-700">Stage {demo_stage + 1} / 5</span>
                    </div>
                    <div className="mt-5 h-2 rounded-full bg-slate-100"><div className={"h-2 rounded-full bg-blue-600 transition-all duration-500 " + progress_width}></div></div>
                    <div className="mt-6 space-y-4">
                        <div className={"rounded-[24px] border p-4 " + (demo_stage >= 0 and "border-slate-200 bg-white" or "border-slate-100 bg-slate-50")}>
                            <p className="text-sm font-semibold text-slate-900">1. Message received</p>
                            <p className="mt-2 text-sm text-slate-600">Tenant text arrives on the property number and is attached to the correct building line.</p>
                        </div>
                        <div className={"rounded-[24px] border p-4 " + (demo_stage >= 1 and "border-slate-200 bg-white" or "border-slate-100 bg-slate-50")}>
                            <p className="text-sm font-semibold text-slate-900">2. AI parses and extracts details</p>
                            <p className="mt-2 text-sm text-slate-600">Unit, issue type, urgency signals, and phone metadata are normalized for the dashboard.</p>
                        </div>
                        <div className={"rounded-[24px] border p-4 " + (demo_stage >= 2 and "border-slate-200 bg-white" or "border-slate-100 bg-slate-50")}>
                            <p className="text-sm font-semibold text-slate-900">3. Triage decision generated</p>
                            <p className="mt-2 text-sm text-slate-600">Rentora classifies the incident, scores urgency, and recommends the next action.</p>
                        </div>
                        <div className={"rounded-[24px] border p-4 " + (demo_stage >= 3 and "border-slate-200 bg-white" or "border-slate-100 bg-slate-50")}>
                            <p className="text-sm font-semibold text-slate-900">4. Owner alert prepared</p>
                            <p className="mt-2 text-sm text-slate-600">A manager-ready notification is drafted with the right level of urgency and context.</p>
                        </div>
                        <div className={"rounded-[24px] border p-4 " + (demo_stage >= 4 and "border-slate-200 bg-white" or "border-slate-100 bg-slate-50")}>
                            <p className="text-sm font-semibold text-slate-900">5. Tenant reply ready or sent</p>
                            <p className="mt-2 text-sm text-slate-600">The tenant receives a professional response while the dashboard updates live.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div className="space-y-6">
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Scenario preview</p>
                    <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">{scenario}</h2>
                    <div className="mt-5 rounded-[24px] bg-slate-950 p-5 text-white">
                        <p className="text-xs uppercase tracking-[0.12em] text-white/50">Sample inbound text</p>
                        <p className="mt-3 text-base leading-7">{scenario_message}</p>
                    </div>
                    <div className="mt-5 grid gap-4">
                        <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                            <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Owner alert preview</p>
                            <p className="mt-3 text-sm leading-7 text-slate-700">{selected.owner_notification}</p>
                        </div>
                        <div className="rounded-[24px] border border-slate-200 bg-white p-5">
                            <p className="text-xs uppercase tracking-[0.12em] text-slate-400">Tenant reply preview</p>
                            <p className="mt-3 text-sm leading-7 text-slate-700">{selected.tenant_reply}</p>
                        </div>
                    </div>
                </div>
                <div className={panel_classes() + " p-6"}>
                    <p className="text-sm font-semibold text-slate-500">Demo-ready outcomes</p>
                    <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">What judges should see</h2>
                    <div className="mt-5 space-y-4 text-sm leading-7 text-slate-600">
                        <div className="rounded-[24px] border border-slate-200 bg-white p-4">Tenants text a property number with a real issue.</div>
                        <div className="rounded-[24px] border border-slate-200 bg-white p-4">AI triage extracts the unit, classifies the problem, and scores urgency.</div>
                        <div className="rounded-[24px] border border-slate-200 bg-white p-4">Property managers see the incident update live with owner-ready actions.</div>
                        <div className="rounded-[24px] border border-slate-200 bg-white p-4">Twilio can plug into the same event-driven UI later without redesign.</div>
                    </div>
                </div>
            </div>
        </div>
    );
}

def settings_view() -> JsxElement {
    return (
        <div className="grid grid-cols-[1fr_1fr] gap-6">
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Workspace settings</p>
                <h1 className="mt-1 text-3xl font-semibold tracking-[-0.04em] text-slate-950">Operational configuration</h1>
                <div className="mt-6 space-y-4">
                    <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                        <p className="text-sm font-semibold text-slate-900">Property intake numbers</p>
                        <p className="mt-2 text-sm leading-7 text-slate-600">Map Twilio numbers to properties, portfolios, or regional teams so inbound texts route into the correct incident stream.</p>
                    </div>
                    <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                        <p className="text-sm font-semibold text-slate-900">Escalation policies</p>
                        <p className="mt-2 text-sm leading-7 text-slate-600">Define emergency thresholds for electrical hazards, active leaks, no-heat incidents, and after-hours routing.</p>
                    </div>
                    <div className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
                        <p className="text-sm font-semibold text-slate-900">Notification templates</p>
                        <p className="mt-2 text-sm leading-7 text-slate-600">Keep owner alerts and tenant replies consistent, professional, and ready for approval workflows.</p>
                    </div>
                </div>
            </div>
            <div className={panel_classes() + " p-6"}>
                <p className="text-sm font-semibold text-slate-500">Integration readiness</p>
                <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">Twilio-ready architecture</h2>
                <div className="mt-6 space-y-4">
                    <div className="flex items-start justify-between rounded-[24px] border border-slate-200 bg-white p-5">
                        <div>
                            <p className="text-sm font-semibold text-slate-900">Inbound SMS webhook</p>
                            <p className="mt-2 text-sm leading-7 text-slate-600">Prepared for message body, sender number, property line, and timestamp metadata.</p>
                        </div>
                        <span className="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">Ready</span>
                    </div>
                    <div className="flex items-start justify-between rounded-[24px] border border-slate-200 bg-white p-5">
                        <div>
                            <p className="text-sm font-semibold text-slate-900">Live event stream</p>
                            <p className="mt-2 text-sm leading-7 text-slate-600">UI designed for real-time incident cards, status changes, and AI activity updates.</p>
                        </div>
                        <span className="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">Ready</span>
                    </div>
                    <div className="flex items-start justify-between rounded-[24px] border border-slate-200 bg-white p-5">
                        <div>
                            <p className="text-sm font-semibold text-slate-900">Owner approval state</p>
                            <p className="mt-2 text-sm leading-7 text-slate-600">Notification previews and tenant reply states are already modeled in the frontend.</p>
                        </div>
                        <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-700">Structured</span>
                    </div>
                </div>
            </div>
        </div>
    );
}

def:pub ClientApp() -> JsxElement {
    has current_view: str = "Dashboard";
    has incidents: list = sample_incidents();
    has selected_incident: IncidentRecord = sample_incidents()[0];
    has search: str = "";
    has urgency_filter: str = "All";
    has category_filter: str = "All";
    has scenario: str = "Plumbing";
    has incoming_text: str = "The sink in Unit 4B is leaking and water is getting on the floor.";
    has demo_stage: int = 0;

    def set_selected(item: IncidentRecord) -> None {
        selected_incident = item;
    }

    def content() -> JsxElement {
        if current_view == "Dashboard" {
            return dashboard_view(incidents, selected_incident, set_selected);
        }
        if current_view == "Incidents" {
            return incidents_view(incidents, selected_incident, set_selected, search, lambda value: str -> None { search = value; }, urgency_filter, lambda value: str -> None { urgency_filter = value; }, category_filter, lambda value: str -> None { category_filter = value; });
        }
        if current_view == "AI Activity" {
            return ai_activity_view(incidents);
        }
        if current_view == "Demo Mode" {
            return demo_mode_view(incidents, selected_incident, set_selected, scenario, lambda value: str -> None { scenario = value; }, incoming_text, lambda value: str -> None { incoming_text = value; }, demo_stage, lambda value: int -> None { demo_stage = value; });
        }
        return settings_view();
    }

    return (
        <div className="min-h-screen bg-transparent text-slate-950">
            <div className="mx-auto flex min-h-screen max-w-[1680px] gap-6 px-6 py-6">
                <aside className="sticky top-6 h-[calc(100vh-3rem)] w-[280px] rounded-[32px] border border-white/70 bg-white/82 p-5 shadow-[0_18px_50px_rgba(15,23,40,0.08)] backdrop-blur">
                    <div className="rounded-[28px] bg-slate-950 p-5 text-white shadow-[0_18px_40px_rgba(15,23,40,0.18)]">
                        <div className="flex items-center justify-between gap-3">
                            <div>
                                <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-white/55">Rentora</p>
                                <h1 className="mt-2 text-2xl font-semibold tracking-[-0.04em]">Property operations</h1>
                            </div>
                            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-white/10 text-lg font-semibold">R</div>
                        </div>
                        <p className="mt-4 text-sm leading-7 text-white/68">AI-powered maintenance triage for modern property teams.</p>
                    </div>
                    <div className="mt-6 space-y-2">
                        {sidebar_item("Dashboard", current_view == "Dashboard", lambda -> None { current_view = "Dashboard"; }, "Live")}
                        {sidebar_item("Incidents", current_view == "Incidents", lambda -> None { current_view = "Incidents"; }, "184")}
                        {sidebar_item("AI Activity", current_view == "AI Activity", lambda -> None { current_view = "AI Activity"; }, "94%")}
                        {sidebar_item("Demo Mode", current_view == "Demo Mode", lambda -> None { current_view = "Demo Mode"; }, "Ready")}
                        {sidebar_item("Settings", current_view == "Settings", lambda -> None { current_view = "Settings"; }, "Ops")}
                    </div>
                    <div className="mt-8 rounded-[28px] border border-slate-200 bg-slate-50 p-5">
                        <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-400">Portfolio snapshot</p>
                        <div className="mt-4 space-y-4">
                            <div>
                                <p className="text-sm font-semibold text-slate-900">42 active properties</p>
                                <p className="mt-1 text-sm text-slate-500">6 regional teams · 1 unified incident stream</p>
                            </div>
                            <div className="h-px bg-slate-200"></div>
                            <div>
                                <p className="text-sm font-semibold text-slate-900">9 urgent issues</p>
                                <p className="mt-1 text-sm text-slate-500">2 critical incidents currently escalated</p>
                            </div>
                        </div>
                    </div>
                    <div className="mt-auto pt-8">
                        <div className="rounded-[28px] border border-blue-100 bg-blue-50 p-5">
                            <p className="text-xs font-semibold uppercase tracking-[0.12em] text-blue-700">Demo narrative</p>
                            <p className="mt-3 text-sm leading-7 text-blue-900">Tenants text issues. Rentora triages instantly. Managers see the workflow live and act faster.</p>
                        </div>
                    </div>
                </aside>

                <main className="flex-1">
                    <header className={panel_classes() + " mb-6 px-6 py-5"}>
                        <div className="flex items-center justify-between gap-6">
                            <div>
                                <p className="text-sm font-semibold text-slate-500">Rentora workspace</p>
                                <h2 className="mt-1 text-2xl font-semibold tracking-[-0.03em] text-slate-950">{current_view}</h2>
                            </div>
                            <div className="flex items-center gap-3">
                                <div className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">Live SMS intake · healthy</div>
                                <div className="rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-600">Manager: Olivia Bennett</div>
                                <button className="rounded-2xl bg-slate-950 px-4 py-3 text-sm font-semibold text-white transition hover:opacity-92">Share demo</button>
                            </div>
                        </div>
                    </header>
                    {content()}
                </main>
            </div>
        </div>
    );
}
