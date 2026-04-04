cl import from shared { IncidentRecord, sample_incidents, sidebar_item, panel_classes }

cl import from .dashboard { dashboard_view }
cl import from .incidents { incidents_view }
cl import from .ai_activity { ai_activity_view }
cl import from .demo_mode { demo_mode_view }
cl import from .settings { settings_view }

def:pub ClientApp() -> JsxElement {
    has current_view: str = "Dashboard";
    has incidents: list = sample_incidents();
    has selected_incident: IncidentRecord = incidents[0];
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
        if current_view == "Dashboard" { return dashboard_view(incidents, selected_incident, set_selected); }
        if current_view == "Incidents" { return incidents_view(incidents, selected_incident, set_selected, search, lambda value: str -> None { search = value; }, urgency_filter, lambda value: str -> None { urgency_filter = value; }, category_filter, lambda value: str -> None { category_filter = value; }); }
        if current_view == "AI Activity" { return ai_activity_view(incidents, selected_incident, set_selected); }
        if current_view == "Demo Mode" { return demo_mode_view(incidents, selected_incident, set_selected, scenario, lambda value: str -> None { scenario = value; }, incoming_text, lambda value: str -> None { incoming_text = value; }, demo_stage, lambda value: int -> None { demo_stage = value; }); }
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
                        {sidebar_item("Incidents", current_view == "Incidents", lambda -> None { current_view = "Incidents"; }, str(len(incidents)))}
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
