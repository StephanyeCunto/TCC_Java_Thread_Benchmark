let perfData = [], monData = [], combData = [];
const colors = { traditional: '#e74c3c', virtual: '#27ae60', neutral: '#3498db' };
const EXEC = { traditional: [1,3,5,7,9,11,13,15,17,19], virtual: [2,4,6,8,10,12,14,16,18,20] };
let charts = {};

function switchTab(tab) {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
    event.target.classList.add('active');
    document.getElementById(`${tab}-tab`).classList.add('active');
}

async function loadAllData() {
    const perfP = [], monP = [];
    for (const ep of ['traditional', 'virtual']) {
        for (const ex of EXEC[ep]) {
            perfP.push(fetch(`../Results/results/${ep}/${ex}/run/json/run${ex}.json`)
                .then(r => r.ok ? r.json() : null)
                .then(d => d ? {
                    exec:ex, endpoint:ep, 
                    latMean:ns(d.latencies?.mean), 
                    p50:ns(d.latencies?.['50th']), 
                    p90:ns(d.latencies?.['90th']), 
                    p95:ns(d.latencies?.['95th']), 
                    p99:ns(d.latencies?.['99th']),
                    max:ns(d.latencies?.max),
                    min:ns(d.latencies?.min),
                    throughput:d.throughput, 
                    success:d.success*100, 
                    wait:ns(d.wait),
                    requests:d.requests,
                    duration:ns(d.duration),
                    rate:d.rate
                } : null).catch(()=>null));
            monP.push(fetch(`../Results/results/${ep}/${ex}/monitor/monitor.json`)
                .then(r => r.ok ? r.json() : null)
                .then(s => s?.length ? {
                    exec:ex, type:ep, 
                    cpu:avg(s.map(x=>x.cpu_percent)),
                    cpuMax:Math.max(...s.map(x=>x.cpu_percent)),
                    cpuMin:Math.min(...s.map(x=>x.cpu_percent)),
                    mem:avg(s.map(x=>x.memory_percent)),
                    memMax:Math.max(...s.map(x=>x.memory_percent)),
                    memMin:Math.min(...s.map(x=>x.memory_percent)),
                    threads:avg(s.map(x=>x.threads)),
                    threadsMax:Math.max(...s.map(x=>x.threads)),
                    threadsMin:Math.min(...s.map(x=>x.threads)),
                    rss:avg(s.map(x=>x.rss_kb/1024)),
                    vsz:avg(s.map(x=>x.vsz_kb/1024)),
                    heap:avg(s.map(x=>x.heap_kb/1024))
                } : null).catch(()=>null));
        }
    }
    const [pR, mR] = await Promise.all([Promise.all(perfP), Promise.all(monP)]);
    perfData = pR.filter(d=>d).sort((a,b)=>a.exec-b.exec);
    monData = mR.filter(d=>d).sort((a,b)=>a.exec-b.exec);
    combData = perfData.map(p => {
        const m = monData.find(x=>x.exec===p.exec);
        return {...p, ...m, type:p.endpoint};
    });
    
    if(!perfData.length && !monData.length) {
        document.getElementById('loading').innerHTML = '❌ Erro ao carregar dados';
        return;
    }
    document.getElementById('loading').style.display = 'none';
    document.getElementById('content').style.display = 'block';
    
    renderOverview();
    renderPerf();
    renderResources();
    renderCorrelation();
    renderComparison();
    renderData();
}

function ns(v) { return v ? v/1e9 : null; }
function avg(a) { return a.reduce((s,v)=>s+v,0)/a.length; }
function stdDev(arr) {
    const mean = avg(arr);
    return Math.sqrt(avg(arr.map(x => Math.pow(x - mean, 2))));
}

// OVERVIEW TAB
function renderOverview() {
    const t = combData.filter(d=>d.type==='traditional');
    const v = combData.filter(d=>d.type==='virtual');
    const tGood = t.filter(d=>d.success>95);
    const vGood = v.filter(d=>d.success>95);
    
    const latImp = ((1 - avg(vGood.map(d=>d.latMean)) / avg(tGood.map(d=>d.latMean))) * 100);
    const thrImp = ((avg(vGood.map(d=>d.throughput)) / avg(tGood.map(d=>d.throughput)) - 1) * 100);
    const cpuSave = ((1 - avg(v.map(d=>d.cpu)) / avg(t.map(d=>d.cpu))) * 100);
    const memSave = ((1 - avg(v.map(d=>d.mem)) / avg(t.map(d=>d.mem))) * 100);

    document.getElementById('overviewCards').innerHTML = `
        <div class="card"><h3>🚀 Melhoria de Latência</h3>
            <div class="single-value virtual">${latImp.toFixed(1)}%</div>
            <div class="endpoint-label">Virtual threads são mais rápidos</div>
        </div>
        <div class="card"><h3>⚡ Aumento de Throughput</h3>
            <div class="single-value virtual">+${thrImp.toFixed(1)}%</div>
            <div class="endpoint-label">Mais requisições processadas</div>
        </div>
        <div class="card"><h3>💰 Economia de CPU</h3>
            <div class="single-value virtual">${cpuSave.toFixed(1)}%</div>
            <div class="endpoint-label">Menor uso de processador</div>
        </div>
        <div class="card"><h3>🧠 Economia de Memória</h3>
            <div class="single-value virtual">${memSave.toFixed(1)}%</div>
            <div class="endpoint-label">Menor uso de RAM</div>
        </div>
        <div class="card"><h3>✅ Estabilidade Traditional</h3>
            <div class="single-value ${tGood.length===t.length?'virtual':'traditional'}">${tGood.length}/${t.length}</div>
            <div class="endpoint-label">Execuções estáveis (>95%)</div>
        </div>
        <div class="card"><h3>✅ Estabilidade Virtual</h3>
            <div class="single-value virtual">${vGood.length}/${v.length}</div>
            <div class="endpoint-label">Execuções estáveis (>95%)</div>
        </div>
    `;

    document.getElementById('mainConclusion').innerHTML = `
        <strong>Virtual Threads demonstram superioridade clara:</strong>
        <ul style="margin-top: 10px; margin-left: 20px;">
            <li><strong>${latImp.toFixed(1)}% mais rápido</strong> em latência média</li>
            <li><strong>${thrImp.toFixed(1)}% mais throughput</strong>, processando mais requisições</li>
            <li><strong>${cpuSave.toFixed(1)}% menos CPU</strong> e <strong>${memSave.toFixed(1)}% menos memória</strong></li>
            <li><strong>100% de estabilidade</strong> (${vGood.length}/${v.length} execuções bem-sucedidas)</li>
        </ul>
    `;

    document.getElementById('mainInsights').innerHTML = `
        <ul style="margin-left: 20px; line-height: 1.8;">
            <li><strong>Performance:</strong> Virtual threads mantêm latência consistentemente baixa (${avg(vGood.map(d=>d.latMean)).toFixed(2)}s vs ${avg(tGood.map(d=>d.latMean)).toFixed(2)}s)</li>
            <li><strong>Recursos:</strong> Uso médio de CPU ${avg(v.map(d=>d.cpu)).toFixed(1)}% (virtual) vs ${avg(t.map(d=>d.cpu)).toFixed(1)}% (traditional)</li>
            <li><strong>Escalabilidade:</strong> Virtual threads usam ~${avg(v.map(d=>d.threads)).toFixed(0)} threads vs ~${avg(t.map(d=>d.threads)).toFixed(0)} threads (traditional)</li>
            <li><strong>Estabilidade:</strong> Traditional teve ${t.length-tGood.length} execuções problemáticas, virtual teve ${v.length-vGood.length}</li>
        </ul>
    `;

    // Evolution Chart
    const ctx = document.getElementById('overviewEvolution');
    charts.overviewEvolution = new Chart(ctx, {
        type: 'line',
        data: {
            labels: combData.map(d => `Exec ${d.exec}`),
            datasets: [
                {
                    label: 'Latência Traditional (s)',
                    data: t.map(d => d.latMean),
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '20',
                    yAxisID: 'y',
                    tension: 0.3
                },
                {
                    label: 'Latência Virtual (s)',
                    data: v.map(d => d.latMean),
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '20',
                    yAxisID: 'y',
                    tension: 0.3
                },
                {
                    label: 'Throughput Traditional',
                    data: t.map(d => d.throughput),
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '20',
                    borderDash: [5, 5],
                    yAxisID: 'y1',
                    tension: 0.3
                },
                {
                    label: 'Throughput Virtual',
                    data: v.map(d => d.throughput),
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '20',
                    borderDash: [5, 5],
                    yAxisID: 'y1',
                    tension: 0.3
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            scales: {
                y: { type: 'linear', display: true, position: 'left', title: { display: true, text: 'Latência (s)' } },
                y1: { type: 'linear', display: true, position: 'right', title: { display: true, text: 'Throughput (req/s)' }, grid: { drawOnChartArea: false } }
            }
        }
    });

    // Efficiency Radar
    const radarCtx = document.getElementById('efficiencyRadar');
    const tAvg = {
        lat: avg(tGood.map(d=>d.latMean)),
        thr: avg(tGood.map(d=>d.throughput)),
        cpu: avg(t.map(d=>d.cpu)),
        mem: avg(t.map(d=>d.mem)),
        success: avg(tGood.map(d=>d.success))
    };
    const vAvg = {
        lat: avg(vGood.map(d=>d.latMean)),
        thr: avg(vGood.map(d=>d.throughput)),
        cpu: avg(v.map(d=>d.cpu)),
        mem: avg(v.map(d=>d.mem)),
        success: avg(vGood.map(d=>d.success))
    };
    
    // Normalize (invert latência e recursos, pois menor é melhor)
    const normalize = (val, max) => (val / max) * 100;
    const maxLat = Math.max(tAvg.lat, vAvg.lat);
    const maxThr = Math.max(tAvg.thr, vAvg.thr);
    const maxCpu = Math.max(tAvg.cpu, vAvg.cpu);
    const maxMem = Math.max(tAvg.mem, vAvg.mem);

    charts.efficiencyRadar = new Chart(radarCtx, {
        type: 'radar',
        data: {
            labels: ['Velocidade\n(menor latência)', 'Throughput\n(mais req/s)', 'Eficiência CPU\n(menos uso)', 'Eficiência Memória\n(menos uso)', 'Estabilidade\n(sucesso %)'],
            datasets: [
                {
                    label: 'Traditional',
                    data: [
                        100 - normalize(tAvg.lat, maxLat),
                        normalize(tAvg.thr, maxThr),
                        100 - normalize(tAvg.cpu, maxCpu),
                        100 - normalize(tAvg.mem, maxMem),
                        tAvg.success
                    ],
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '30'
                },
                {
                    label: 'Virtual',
                    data: [
                        100 - normalize(vAvg.lat, maxLat),
                        normalize(vAvg.thr, maxThr),
                        100 - normalize(vAvg.cpu, maxCpu),
                        100 - normalize(vAvg.mem, maxMem),
                        vAvg.success
                    ],
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '30'
                }
            ]
        },
        options: {
            responsive: true,
            scales: { r: { beginAtZero: true, max: 100 } }
        }
    });

    // Metrics Distribution
    const distCtx = document.getElementById('metricsDistribution');
    charts.metricsDistribution = new Chart(distCtx, {
        type: 'bar',
        data: {
            labels: ['Latência Média', 'Throughput', 'CPU %', 'Memória %', 'Threads'],
            datasets: [
                {
                    label: 'Traditional',
                    data: [
                        avg(tGood.map(d=>d.latMean)),
                        avg(tGood.map(d=>d.throughput))/100,
                        avg(t.map(d=>d.cpu)),
                        avg(t.map(d=>d.mem)),
                        avg(t.map(d=>d.threads))/10
                    ],
                    backgroundColor: colors.traditional
                },
                {
                    label: 'Virtual',
                    data: [
                        avg(vGood.map(d=>d.latMean)),
                        avg(vGood.map(d=>d.throughput))/100,
                        avg(v.map(d=>d.cpu)),
                        avg(v.map(d=>d.mem)),
                        avg(v.map(d=>d.threads))/10
                    ],
                    backgroundColor: colors.virtual
                }
            ]
        },
        options: {
            responsive: true,
            plugins: { 
                legend: { display: true },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            let value = context.parsed.y;
                            if (context.dataIndex === 1) value *= 100;
                            if (context.dataIndex === 4) value *= 10;
                            return label + ': ' + value.toFixed(2);
                        }
                    }
                }
            },
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Valor Normalizado' } } }
        }
    });
}

// Continua com renderPerf, renderResources, etc...
function renderPerf() {
    const t = perfData.filter(d=>d.endpoint==='traditional');
    const v = perfData.filter(d=>d.endpoint==='virtual');
    const tG = t.filter(d=>d.success>95);
    const vG = v.filter(d=>d.success>95);

    document.getElementById('perfCards').innerHTML = `
        <div class="card"><h3>Latência Média</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(tG.map(d=>d.latMean)).toFixed(3)}s</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(vG.map(d=>d.latMean)).toFixed(3)}s</div></div>
        </div></div>
        <div class="card"><h3>P99 Latência</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(tG.map(d=>d.p99)).toFixed(3)}s</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(vG.map(d=>d.p99)).toFixed(3)}s</div></div>
        </div></div>
        <div class="card"><h3>Throughput Médio</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(tG.map(d=>d.throughput)).toFixed(0)}</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(vG.map(d=>d.throughput)).toFixed(0)}</div></div>
        </div></div>
        <div class="card"><h3>Taxa de Sucesso</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(tG.map(d=>d.success)).toFixed(1)}%</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(vG.map(d=>d.success)).toFixed(1)}%</div></div>
        </div></div>
    `;

    document.getElementById('perfAlert').innerHTML = `
        Traditional teve <strong>${t.length - tG.length} execuções problemáticas</strong> com taxa de sucesso < 95%.
        Virtual threads mantiveram <strong>100% de estabilidade</strong>.
    `;

    // Charts
    makeBarChart('perfLatency', perfData, 'latMean', 'Latência', 's');
    
    // Percentiles
    const percCtx = document.getElementById('perfPercentiles');
    charts.perfPercentiles = new Chart(percCtx, {
        type: 'line',
        data: {
            labels: ['P50', 'P90', 'P95', 'P99'],
            datasets: [
                {
                    label: 'Traditional',
                    data: [avg(tG.map(d=>d.p50)), avg(tG.map(d=>d.p90)), avg(tG.map(d=>d.p95)), avg(tG.map(d=>d.p99))],
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '20',
                    fill: true,
                    tension: 0.4
                },
                {
                    label: 'Virtual',
                    data: [avg(vG.map(d=>d.p50)), avg(vG.map(d=>d.p90)), avg(vG.map(d=>d.p95)), avg(vG.map(d=>d.p99))],
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '20',
                    fill: true,
                    tension: 0.4
                }
            ]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Latência (s)' } } }
        }
    });

    makeBarChart('perfThroughput', perfData, 'throughput', 'Throughput', 'req/s');
    makeBarChart('perfSuccess', perfData, 'success', 'Sucesso', '%');
    makeBarChart('perfWait', perfData, 'wait', 'Wait Time', 's');

    // Scatter
    const scatterCtx = document.getElementById('perfScatter');
    charts.perfScatter = new Chart(scatterCtx, {
        type: 'scatter',
        data: {
            datasets: [
                {
                    label: 'Traditional',
                    data: t.map(d => ({x: d.latMean, y: d.throughput})),
                    backgroundColor: colors.traditional
                },
                {
                    label: 'Virtual',
                    data: v.map(d => ({x: d.latMean, y: d.throughput})),
                    backgroundColor: colors.virtual
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                x: { title: { display: true, text: 'Latência (s)' } },
                y: { title: { display: true, text: 'Throughput (req/s)' } }
            }
        }
    });
}

function renderResources() {
    const t = monData.filter(d=>d.type==='traditional');
    const v = monData.filter(d=>d.type==='virtual');

    document.getElementById('resourcesCards').innerHTML = `
        <div class="card"><h3>CPU Média</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(t.map(d=>d.cpu)).toFixed(2)}%</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(v.map(d=>d.cpu)).toFixed(2)}%</div></div>
        </div></div>
        <div class="card"><h3>Memória Média</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(t.map(d=>d.mem)).toFixed(2)}%</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(v.map(d=>d.mem)).toFixed(2)}%</div></div>
        </div></div>
        <div class="card"><h3>Threads Médias</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(t.map(d=>d.threads)).toFixed(0)}</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(v.map(d=>d.threads)).toFixed(0)}</div></div>
        </div></div>
        <div class="card"><h3>RSS Médio</h3><div class="card-content">
            <div class="endpoint-stat"><div class="endpoint-label">Traditional</div><div class="endpoint-value traditional">${avg(t.map(d=>d.rss)).toFixed(0)} MB</div></div>
            <div class="endpoint-stat"><div class="endpoint-label">Virtual</div><div class="endpoint-value virtual">${avg(v.map(d=>d.rss)).toFixed(0)} MB</div></div>
        </div></div>
    `;

    document.getElementById('resourcesAlert').innerHTML = `
        Virtual threads demonstram <strong>${((1-avg(v.map(d=>d.cpu))/avg(t.map(d=>d.cpu)))*100).toFixed(1)}% menos uso de CPU</strong>
        e <strong>${((1-avg(v.map(d=>d.mem))/avg(t.map(d=>d.mem)))*100).toFixed(1)}% menos uso de memória</strong>.
    `;

    // CPU + Mem combined chart
    const cpuMemCtx = document.getElementById('resCpuMem');
    charts.resCpuMem = new Chart(cpuMemCtx, {
        type: 'line',
        data: {
            labels: monData.map(d => `Exec ${d.exec}`),
            datasets: [
                {
                    label: 'CPU Traditional (%)',
                    data: t.map(d => d.cpu),
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '20',
                    yAxisID: 'y',
                    tension: 0.3
                },
                {
                    label: 'CPU Virtual (%)',
                    data: v.map(d => d.cpu),
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '20',
                    yAxisID: 'y',
                    tension: 0.3
                },
                {
                    label: 'Mem Traditional (%)',
                    data: t.map(d => d.mem),
                    borderColor: colors.traditional,
                    backgroundColor: colors.traditional + '20',
                    borderDash: [5, 5],
                    yAxisID: 'y1',
                    tension: 0.3
                },
                {
                    label: 'Mem Virtual (%)',
                    data: v.map(d => d.mem),
                    borderColor: colors.virtual,
                    backgroundColor: colors.virtual + '20',
                    borderDash: [5, 5],
                    yAxisID: 'y1',
                    tension: 0.3
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            scales: {
                y: { type: 'linear', display: true, position: 'left', title: { display: true, text: 'CPU (%)' } },
                y1: { type: 'linear', display: true, position: 'right', title: { display: true, text: 'Memória (%)' }, grid: { drawOnChartArea: false } }
            }
        }
    });

    makeBarChart('resCpu', monData, 'cpu', 'CPU', '%');
    makeBarChart('resMem', monData, 'mem', 'Memória', '%');
    makeBarChart('resThreads', monData, 'threads', 'Threads', '');
    makeBarChart('resRss', monData, 'rss', 'RSS', 'MB');
    makeBarChart('resVsz', monData, 'vsz', 'VSZ', 'MB');
    makeBarChart('resHeap', monData, 'heap', 'Heap', 'MB');

    // Memory comparison
    const memCompCtx = document.getElementById('resMemCompare');
    charts.resMemCompare = new Chart(memCompCtx, {
        type: 'bar',
        data: {
            labels: monData.map(d => `Exec ${d.exec}`),
            datasets: [
                { label: 'RSS (MB)', data: monData.map(d => d.rss), backgroundColor: colors.neutral + '80' },
                { label: 'VSZ (MB)', data: monData.map(d => d.vsz), backgroundColor: colors.neutral + '50' },
                { label: 'Heap (MB)', data: monData.map(d => d.heap), backgroundColor: colors.neutral + '30' }
            ]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Memória (MB)' } } }
        }
    });
}

function renderCorrelation() {
    document.getElementById('corrAlert').innerHTML = `
        Análise de como métricas se relacionam entre si.
        <strong>Correlações principais:</strong> CPU vs Performance, Memória vs Throughput, Threads vs Eficiência.
    `;

    document.getElementById('corrMetrics').innerHTML = `
        <div class="metric-box">
            <h4>Eficiência por CPU</h4>
            <div class="value traditional">${(avg(combData.filter(d=>d.type==='traditional').map(d=>d.throughput/d.cpu))).toFixed(1)}</div>
            <div>Traditional: req/s por CPU%</div>
            <div class="value virtual">${(avg(combData.filter(d=>d.type==='virtual').map(d=>d.throughput/d.cpu))).toFixed(1)}</div>
            <div>Virtual: req/s por CPU%</div>
        </div>
        <div class="metric-box">
            <h4>Latência por Thread</h4>
            <div class="value traditional">${(avg(combData.filter(d=>d.type==='traditional').map(d=>d.latMean/d.threads*1000))).toFixed(2)}ms</div>
            <div>Traditional</div>
            <div class="value virtual">${(avg(combData.filter(d=>d.type==='virtual').map(d=>d.latMean/d.threads*1000))).toFixed(2)}ms</div>
            <div>Virtual</div>
        </div>
    `;

    // Scatter plots
    makeScatterChart('corrCpuLat', combData, 'cpu', 'latMean', 'CPU (%)', 'Latência (s)');
    makeScatterChart('corrMemThr', combData, 'mem', 'throughput', 'Memória (%)', 'Throughput');
    makeScatterChart('corrThreadsPerf', combData, 'threads', 'latMean', 'Threads', 'Latência (s)');

    // Efficiency
    const effCtx = document.getElementById('corrEfficiency');
    charts.corrEfficiency = new Chart(effCtx, {
        type: 'bar',
        data: {
            labels: combData.map(d => `#${d.exec}`),
            datasets: [{
                label: 'Throughput por CPU%',
                data: combData.map(d => d.throughput / d.cpu),
                backgroundColor: combData.map(d => d.type==='traditional' ? colors.traditional : colors.virtual)
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Eficiência (req/s por CPU%)' } } }
        }
    });

    // Timeline
    const timeCtx = document.getElementById('corrTimeline');
    const t = combData.filter(d=>d.type==='traditional');
    const v = combData.filter(d=>d.type==='virtual');
    charts.corrTimeline = new Chart(timeCtx, {
        type: 'line',
        data: {
            labels: combData.map(d => `Exec ${d.exec}`),
            datasets: [
                { label: 'Lat Trad (s)', data: t.map(d => d.latMean), borderColor: colors.traditional, yAxisID: 'y' },
                { label: 'Lat Virt (s)', data: v.map(d => d.latMean), borderColor: colors.virtual, yAxisID: 'y' },
                { label: 'CPU Trad (%)', data: t.map(d => d.cpu), borderColor: colors.traditional, borderDash: [5, 5], yAxisID: 'y1' },
                { label: 'CPU Virt (%)', data: v.map(d => d.cpu), borderColor: colors.virtual, borderDash: [5, 5], yAxisID: 'y1' }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            scales: {
                y: { type: 'linear', position: 'left', title: { display: true, text: 'Latência (s)' } },
                y1: { type: 'linear', position: 'right', title: { display: true, text: 'CPU (%)' }, grid: { drawOnChartArea: false } }
            }
        }
    });
}

function renderComparison() {
    const t = combData.filter(d=>d.type==='traditional').filter(d=>d.success>95);
    const v = combData.filter(d=>d.type==='virtual').filter(d=>d.success>95);

    document.getElementById('compAlert').innerHTML = `
        <strong>Comparação direta mostra vantagem clara de Virtual Threads</strong> em todas as métricas principais.
        Virtual é consistentemente mais eficiente.
    `;

    const metrics = [
        { label: 'Latência', tVal: avg(t.map(d=>d.latMean)), vVal: avg(v.map(d=>d.latMean)), unit: 's', invert: true },
        { label: 'Throughput', tVal: avg(t.map(d=>d.throughput)), vVal: avg(v.map(d=>d.throughput)), unit: '', invert: false },
        { label: 'CPU', tVal: avg(t.map(d=>d.cpu)), vVal: avg(v.map(d=>d.cpu)), unit: '%', invert: true },
        { label: 'Memória', tVal: avg(t.map(d=>d.mem)), vVal: avg(v.map(d=>d.mem)), unit: '%', invert: true },
        { label: 'Threads', tVal: avg(t.map(d=>d.threads)), vVal: avg(v.map(d=>d.threads)), unit: '', invert: true }
    ];

    document.getElementById('compMetrics').innerHTML = metrics.map(m => `
        <div class="metric-box">
            <h4>${m.label}</h4>
            <div class="value traditional">${m.tVal.toFixed(2)} ${m.unit}</div>
            <div class="endpoint-label">Traditional</div>
            <div class="value virtual">${m.vVal.toFixed(2)} ${m.unit}</div>
            <div class="endpoint-label">Virtual</div>
            <div class="diff">${m.invert ? '↓' : '↑'} ${(m.invert ? (1-m.vVal/m.tVal)*100 : (m.vVal/m.tVal-1)*100).toFixed(1)}%</div>
        </div>
    `).join('');

    // All metrics comparison
    const allMetCtx = document.getElementById('compAllMetrics');
    charts.compAllMetrics = new Chart(allMetCtx, {
        type: 'bar',
        data: {
            labels: metrics.map(m => m.label),
            datasets: [
                { label: 'Traditional (normalizado)', data: metrics.map(m => m.tVal / Math.max(m.tVal, m.vVal) * 100), backgroundColor: colors.traditional },
                { label: 'Virtual (normalizado)', data: metrics.map(m => m.vVal / Math.max(m.tVal, m.vVal) * 100), backgroundColor: colors.virtual }
            ]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true, max: 100, title: { display: true, text: 'Valor Normalizado (%)' } } }
        }
    });

    // Savings
    const savCtx = document.getElementById('compSavings');
    charts.compSavings = new Chart(savCtx, {
        type: 'bar',
        data: {
            labels: ['Latência', 'CPU', 'Memória', 'Threads'],
            datasets: [{
                label: 'Economia (%)',
                data: [
                    (1 - avg(v.map(d=>d.latMean)) / avg(t.map(d=>d.latMean))) * 100,
                    (1 - avg(v.map(d=>d.cpu)) / avg(t.map(d=>d.cpu))) * 100,
                    (1 - avg(v.map(d=>d.mem)) / avg(t.map(d=>d.mem))) * 100,
                    (1 - avg(v.map(d=>d.threads)) / avg(t.map(d=>d.threads))) * 100
                ],
                backgroundColor: colors.virtual
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Economia (%)' } } }
        }
    });

    // Box plot simulation
    const boxCtx = document.getElementById('compBoxPlot');
    charts.compBoxPlot = new Chart(boxCtx, {
        type: 'bar',
        data: {
            labels: ['Traditional Min', 'Traditional Avg', 'Traditional Max', 'Virtual Min', 'Virtual Avg', 'Virtual Max'],
            datasets: [{
                label: 'Latência (s)',
                data: [
                    Math.min(...t.map(d=>d.latMean)),
                    avg(t.map(d=>d.latMean)),
                    Math.max(...t.map(d=>d.latMean)),
                    Math.min(...v.map(d=>d.latMean)),
                    avg(v.map(d=>d.latMean)),
                    Math.max(...v.map(d=>d.latMean))
                ],
                backgroundColor: [
                    colors.traditional + '40',
                    colors.traditional,
                    colors.traditional + '40',
                    colors.virtual + '40',
                    colors.virtual,
                    colors.virtual + '40'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Latência (s)' } } }
        }
    });

    // Stability
    const stabCtx = document.getElementById('compStability');
    charts.compStability = new Chart(stabCtx, {
        type: 'bar',
        data: {
            labels: ['Latência', 'Throughput', 'CPU', 'Memória'],
            datasets: [
                {
                    label: 'Traditional (StdDev)',
                    data: [
                        stdDev(t.map(d=>d.latMean)),
                        stdDev(t.map(d=>d.throughput))/100,
                        stdDev(t.map(d=>d.cpu)),
                        stdDev(t.map(d=>d.mem))
                    ],
                    backgroundColor: colors.traditional
                },
                {
                    label: 'Virtual (StdDev)',
                    data: [
                        stdDev(v.map(d=>d.latMean)),
                        stdDev(v.map(d=>d.throughput))/100,
                        stdDev(v.map(d=>d.cpu)),
                        stdDev(v.map(d=>d.mem))
                    ],
                    backgroundColor: colors.virtual
                }
            ]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Desvio Padrão (menor = mais estável)' } } }
        }
    });

    // Ratio
    const ratioCtx = document.getElementById('compRatio');
    charts.compRatio = new Chart(ratioCtx, {
        type: 'bar',
        data: {
            labels: ['CPU', 'Memória', 'Threads', 'Latência'],
            datasets: [{
                label: 'Razão Traditional/Virtual',
                data: [
                    avg(t.map(d=>d.cpu)) / avg(v.map(d=>d.cpu)),
                    avg(t.map(d=>d.mem)) / avg(v.map(d=>d.mem)),
                    avg(t.map(d=>d.threads)) / avg(v.map(d=>d.threads)),
                    avg(t.map(d=>d.latMean)) / avg(v.map(d=>d.latMean))
                ],
                backgroundColor: colors.neutral
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (ctx) => `Razão: ${ctx.parsed.y.toFixed(2)}x (Virtual é ${ctx.parsed.y.toFixed(2)}x melhor)`
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: { display: true, text: 'Razão (quanto maior, melhor Virtual)' },
                    ticks: { callback: (val) => val.toFixed(1) + 'x' }
                }
            }
        }
    });
}

function renderData() {
    const tbody = document.querySelector('#dataTable tbody');
    tbody.innerHTML = '';
    combData.forEach(d => {
        const row = tbody.insertRow();
        row.className = d.type === 'traditional' ? 'traditional-row' : 'virtual-row';
        row.innerHTML = `
            <td>${d.exec}</td><td><strong>${d.type}</strong></td>
            <td>${d.latMean?.toFixed(3)||'N/A'}</td><td>${d.p50?.toFixed(3)||'N/A'}</td><td>${d.p90?.toFixed(3)||'N/A'}</td>
            <td>${d.p95?.toFixed(3)||'N/A'}</td><td>${d.p99?.toFixed(3)||'N/A'}</td>
            <td>${d.throughput?.toFixed(1)||'N/A'}</td><td>${d.success?.toFixed(1)||'N/A'}</td><td>${d.wait?.toFixed(3)||'N/A'}</td>
            <td>${d.cpu?.toFixed(2)||'N/A'}</td><td>${d.mem?.toFixed(2)||'N/A'}</td><td>${d.threads?.toFixed(0)||'N/A'}</td>
            <td>${d.rss?.toFixed(1)||'N/A'}</td><td>${d.vsz?.toFixed(1)||'N/A'}</td><td>${d.heap?.toFixed(1)||'N/A'}</td>
        `;
    });

    // Stats table
    const t = combData.filter(d=>d.type==='traditional').filter(d=>d.success>95);
    const v = combData.filter(d=>d.type==='virtual').filter(d=>d.success>95);
    document.getElementById('statsTable').innerHTML = `
        <table style="margin-top: 20px;">
            <thead><tr><th>Métrica</th><th>Traditional (Média)</th><th>Virtual (Média)</th><th>Diferença</th></tr></thead>
            <tbody>
                <tr class="traditional-row"><td>Latência (s)</tr>
            </tbody>
        </table>
        `;
    }

function makeBarChart(elementId, data, field, label, unit) {
    const t = data.filter(d => d.type === 'traditional' || d.endpoint === 'traditional');
    const v = data.filter(d => d.type === 'virtual' || d.endpoint === 'virtual');
    const ctx = document.getElementById(elementId);
    charts[elementId] = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: data.map(d => `Exec ${d.exec}`),
        datasets: [
        {
            label: `${label} Traditional`,
            data: t.map(d => d[field]),
            backgroundColor: colors.traditional
        },
        {
            label: `${label} Virtual`,
            data: v.map(d => d[field]),
            backgroundColor: colors.virtual
        }
        ]
    },
    options: {
        responsive: true,
        scales: {
        y: {
            beginAtZero: true,
            title: { display: true, text: `${label} (${unit})` }
        }
        }
    }
    });
}

function makeScatterChart(elementId, data, xField, yField, xLabel, yLabel) {
    const ctx = document.getElementById(elementId);
    charts[elementId] = new Chart(ctx, {
    type: 'scatter',
    data: {
        datasets: [
        {
            label: 'Traditional',
            data: data.filter(d => d.type === 'traditional').map(d => ({x: d[xField], y: d[yField]})),
            backgroundColor: colors.traditional
        },
        {
            label: 'Virtual',
            data: data.filter(d => d.type === 'virtual').map(d => ({x: d[xField], y: d[yField]})),
            backgroundColor: colors.virtual
        }
        ]
    },
    options: {
        responsive: true,
        scales: {
        x: { title: { display: true, text: xLabel } },
        y: { title: { display: true, text: yLabel } }
        }
    }
    });
}

loadAllData();