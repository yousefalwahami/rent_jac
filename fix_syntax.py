import re

with open("workflow.cl.jac", "r") as f:
    text = f.read()

# Fix the nested return
bad_block = """                        return (
                            node_classes = "absolute w-[200px] h-[90px] p-4 rounded-xl border flex flex-col justify-between cursor-pointer transition-all duration-700 backdrop-blur-xl hover:ring-1 hover:ring-indigo-500/50 " + status_classes(n["status"]) + (" translate-y-4" if n["status"] == 0 else " translate-y-0");
                            label_classes = "text-[11px] font-bold uppercase tracking-widest " + ("text-white" if n["status"] >= 1 else "text-slate-500");
                            bar_classes = "h-[2px] w-full bg-gradient-to-r rounded overflow-hidden mt-1 " + ("from-indigo-500 to-indigo-900" if n["status"] == 1 else ("from-emerald-500 to-teal-800" if n["status"] == 2 else "from-slate-800 to-transparent bg-slate-800"));
                            output_classes = "absolute -bottom-4 translate-y-0 left-1/2 -translate-x-1/2 whitespace-nowrap px-2.5 py-0.5 rounded shadow-lg border text-[10px] font-mono transition-all duration-700 " + ("bg-emerald-500/10 border-emerald-500/20 text-emerald-400 opacity-100" if n["status"] == 2 else ("bg-amber-500/10 border-amber-500/20 text-amber-400 opacity-100" if n["status"] == 3 else "opacity-0 -translate-y-2 pointer-events-none"));
                            
                            return ("""
                            
good_block = """                        node_classes = "absolute w-[200px] h-[90px] p-4 rounded-xl border flex flex-col justify-between cursor-pointer transition-all duration-700 backdrop-blur-xl hover:ring-1 hover:ring-indigo-500/50 " + status_classes(n["status"]) + (" translate-y-4" if n["status"] == 0 else " translate-y-0");
                        label_classes = "text-[11px] font-bold uppercase tracking-widest " + ("text-white" if n["status"] >= 1 else "text-slate-500");
                        bar_classes = "h-[2px] w-full bg-gradient-to-r rounded overflow-hidden mt-1 " + ("from-indigo-500 to-indigo-900" if n["status"] == 1 else ("from-emerald-500 to-teal-800" if n["status"] == 2 else "from-slate-800 to-transparent bg-slate-800"));
                        output_classes = "absolute -bottom-4 translate-y-0 left-1/2 -translate-x-1/2 whitespace-nowrap px-2.5 py-0.5 rounded shadow-lg border text-[10px] font-mono transition-all duration-700 " + ("bg-emerald-500/10 border-emerald-500/20 text-emerald-400 opacity-100" if n["status"] == 2 else ("bg-amber-500/10 border-amber-500/20 text-amber-400 opacity-100" if n["status"] == 3 else "opacity-0 -translate-y-2 pointer-events-none"));
                        
                        return ("""

text = text.replace(bad_block, good_block)

# Fix the style tag backticks
old_style = """            <style>{`
                @keyframes slide {
                    0% { transform: translateX(-100%); }
                    100% { transform: translateX(300%); }
                }
                @keyframes slideLeft {
                    from { transform: translateX(100%); }
                    to { transform: translateX(0); }
                }
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(10px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                ::-webkit-scrollbar { width: 8px; height: 8px; }
                ::-webkit-scrollbar-track { background: transparent; }
                ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.05); border-radius: 4px; }
                ::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.1); }
            `}</style>"""

new_style = """            <style>
                {".custom-scrollbar::-webkit-scrollbar { width: 8px; height: 8px; } 
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; } 
                .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.05); border-radius: 4px; } 
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.1); }
                @keyframes slide { 0% { transform: translateX(-100%); } 100% { transform: translateX(300%); } }
                @keyframes slideLeft { from { transform: translateX(100%); } to { transform: translateX(0); } }
                @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }"}
            </style>"""

text = text.replace(old_style, new_style)

with open("workflow.cl.jac", "w") as f:
    f.write(text)

