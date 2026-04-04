import from "@jac/runtime" { jacIsLoggedIn, jacLogout }
cl import from .dashboard { dashboard_view }
cl import from .incidents { incidents_view }
cl import from .ai_activity { ai_activity_view }
cl import from .demo_mode { demo_mode_view }
cl import from .settings { settings_view }
cl import from .sms_inbox { SmsInboxView }
cl import from .login { LoginView }
cl import from .shared { nav_button_classes, sample_incidents, IncidentRecord }

def:pub ClientApp() -> JsxElement {
    has is_authenticated: bool = jacIsLoggedIn();
    has current_view: str = "Dashboard";
    has live_incidents: list = [];
    has demo_incidents: list = sample_incidents();
    has selected_incident: IncidentRecord = None;
    has search: str = "";
    has urgency_filter: str = "All";
    has category_filter: str = "All";
    has scenario: str = "Plumbing";
    has incoming_text: str = "The sink in Unit 4B is leaking and water is getting on the floor.";
    has demo_stage: int = 0;

    if not is_authenticated {
        return <LoginView on_auth_success={lambda -> None { is_authenticated = True; }} />;
    }

    def handle_logout() -> None {
        jacLogout();
        is_authenticated = False;
    }

    def set_selected(item: IncidentRecord) -> None {
        selected_incident = item;
    }

    def content() -> JsxElement {
        if current_view == "Dashboard" { return dashboard_view(live_incidents, selected_incident, set_selected); }
        if current_view == "Incidents" { return incidents_view(live_incidents, selected_incident, set_selected, search, lambda value: str -> None { search = value; }, urgency_filter, lambda value: str -> None { urgency_filter = value; }, category_filter, lambda value: str -> None { category_filter = value; }); }
        if current_view == "AI Activity" { return ai_activity_view(live_incidents, selected_incident, set_selected); }
        if current_view == "Demo Mode" { return demo_mode_view(demo_incidents, demo_incidents[0] if len(demo_incidents) > 0 else None, set_selected, scenario, lambda value: str -> None { scenario = value; }, incoming_text, lambda value: str -> None { incoming_text = value; }, demo_stage, lambda value: int -> None { demo_stage = value; }); }
        if current_view == "SMS Inbox" { return <SmsInboxView />; }
        return settings_view();
    }

    def sidebar_item(label: str, active: bool, on_click: any, meta: str) -> JsxElement {
        return (
            <button
                onClick={on_click}
                className={"flex w-full items-center justify-between rounded-md px-3 py-2 text-sm transition-colors border border-transparent " + (active and "bg-white text-slate-900 shadow-sm border-slate-200 font-medium" or "text-slate-600 hover:bg-slate-100 hover:text-slate-900")}
            >
                <span>{label}</span>
                {meta and (
                    <span className={"text-xs " + (active and "text-slate-500 font-medium" or "text-slate-400")}>
                        {meta}
                    </span>
                )}
            </button>
        );
    }

    return (
        <div className="flex h-screen w-full bg-slate-50 text-slate-900 font-sans overflow-hidden font-inter selection:bg-indigo-100 selection:text-indigo-900">
            
            <aside className="w-[260px] flex-shrink-0 border-r border-slate-200 bg-slate-50/50 flex flex-col justify-between">
                <div className="px-4 py-5">
                    
                    <div className="flex items-center gap-3 px-2 mb-6 cursor-pointer group">
                        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-slate-900 text-white text-sm font-semibold shadow-sm group-hover:bg-slate-800 transition-colors">
                            R
                        </div>
                        <div>
                            <h1 className="text-[14px] font-semibold tracking-tight text-slate-900">Rentora</h1>
                            <p className="text-[12px] text-slate-500 line-clamp-1">Production Environment</p>
                        </div>
                    </div>

                    
                    <div className="space-y-1">
                        {sidebar_item("Dashboard", current_view == "Dashboard", lambda -> None { current_view = "Dashboard"; }, "Live")}
                        {sidebar_item("Incidents", current_view == "Incidents", lambda -> None { current_view = "Incidents"; }, str(len(live_incidents)))}
                        {sidebar_item("AI Activity", current_view == "AI Activity", lambda -> None { current_view = "AI Activity"; }, "")}
                        {sidebar_item("Demo Mode", current_view == "Demo Mode", lambda -> None { current_view = "Demo Mode"; }, "")}
                        {sidebar_item("SMS Inbox", current_view == "SMS Inbox", lambda -> None { current_view = "SMS Inbox"; }, "Live")}
                        {sidebar_item("Settings", current_view == "Settings", lambda -> None { current_view = "Settings"; }, "")}
                    </div>

                    <div className="mt-8 px-2">
                        <h3 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-2">System</h3>
                        <div className="space-y-1">
                            <div className="flex w-full items-center justify-between rounded-md px-2 py-1.5 text-sm text-slate-600">
                                <div className="flex items-center gap-2">
                                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 shadow-[0_0_4px_rgba(16,185,129,0.8)] animate-pulse"></span>
                                    Twilio Webhook
                                </div>
                                <span className="text-xs text-slate-400 font-mono">OK</span>
                            </div>
                            <div className="flex w-full items-center justify-between rounded-md px-2 py-1.5 text-sm text-slate-600">
                                <div className="flex items-center gap-2">
                                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                    AI Parser
                                </div>
                                <span className="text-xs text-slate-400 font-mono">14ms</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="p-4 border-t border-slate-200/60">
                    <div className="flex items-center justify-between gap-2 px-2 py-2">
                        <div className="flex items-center gap-2 min-w-0">
                            <div className="w-7 h-7 rounded-full bg-slate-200 shrink-0 border border-slate-300"></div>
                            <p className="text-sm font-medium text-slate-900 truncate">Account</p>
                        </div>
                        <button
                            onClick={handle_logout}
                            className="text-xs font-medium text-slate-500 hover:text-slate-900 px-2 py-1 rounded-md hover:bg-slate-100 transition shrink-0"
                        >
                            Sign out
                        </button>
                    </div>
                </div>
            </aside>

            
            <main className="flex-1 flex flex-col min-w-0 bg-white">
                
                <header className="h-14 flex-shrink-0 border-b border-slate-200 flex items-center justify-between px-6 bg-white">
                    <div className="flex items-center gap-4">
                        <h2 className="text-sm font-medium text-slate-900">{current_view}</h2>
                        <span className="text-slate-300">/</span>
                        <div className="flex items-center gap-2">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 shadow-[0_0_6px_rgba(16,185,129,0.6)] animate-pulse"></span>
                            <span className="text-xs font-medium text-slate-600">All systems operational</span>
                        </div>
                    </div>
                    
                    <div className="flex items-center gap-3">
                        <button className="text-sm text-slate-600 hover:text-slate-900 font-medium px-2 py-1 rounded-md hover:bg-slate-50 transition">
                            Docs
                        </button>
                        <button className="text-sm text-slate-600 hover:text-slate-900 font-medium px-2 py-1 rounded-md hover:bg-slate-50 transition">
                            Support
                        </button>
                        <button className="h-8 px-3 inline-flex items-center justify-center rounded-md bg-slate-900 text-xs font-medium text-white shadow-sm hover:bg-slate-800 transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-900">
                            Share Demo
                        </button>
                    </div>
                </header>

                
                <div className="flex-1 overflow-y-auto">
                    {content()}
                </div>
            </main>
        </div>
    );
}
