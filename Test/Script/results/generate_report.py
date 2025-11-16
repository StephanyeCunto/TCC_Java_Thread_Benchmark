import os

OUTPUT = "report.html"

html = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Benchmark Report</title>
    <style>
        body { font-family: Arial; padding: 30px; }
        h1 { color: #444; }
        pre { background: #eee; padding: 20px; border-radius: 8px; }
    </style>
</head>
<body>
    <h1>Benchmark Report</h1>
    <p>Gerado automaticamente.</p>
    <h2>Logs</h2>
    <pre>
"""

# Lê todos os arquivos .txt da pasta results/logs/
logs_dir = "results/logs"

for filename in sorted(os.listdir(logs_dir)):
    if filename.endswith(".txt"):
        html += f"\n=== {filename} ===\n"
        with open(os.path.join(logs_dir, filename)) as f:
            html += f.read()

html += """
    </pre>
</body>
</html>
"""

with open(OUTPUT, "w") as f:
    f.write(html)

print(f"Relatório gerado em: {OUTPUT}")
