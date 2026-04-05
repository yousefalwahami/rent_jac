with open("incidents.cl.jac", "r") as f:
    text = f.read()

if "cl import from .workflow { AiFlowDetailView }" not in text:
    text = "cl import from .workflow { AiFlowDetailView }\n" + text

with open("incidents.cl.jac", "w") as f:
    f.write(text)

