obj:pub IncidentStep {
    has label: str = "";
    has detail: str = "";
    has time: str = "";
    has state: str = "done";
}

obj:pub IncidentRecord {
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

def:pub status_classes(value: str) -> str {
    if value == "Resolved" { return "bg-emerald-50 text-emerald-700 border border-emerald-200"; }
    if value == "Owner reviewing" { return "bg-amber-50 text-amber-700 border border-amber-200"; }
    if value == "Dispatching vendor" { return "bg-blue-50 text-blue-700 border border-blue-200"; }
    return "bg-slate-100 text-slate-700 border border-slate-200";
}

def:pub urgency_classes(value: str) -> str {
    if value == "Critical" { return "bg-rose-50 text-rose-700 border border-rose-200"; }
    if value == "High" { return "bg-orange-50 text-orange-700 border border-orange-200"; }
    if value == "Medium" { return "bg-amber-50 text-amber-700 border border-amber-200"; }
    return "bg-slate-100 text-slate-700 border border-slate-200";
}

def:pub category_dot(value: str) -> str {
    if value == "Electrical" { return "bg-rose-500"; }
    if value == "Plumbing" { return "bg-sky-500"; }
    if value == "HVAC" { return "bg-violet-500"; }
    if value == "Appliance" { return "bg-emerald-500"; }
    if value == "Noise" { return "bg-amber-500"; }
    return "bg-slate-500";
}


def:pub empty_state(title: str, description: str, pulse: bool) -> JsxElement {
    return (
        <div className="flex flex-col items-center justify-center py-16 px-4 text-center rounded-sm border border-slate-200 border-dashed bg-slate-50/50">
            <div className="relative mb-4">
                <div className={"w-10 h-10 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center " + (pulse and "animate-pulse" or "")}>
                   <div className={"w-3 h-3 rounded-full " + (pulse and "bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.8)]" or "bg-slate-300")}></div>
                </div>
            </div>
            <h3 className="text-sm font-semibold text-slate-900">{title}</h3>
            <p className="mt-1 text-sm text-slate-500 max-w-sm">{description}</p>
        </div>
    );
}

def:pub nav_button_classes(active: bool) -> str {
    return (active and "bg-slate-100/80 text-slate-900 font-medium" or "text-slate-500 hover:bg-slate-50 hover:text-slate-900");
}

def:pub panel_classes() -> str {
    return "rounded-sm border border-slate-200 bg-white shadow-sm";
}

def:pub metric_card(title: str, value: str, delta: str, note: str) -> JsxElement {
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

def:pub sidebar_item(label: str, active: bool, on_click: any, meta: str) -> JsxElement {
    return (
        <button onClick={on_click} className={"w-full rounded-md px-4 py-3 text-left transition-all duration-200 " + nav_button_classes(active)}>
            <div className="flex items-center justify-between gap-3">
                <span className="text-sm font-semibold tracking-[-0.01em]">{label}</span>
                <span className={active and "text-white/70 text-xs" or "text-slate-400 text-xs"}>{meta}</span>
            </div>
        </button>
    );
}

def:pub incident_row(incident: IncidentRecord, active: bool, on_click: any) -> JsxElement {
    return (
        <button onClick={on_click} className={"flex flex-col gap-2 w-full text-left p-3 rounded-sm border transition-all duration-150 " + (active and "bg-indigo-50/50 border-indigo-200 shadow-sm" or "bg-white border-slate-200 hover:border-slate-300 hover:bg-slate-50")}>
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <span className={"w-2 h-2 rounded-full " + category_dot(incident.category)}></span>
                    <span className="text-sm font-semibold text-slate-900">{incident.tenant}</span>
                    <span className="text-xs text-slate-500 font-mono">{incident.id}</span>
                </div>
                <span className="text-xs text-slate-400">{incident.time}</span>
            </div>
            <div className="text-xs text-slate-600 mt-1 mb-2 truncate">
                {incident.message}
            </div>
            <div className="flex items-center justify-between text-xs">
                <div className="text-slate-600">
                    <span className="font-medium text-slate-700">{incident.property}</span>, Unit {incident.unit}
                </div>
                <div className="flex items-center gap-2">
                    <span className={"inline-flex justify-center uppercase tracking-wide border px-1.5 py-0.5 rounded text-[10px] font-bold " + urgency_classes(incident.urgency)}>{incident.urgency}</span>
                    <span className={"inline-flex justify-center border px-1.5 py-0.5 rounded text-[10px] font-semibold " + status_classes(incident.status)}>{incident.status}</span>
                </div>
            </div>
        </button>
    );
}

def:pub timeline_step(step: IncidentStep) -> JsxElement {
    return (
        <div className="flex gap-3">
            <div className="flex flex-col items-center">
                <span className={"mt-1 flex h-3.5 w-3.5 rounded-full border-2 border-white shadow " + (step.state == "live" and "bg-blue-600" or (step.state == "queued" and "bg-slate-300" or "bg-emerald-500"))}></span>
                <span className="mt-2 h-full w-px bg-slate-200"></span>
            </div>
            <div className="pb-5">
                <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold text-slate-900">{step.label}</p>
                    <span className={"rounded-full px-2 py-0.5 text-[11px] font-semibold uppercase tracking-[0.08em] " + (step.state == "live" and "bg-blue-50 text-blue-700" or (step.state == "queued" and "bg-slate-100 text-slate-500" or "bg-emerald-50 text-emerald-700"))}>{step.state}</span>
                </div>
                <p className="mt-1 text-sm leading-6 text-slate-500">{step.detail}</p>
                <p className="mt-2 text-xs font-medium text-slate-400">{step.time}</p>
            </div>
        </div>
    );
}

def:pub workflow_node(label: str, detail: str, state: str, active: bool) -> JsxElement {
    return (
        <div className={"relative w-44 rounded-[20px] border p-4 shadow-sm transition-all duration-500 " + (state == "complete" and "border-emerald-200 bg-emerald-50 text-emerald-900" or (state == "running" and "border-blue-400 bg-white ring-4 ring-blue-50 text-slate-900 shadow-md" or (state == "escalated" and "border-orange-300 bg-orange-50 text-orange-900" or "border-slate-200 bg-slate-50 text-slate-500")))}>
            <div className="flex justify-between">
                <span className={"flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold " + (state == "complete" and "bg-emerald-500 text-white" or (state == "running" and "bg-blue-500 text-white animate-pulse" or (state == "escalated" and "bg-orange-500 text-white" or "bg-slate-300 text-white")))}>
                    {state == "complete" and "✓" or (state == "running" and "↻" or (state == "escalated" and "!" or "·"))}
                </span>
            </div>
            <p className="mt-3 text-sm font-bold tracking-tight">{label}</p>
            <p className="mt-1 text-xs opacity-80">{detail}</p>
            {active and <div className="absolute -bottom-1 -right-1 flex h-3 w-3 items-center justify-center rounded-full bg-blue-500"><div className="h-full w-full animate-ping rounded-full bg-blue-400 opacity-75"></div></div>}
        </div>
    );
}

def:pub sample_incidents() -> list {
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

def:pub create_incident_record(id: str, time: str, message: str, phone: str, tenant: str, prop: str, unit: str, category: str, urgency: str, status: str, confidence: str, summary: str, owner_notification: str, property_code: str) -> IncidentRecord {
    return IncidentRecord(
        id=id,
        time=time,
        message=message,
        phone=phone,
        tenant=tenant,
        property=prop,
        unit=unit,
        category=category,
        urgency=urgency,
        status=status,
        confidence=confidence,
        summary=summary,
        owner_notification=owner_notification,
        property_code=property_code
    );
}
