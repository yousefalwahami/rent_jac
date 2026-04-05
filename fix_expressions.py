import re

with open("workflow.cl.jac", "r") as f:
    text = f.read()

# Replace edge JSX attributes computation
old_edge = """                            d_path = "M " + p_x1 + " " + p_y1 + " C " + cp1_x + " " + p_y1 + ", " + cp2_x + " " + p_y2 + ", " + p_x2 + " " + p_y2;

                            return (
                                <g key={e["from"] + "-" + e["to"]}>
                                    <path 
                                        d={d_path}
                                        fill="none"
                                        stroke={active and (flowing and "#818cf8" or "#10b981") or "#1e293b"}
                                        strokeWidth={active and "2" or "1"}
                                        className={"transition-all duration-700 " + (flowing and "opacity-100" or (active and "opacity-60" or "opacity-20"))}
                                        strokeDasharray={flowing and "4 4" or "none"}
                                    />"""
                                    
new_edge = """                            d_path = "M " + p_x1 + " " + p_y1 + " C " + cp1_x + " " + p_y1 + ", " + cp2_x + " " + p_y2 + ", " + p_x2 + " " + p_y2;

                            stroke_color = "#1e293b";
                            if active { stroke_color = "#818cf8" if flowing else "#10b981"; }
                            stroke_w = "2" if active else "1";
                            class_n = "transition-all duration-700 opacity-100" if flowing else ("transition-all duration-700 opacity-60" if active else "transition-all duration-700 opacity-20");
                            dash_a = "4 4" if flowing else "none";

                            return (
                                <g key={e["from"] + "-" + e["to"]}>
                                    <path 
                                        d={d_path}
                                        fill="none"
                                        stroke={stroke_color}
                                        strokeWidth={stroke_w}
                                        className={class_n}
                                        strokeDasharray={dash_a}
                                    />"""
text = text.replace(old_edge, new_edge)

# Replace node JSX attributes computation
old_node = """                            <div 
                                key={n["id"]} 
                                onClick={lambda -> None { selected_node = n; }}
                                className={`absolute w-[200px] h-[90px] p-4 rounded-xl border flex flex-col justify-between cursor-pointer transition-all duration-700 backdrop-blur-xl hover:ring-1 hover:ring-indigo-500/50 ` + status_classes(n["status"]) + (n["status"] == 0 and " translate-y-4" or " translate-y-0")}
                                style={{ left: str(n["x"]) + "px", top: str(n["y"]) + "px" }}
                            >
                                <div className="flex items-center justify-between">
                                    <h4 className={"text-[11px] font-bold uppercase tracking-widest " + (n["status"] >= 1 and "text-white" or "text-slate-500")}>{n["label"]}</h4>
                                    <div className="flex gap-1 shrink-0 ml-2">
                                        {n["status"] == 1 and <span className="w-2 h-2 rounded-full bg-indigo-400 animate-ping"></span>}
                                        {n["status"] == 2 and <span className="w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399]"></span>}
                                        {n["status"] == 3 and <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse shadow-[0_0_8px_#fbbf24]"></span>}
                                    </div>
                                </div>
                                
                                <div className={"h-[2px] w-full bg-gradient-to-r rounded overflow-hidden mt-1 " + (n["status"] == 1 and "from-indigo-500 to-indigo-900" or (n["status"] == 2 and "from-emerald-500 to-teal-800" or "from-slate-800 to-transparent bg-slate-800"))}>
                                    {n["status"] == 1 and <div className="h-full w-1/3 bg-white/60 animate-[slide_1.5s_ease-in-out_infinite]"></div>}
                                </div>

                                <div className={"absolute -bottom-4 translate-y-0 left-1/2 -translate-x-1/2 whitespace-nowrap px-2.5 py-0.5 rounded shadow-lg border text-[10px] font-mono transition-all duration-700 " + (n["status"] == 2 and "bg-emerald-500/10 border-emerald-500/20 text-emerald-400 opacity-100" or (n["status"] == 3 and "bg-amber-500/10 border-amber-500/20 text-amber-400 opacity-100" or "opacity-0 -translate-y-2 pointer-events-none"))}>"""
                                
new_node = """                            node_classes = "absolute w-[200px] h-[90px] p-4 rounded-xl border flex flex-col justify-between cursor-pointer transition-all duration-700 backdrop-blur-xl hover:ring-1 hover:ring-indigo-500/50 " + status_classes(n["status"]) + (" translate-y-4" if n["status"] == 0 else " translate-y-0");
                            label_classes = "text-[11px] font-bold uppercase tracking-widest " + ("text-white" if n["status"] >= 1 else "text-slate-500");
                            bar_classes = "h-[2px] w-full bg-gradient-to-r rounded overflow-hidden mt-1 " + ("from-indigo-500 to-indigo-900" if n["status"] == 1 else ("from-emerald-500 to-teal-800" if n["status"] == 2 else "from-slate-800 to-transparent bg-slate-800"));
                            output_classes = "absolute -bottom-4 translate-y-0 left-1/2 -translate-x-1/2 whitespace-nowrap px-2.5 py-0.5 rounded shadow-lg border text-[10px] font-mono transition-all duration-700 " + ("bg-emerald-500/10 border-emerald-500/20 text-emerald-400 opacity-100" if n["status"] == 2 else ("bg-amber-500/10 border-amber-500/20 text-amber-400 opacity-100" if n["status"] == 3 else "opacity-0 -translate-y-2 pointer-events-none"));
                            
                            return (
                                <div 
                                    key={n["id"]} 
                                    onClick={lambda -> None { selected_node = n; }}
                                    className={node_classes}
                                    style={{ left: str(n["x"]) + "px", top: str(n["y"]) + "px" }}
                                >
                                    <div className="flex items-center justify-between">
                                        <h4 className={label_classes}>{n["label"]}</h4>
                                        <div className="flex gap-1 shrink-0 ml-2">
                                            {n["status"] == 1 and <span className="w-2 h-2 rounded-full bg-indigo-400 animate-ping"></span>}
                                            {n["status"] == 2 and <span className="w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399]"></span>}
                                            {n["status"] == 3 and <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse shadow-[0_0_8px_#fbbf24]"></span>}
                                        </div>
                                    </div>
                                    
                                    <div className={bar_classes}>
                                        {n["status"] == 1 and <div className="h-full w-1/3 bg-white/60 animate-[slide_1.5s_ease-in-out_infinite]"></div>}
                                    </div>

                                    <div className={output_classes}>"""
text = text.replace(old_node, new_node)

with open("workflow.cl.jac", "w") as f:
    f.write(text)
