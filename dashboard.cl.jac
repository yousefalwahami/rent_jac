cl import from shared { IncidentRecord, metric_card, panel_classes, incident_row, urgency_classes, timeline_step }

def:pub dashboard_view(incidents: list, selected: IncidentRecord, set_selected: any) -> JsxElement {
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
                        </div>
                    </div>
                    <div className={panel_classes() + " p-6"}>
                        <div className="flex items-center justify-between gap-4">
                            <div>
                                <p className="text-sm font-semibold text-slate-500">AI activity timeline</p>
                                <h3 className="mt-1 text-xl font-semibold tracking-[-0.03em] text-slate-950">Visible, live, and demo-ready</h3>
                            </div>
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
