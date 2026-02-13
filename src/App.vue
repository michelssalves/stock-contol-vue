<script setup>
import { computed, ref, watch } from 'vue'
import VueApexCharts from 'vue3-apexcharts'

const companyName = 'Analise de Custos de Estoque'
const userName = 'Michel Alves'

const mockMovements = [
  { data: '2026-01-05', grupo: 'ACO', codProduto: 'ACO-001', produto: 'Chapa Aco 3mm', custo: 18.3 },
  { data: '2026-01-09', grupo: 'ACO', codProduto: 'ACO-001', produto: 'Chapa Aco 3mm', custo: 19.1 },
  { data: '2026-01-13', grupo: 'ACO', codProduto: 'ACO-002', produto: 'Tubo Galvanizado 1pol', custo: 124.8 },
  { data: '2026-01-20', grupo: 'ACO', codProduto: 'ACO-002', produto: 'Tubo Galvanizado 1pol', custo: 121.7 },
  { data: '2026-01-24', grupo: 'ACO', codProduto: 'ACO-003', produto: 'Perfil U 2mm', custo: 32.4 },
  { data: '2026-02-02', grupo: 'ELETRICO', codProduto: 'ELE-001', produto: 'Cabo Flexivel 2.5mm', custo: 2.4 },
  { data: '2026-02-03', grupo: 'ELETRICO', codProduto: 'ELE-001', produto: 'Cabo Flexivel 2.5mm', custo: 2.75 },
  { data: '2026-02-05', grupo: 'ELETRICO', codProduto: 'ELE-002', produto: 'Disjuntor 40A', custo: 48.9 },
  { data: '2026-02-08', grupo: 'ELETRICO', codProduto: 'ELE-002', produto: 'Disjuntor 40A', custo: 47.2 },
  { data: '2026-02-10', grupo: 'PINTURA', codProduto: 'PIN-001', produto: 'Tinta Epoxi Azul', custo: 39.9 },
  { data: '2026-02-11', grupo: 'PINTURA', codProduto: 'PIN-001', produto: 'Tinta Epoxi Azul', custo: 41.35 },
  { data: '2026-02-12', grupo: 'PINTURA', codProduto: 'PIN-002', produto: 'Primer Anticorrosivo', custo: 29.4 }
]

const filters = ref({
  dataInicial: '2026-01-01',
  dataFinal: '2026-02-28',
  grupoPai: 'TODOS',
  tipo: 'TODOS',
  controleEstoque: 'TODOS',
  termoProduto: ''
})

const chartFilters = ref({
  topN: 8
})

const pagination = ref({
  page: 1,
  pageSize: 10
})

const query = new URLSearchParams(window.location.search)
const isGithubPages = window.location.hostname.includes('github.io')
const forceMock = query.get('mock') === '1'
const forceApi = query.get('api') === '1'

const apiBaseRaw =
  query.get('apiBase') ||
  window.localStorage.getItem('stock_api_base') ||
  'http://vhwin1065:9023'

const apiBase = apiBaseRaw.replace(/\/$/, '')
const apiEndpoint = `${apiBase}/rest/protheus/v1/stock-control/precos-periodo`
const apiHeaders = {
  Authorization: `Basic ${btoa('admin:tcp_tcp')}`,
  'Content-Type': 'application/json',
  tenantid: '02,01',
  'x-erp-module': 'EST'
}
const EMPTY_GROUP_OPTION = '__EMPTY_GROUP__'
const EMPTY_TYPE_OPTION = '__EMPTY_TYPE__'
const allTableColumns = [
  { key: 'tipoProduto', label: 'B1_TIPO' },
  { key: 'grupo', label: 'Grupo' },
  { key: 'codProduto', label: 'Produto' },
  { key: 'produto', label: 'Descricao' },
  { key: 'b1Emin', label: 'B1_EMIN' },
  { key: 'b1Emax', label: 'B1_EMAX' },
  { key: 'b1Localiz', label: 'B1_LOCALIZ' },
  { key: 'b1Zlocali', label: 'B1_ZLOCALI' },
  { key: 'b1Rastro', label: 'B1_RASTRO' },
  { key: 'b1Xcaepi', label: 'B1_XCAEPI' },
  { key: 'b1Mrp', label: 'B1_MRP' },
  { key: 'menorPreco', label: 'Menor preco' },
  { key: 'maiorPreco', label: 'Maior preco' }
]
const essentialColumnKeys = ['tipoProduto', 'grupo', 'codProduto', 'produto', 'menorPreco', 'maiorPreco']
const typeLabelMap = {
  AI: 'AI - Ativo imobilizado',
  AU: 'AU - Automacao',
  BC: 'BC - Bobcat',
  BN: 'BN - Bem do ativo',
  CL: 'CL - Combustiveis e lubrificantes',
  CS: 'CS - Compra mediante solicitacao',
  CT: 'CT - Cabeca tratora',
  EE: 'EE - Elementos eletricos',
  EH: 'EH - Elementos hidraulicos',
  EM: 'EM - Elementos mecanicos',
  EP: 'EP - Empilhadeira',
  ES: 'ES - Equipamento de seguranca e protecao (EPI)',
  EV: 'EV - Empilhadeira de vazio',
  FG: 'FG - Ferramentas em geral',
  GE: 'GE - Garantia estendida',
  GG: 'GG - Gastos gerais',
  GM: 'GM - Guindaste movel',
  GN: 'GN - Generico',
  GR: 'GR - Geral TCP',
  IA: 'IA - Insumo agricola',
  IF: 'IF - Informatica',
  II: 'II - Insumo industriais',
  IL: 'IL - Iluminacao',
  IN: 'IN - Produtos industriais',
  INF: 'INF - Informatica',
  KL: 'KL - Kalmar',
  KT: 'KT - Kit',
  MC: 'MC - Material de consumo',
  ME: 'ME - Mercadoria',
  MM: 'MM - Materiais manfro',
  MO: 'MO - Mao de obra',
  MP: 'MP - Materia prima',
  MS: 'MS - Medicina e seguranca (sem CA)',
  OI: 'OI - Outros insumos',
  PA: 'PA - Produto acabado',
  PF: 'PF - Plataforma elevatoria',
  PI: 'PI - Produto intermediario',
  PN: 'PN - Prestes e neves',
  PO: 'PO - Ponto de pedido',
  PP: 'PP - Produto em processo',
  PR: 'PR - Pecas de reposicao',
  PV: 'PV - Produto veiculo',
  RS: 'RS - Reach stacker',
  SL: 'SL - Selo de controle',
  SM: 'SM - Sementes',
  SP: 'SP - Subproduto',
  SS: 'SS - Self service',
  ST: 'ST - Servicos de terceiros',
  SV: 'SV - Servicos'
}

const mode = ref('mock')
const loading = ref(false)
const apiVersion = ref('')
const loadMessage = ref('')
const apiProductRows = ref([])
const visibleColumnKeys = ref([...essentialColumnKeys])

const shouldUseMock = computed(() => forceMock || (isGithubPages && !forceApi))

const normalizeApiDate = (value) => {
  const c = String(value || '').trim()
  if (!c) return ''
  return c.replaceAll('/', '-')
}

const toNumber = (value) => {
  const n = Number(value)
  return Number.isFinite(n) ? n : 0
}

const normalizeApiRows = (rows) =>
  (rows || []).map((row) => ({
    grupo: String(row.grupo || 'SEM_GRUPO').trim() || 'SEM_GRUPO',
    grupoDescricao: String(row.grupoDescricao || '').trim(),
    codProduto: String(row.codProduto || '').trim(),
    produto: String(row.produto || '').trim(),
    tipoProduto: String(row.tipoProduto || '').trim().toUpperCase(),
    b1Emin: toNumber(row.b1Emin),
    b1Emax: toNumber(row.b1Emax),
    b1Localiz: String(row.b1Localiz || '').trim(),
    b1Zlocali: String(row.b1Zlocali || '').trim(),
    b1Rastro: String(row.b1Rastro || '').trim(),
    b1Xcaepi: String(row.b1Xcaepi || '').trim(),
    b1Mrp: String(row.b1Mrp || '').trim(),
    menorPreco: toNumber(row.menorPreco),
    maiorPreco: toNumber(row.maiorPreco),
    variacao: toNumber(row.variacao),
    qtdMov: toNumber(row.qtdMov),
    dataPrimeiraCompra: normalizeApiDate(row.dataPrimeiraCompra),
    dataUltimaCompra: normalizeApiDate(row.dataUltimaCompra)
  }))

const loadFromApi = async () => {
  if (shouldUseMock.value) {
    mode.value = 'mock'
    loadMessage.value = 'Modo mock (GitHub Pages).'
    return
  }

  loading.value = true
  loadMessage.value = ''

  try {
    const response = await fetch(apiEndpoint, {
      method: 'POST',
      headers: apiHeaders,
      body: JSON.stringify({
        dataInicial: filters.value.dataInicial,
        dataFinal: filters.value.dataFinal,
        grupoPai: filters.value.grupoPai === EMPTY_GROUP_OPTION ? EMPTY_GROUP_OPTION : filters.value.grupoPai,
        tipo: filters.value.tipo === EMPTY_TYPE_OPTION ? EMPTY_TYPE_OPTION : filters.value.tipo,
        controleEstoque: filters.value.controleEstoque,
        termoProduto: filters.value.termoProduto
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }

    const data = await response.json()

    if (!data?.ok) {
      throw new Error(data?.message || 'Resposta da API invalida')
    }

    apiProductRows.value = normalizeApiRows(data.resumoProduto)
    apiVersion.value = data.versaoApi || ''
    mode.value = 'api'
    loadMessage.value = 'Dados carregados da API Protheus.'
  } catch (error) {
    mode.value = 'mock'
    loadMessage.value = `Falha na API (${error.message}). Usando mock.`
  } finally {
    loading.value = false
  }
}

watch(
  () => [filters.value.dataInicial, filters.value.dataFinal, filters.value.grupoPai, filters.value.tipo, filters.value.controleEstoque, filters.value.termoProduto],
  () => {
    loadFromApi()
  },
  { immediate: true }
)

const mockFilteredMovements = computed(() => {
  const term = filters.value.termoProduto.trim().toLowerCase()

  return mockMovements.filter((item) => {
    const byDate = item.data >= filters.value.dataInicial && item.data <= filters.value.dataFinal
    const byGroup = filters.value.grupoPai === 'TODOS' || item.grupo === filters.value.grupoPai
    const byTerm =
      !term ||
      item.produto.toLowerCase().includes(term) ||
      item.codProduto.toLowerCase().includes(term)

    return byDate && byGroup && byTerm
  })
})

const mockByProductRows = computed(() => {
  const map = new Map()

  for (const item of mockFilteredMovements.value) {
    const key = `${item.grupo}|${item.codProduto}`
    const current = map.get(key) || {
      grupo: item.grupo,
      codProduto: item.codProduto,
      produto: item.produto,
      tipoProduto: '',
      b1Emin: 0,
      b1Emax: 0,
      b1Localiz: '',
      b1Zlocali: '',
      b1Rastro: '',
      b1Xcaepi: '',
      b1Mrp: '',
      menorPreco: item.custo,
      maiorPreco: item.custo,
      qtdMov: 0,
      dataPrimeiraCompra: item.data,
      dataUltimaCompra: item.data
    }

    current.menorPreco = Math.min(current.menorPreco, item.custo)
    current.maiorPreco = Math.max(current.maiorPreco, item.custo)
    current.qtdMov += 1
    current.dataPrimeiraCompra = current.dataPrimeiraCompra < item.data ? current.dataPrimeiraCompra : item.data
    current.dataUltimaCompra = current.dataUltimaCompra > item.data ? current.dataUltimaCompra : item.data

    map.set(key, current)
  }

  return [...map.values()].map((row) => ({ ...row, variacao: row.maiorPreco - row.menorPreco }))
})

const normalizeTipo = (row) => String(row.tipoProduto || 'NA').toUpperCase().trim() || 'NA'
const matchesControleEstoque = (row) => {
  const estoqueMinimo = Number(row.b1Emin || 0)
  if (filters.value.controleEstoque === 'TODOS') return true
  if (filters.value.controleEstoque === 'NAO_ESTOQUE') return estoqueMinimo <= 0
  if (filters.value.controleEstoque === 'ESTOQUE') return estoqueMinimo > 0
  return true
}

const productRowsBase = computed(() => (mode.value === 'api' ? apiProductRows.value : mockByProductRows.value))

const productRows = computed(() =>
  productRowsBase.value.filter((row) => {
    const tipo = normalizeTipo(row)
    const byTipo = filters.value.tipo === 'TODOS' || filters.value.tipo === tipo
    const byControle = matchesControleEstoque(row)
    return byTipo && byControle
  })
)

const productRowsWithoutControle = computed(() =>
  productRowsBase.value.filter((row) => {
    const tipo = normalizeTipo(row)
    return filters.value.tipo === 'TODOS' || filters.value.tipo === tipo
  })
)

const totalPages = computed(() => Math.max(1, Math.ceil(productRows.value.length / pagination.value.pageSize)))

const paginatedRows = computed(() => {
  const start = (pagination.value.page - 1) * pagination.value.pageSize
  const end = start + pagination.value.pageSize
  return productRows.value.slice(start, end)
})

const paginationLabel = computed(() => {
  if (productRows.value.length === 0) return '0-0 de 0'
  const start = (pagination.value.page - 1) * pagination.value.pageSize + 1
  const end = Math.min(start + pagination.value.pageSize - 1, productRows.value.length)
  return `${start}-${end} de ${productRows.value.length}`
})

watch(
  () => [productRows.value.length, pagination.value.pageSize],
  () => {
    pagination.value.page = 1
  }
)

watch(totalPages, (newTotal) => {
  if (pagination.value.page > newTotal) {
    pagination.value.page = newTotal
  }
})

const byGroupRows = computed(() => {
  const map = new Map()

  for (const row of productRows.value) {
    const current = map.get(row.grupo) || {
      grupo: row.grupo,
      grupoDescricao: row.grupoDescricao || '',
      qtdProdutos: 0,
      qtdMov: 0,
      menorPreco: row.menorPreco,
      maiorPreco: row.maiorPreco
    }

    current.qtdProdutos += 1
    current.qtdMov += row.qtdMov
    current.menorPreco = Math.min(current.menorPreco, row.menorPreco)
    current.maiorPreco = Math.max(current.maiorPreco, row.maiorPreco)

    map.set(row.grupo, current)
  }

  return [...map.values()]
    .map((row) => ({ ...row, variacao: row.maiorPreco - row.menorPreco }))
    .sort((a, b) => a.grupo.localeCompare(b.grupo))
})

const totalRegistros = computed(() => productRows.value.reduce((acc, row) => acc + row.qtdMov, 0))
const totalGrupos = computed(() => byGroupRows.value.length)
const totalProdutos = computed(() => productRows.value.length)
const totalItensEstoque = computed(
  () => productRowsWithoutControle.value.filter((row) => Number(row.b1Emin || 0) > 0).length
)
const totalItensNaoEstoque = computed(
  () => productRowsWithoutControle.value.filter((row) => Number(row.b1Emin || 0) <= 0).length
)

const groupOptions = computed(() => {
  const groupsFromMock = [...new Set(mockMovements.map((item) => item.grupo))]
  const groupsFromApi = [...new Set(apiProductRows.value.map((item) => item.grupo))]
  const baseGroups = mode.value === 'api' ? groupsFromApi : groupsFromMock
  const groups = [...new Set(baseGroups)].sort((a, b) => a.localeCompare(b))
  return ['TODOS', ...groups.map((g) => (g === '' ? EMPTY_GROUP_OPTION : g))]
})

const typeOptions = computed(() => {
  const typesFromApi = apiProductRows.value.map((item) => normalizeTipo(item))
  const typesFromMock = mockByProductRows.value.map((item) => normalizeTipo(item))
  const baseTypes = mode.value === 'api' ? typesFromApi : typesFromMock
  const types = [...new Set(baseTypes)].sort((a, b) => a.localeCompare(b))
  const mapped = types.map((t) => (t === 'NA' ? EMPTY_TYPE_OPTION : t))
  const uniqueMapped = [...new Set([EMPTY_TYPE_OPTION, ...mapped])]
  return ['TODOS', ...uniqueMapped]
})

const groupDescriptionMap = computed(() => {
  const map = new Map()
  for (const row of apiProductRows.value) {
    if (row.grupo && row.grupoDescricao) {
      map.set(row.grupo, row.grupoDescricao)
    }
  }
  return map
})

const displayGroup = (grupo) => {
  if (grupo === 'TODOS') return 'Todos os grupos'
  if (grupo === EMPTY_GROUP_OPTION || !grupo) return 'Sem grupo'
  const desc = groupDescriptionMap.value.get(grupo)
  return desc ? `${grupo} - ${desc}` : grupo
}

const displayType = (tipo) => {
  if (tipo === 'TODOS') return 'Todos os tipos'
  if (tipo === EMPTY_TYPE_OPTION) return 'Sem tipo'
  return typeLabelMap[tipo] || `${tipo} - Tipo nao mapeado`
}

const displayTypeFromRow = (tipo) => {
  const code = String(tipo || '').trim().toUpperCase()
  if (!code || code === 'NA') return 'Sem tipo'
  return typeLabelMap[code] || `${code} - Tipo nao mapeado`
}

const visibleColumns = computed(() =>
  allTableColumns.filter((col) => visibleColumnKeys.value.includes(col.key))
)

const toggleColumn = (key, checked) => {
  if (checked) {
    if (!visibleColumnKeys.value.includes(key)) {
      visibleColumnKeys.value.push(key)
    }
    return
  }

  if (visibleColumnKeys.value.length <= 1) return
  visibleColumnKeys.value = visibleColumnKeys.value.filter((k) => k !== key)
}

const showEssentialColumns = () => {
  visibleColumnKeys.value = [...essentialColumnKeys]
}

const showAllColumns = () => {
  visibleColumnKeys.value = [...allTableColumns.map((col) => col.key)]
}

const getColumnValue = (row, key) => {
  switch (key) {
    case 'tipoProduto':
      return displayTypeFromRow(row.tipoProduto)
    case 'grupo':
      return displayGroup(row.grupo)
    case 'codProduto':
      return row.codProduto
    case 'produto':
      return row.produto
    case 'b1Emin':
      return row.b1Emin ?? 0
    case 'b1Emax':
      return row.b1Emax ?? 0
    case 'b1Localiz':
      return row.b1Localiz || '-'
    case 'b1Zlocali':
      return row.b1Zlocali || '-'
    case 'b1Rastro':
      return row.b1Rastro || '-'
    case 'b1Xcaepi':
      return row.b1Xcaepi || '-'
    case 'b1Mrp':
      return row.b1Mrp || '-'
    case 'menorPreco':
      return currency(row.menorPreco)
    case 'maiorPreco':
      return currency(row.maiorPreco)
    default:
      return '-'
  }
}

const shortLabel = (value, max = 38) => {
  const text = String(value || '')
  return text.length > max ? `${text.slice(0, max - 1)}…` : text
}

const chartRows = computed(() => productRows.value)

const topExpensiveRows = computed(() =>
  chartRows.value
    .sort((a, b) => b.maiorPreco - a.maiorPreco)
    .slice(0, chartFilters.value.topN)
)

const topExpensiveSeries = computed(() => [
  {
    name: 'Maior preco',
    data: topExpensiveRows.value.map((row) => Number(row.maiorPreco.toFixed(2)))
  }
])

const topExpensiveOptions = computed(() => ({
  chart: {
    type: 'bar',
    toolbar: { show: false },
    fontFamily: 'Manrope, Segoe UI, sans-serif'
  },
  plotOptions: {
    bar: {
      borderRadius: 4,
      horizontal: true
    }
  },
  dataLabels: { enabled: false },
  xaxis: {
    categories: topExpensiveRows.value.map((row) => row.codProduto),
    labels: {
      formatter: (value) =>
        new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value || 0)
    }
  },
  tooltip: {
    x: {
      formatter: (_, { dataPointIndex }) => topExpensiveRows.value[dataPointIndex]?.produto || ''
    },
    y: {
      formatter: (value) =>
        new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value || 0)
    }
  },
  noData: { text: 'Sem dados para ranking de preco.' }
}))

const priceBuckets = [
  { label: 'Ate R$ 100', min: 0, max: 100 },
  { label: 'R$ 100 a 500', min: 100, max: 500 },
  { label: 'R$ 500 a 1.000', min: 500, max: 1000 },
  { label: 'R$ 1.000 a 5.000', min: 1000, max: 5000 },
  { label: 'Acima de R$ 5.000', min: 5000, max: Number.POSITIVE_INFINITY }
]

const distributionCounts = computed(() =>
  priceBuckets.map((bucket) => {
    const qtd = productRows.value.filter(
      (row) => row.maiorPreco > bucket.min && row.maiorPreco <= bucket.max
    ).length
    return { label: bucket.label, qtd }
  })
)

const distributionSeries = computed(() => [
  { name: 'Produtos', data: distributionCounts.value.map((item) => item.qtd) }
])

const distributionOptions = computed(() => ({
  chart: {
    type: 'bar',
    toolbar: { show: false },
    fontFamily: 'Manrope, Segoe UI, sans-serif'
  },
  colors: ['#8b5cf6'],
  dataLabels: { enabled: false },
  xaxis: {
    categories: distributionCounts.value.map((item) => item.label)
  },
  yaxis: {
    title: { text: 'Qtd. produtos' }
  },
  noData: { text: 'Sem dados para distribuicao.' }
}))

const currency = (value) =>
  new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
</script>

<template>
  <main class="page">
    <section class="panel">
      <header class="panel-header">
        <div class="panel-header-left">
          <div class="panel-brand-icon">{ }</div>
          <div class="panel-title-block">
            <p class="panel-caption">Modelo Protheus + Vue</p>
            <h1>{{ companyName }}</h1>
            <p class="panel-subtitle">Painel de analise com foco em custos, estoque e performance de compras.</p>
          </div>
        </div>
        <div class="panel-user">
          <span class="panel-user-dot"></span>
          <span>{{ userName }}</span>
        </div>
      </header>

      <div class="runtime-state">
        <span class="pill" :class="mode.toLowerCase()">{{ mode === 'api' ? 'API' : 'MOCK' }}</span>
        <span v-if="apiVersion" class="runtime-text">{{ apiVersion }}</span>
        <span v-if="loading" class="runtime-text">Carregando...</span>
        <span v-else-if="loadMessage" class="runtime-text">{{ loadMessage }}</span>
      </div>

      <div class="kpis">
        <article>
          <span>Movimentacoes no periodo</span>
          <strong>{{ totalRegistros }}</strong>
        </article>
        <article>
          <span>Grupos analisados</span>
          <strong>{{ totalGrupos }}</strong>
        </article>
        <article>
          <span>Produtos analisados</span>
          <strong>{{ totalProdutos }}</strong>
        </article>
        <article>
          <span>Qtd. itens estoque</span>
          <strong>{{ totalItensEstoque }}</strong>
        </article>
        <article>
          <span>Qtd. itens nao estoque</span>
          <strong>{{ totalItensNaoEstoque }}</strong>
        </article>
      </div>

      <div class="filters">
        <div class="field">
          <label>Data inicial</label>
          <input v-model="filters.dataInicial" type="date" />
        </div>
        <div class="field">
          <label>Data final</label>
          <input v-model="filters.dataFinal" type="date" />
        </div>
        <div class="field">
          <label>Grupo pai</label>
          <select v-model="filters.grupoPai">
            <option v-for="option in groupOptions" :key="option" :value="option">
              {{ displayGroup(option) }}
            </option>
          </select>
        </div>
        <div class="field">
          <label>Tipo</label>
          <select v-model="filters.tipo">
            <option v-for="option in typeOptions" :key="option" :value="option">
              {{ displayType(option) }}
            </option>
          </select>
        </div>
        <div class="field">
          <label>Controle de estoque</label>
          <select v-model="filters.controleEstoque">
            <option value="TODOS">Todos</option>
            <option value="ESTOQUE">Com saldo minimo (B1_EMIN > 0)</option>
            <option value="NAO_ESTOQUE">Sem saldo minimo (B1_EMIN <= 0)</option>
          </select>
        </div>
        <div class="field">
          <label>Buscar produto</label>
          <input v-model="filters.termoProduto" type="text" placeholder="Codigo ou descricao" />
        </div>
      </div>

      <div class="chart-filters">
        <div class="field">
          <label>Top produtos nos graficos</label>
          <select v-model.number="chartFilters.topN">
            <option :value="5">Top 5</option>
            <option :value="8">Top 8</option>
            <option :value="10">Top 10</option>
            <option :value="15">Top 15</option>
          </select>
        </div>
      </div>

      <section class="charts">
        <article class="chart-card">
          <h2>Top mais caros (maior preco)</h2>
          <VueApexCharts type="bar" height="280" :options="topExpensiveOptions" :series="topExpensiveSeries" />
        </article>
        <article class="chart-card">
          <h2>Distribuicao de preco (maior preco)</h2>
          <VueApexCharts type="bar" height="280" :options="distributionOptions" :series="distributionSeries" />
        </article>
      </section>

      <div class="column-picker">
        <details>
          <summary>
            <span>Colunas da tabela</span>
            <strong>{{ visibleColumnKeys.length }}</strong>
          </summary>
          <div class="column-picker-actions">
            <button type="button" @click="showEssentialColumns">Essenciais</button>
            <button type="button" @click="showAllColumns">Todas</button>
          </div>
          <div class="column-picker-grid">
            <label v-for="col in allTableColumns" :key="col.key">
              <input
                type="checkbox"
                :checked="visibleColumnKeys.includes(col.key)"
                @change="toggleColumn(col.key, $event.target.checked)"
              />
              <span>{{ col.label }}</span>
            </label>
          </div>
        </details>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th v-for="col in visibleColumns" :key="col.key">{{ col.label }}</th>
            </tr>
          </thead>
          <tbody v-if="productRows.length > 0">
            <tr v-for="row in paginatedRows" :key="`${row.grupo}-${row.codProduto}`">
              <td v-for="col in visibleColumns" :key="`${row.grupo}-${row.codProduto}-${col.key}`">
                {{ getColumnValue(row, col.key) }}
              </td>
            </tr>
          </tbody>
          <tbody v-else>
            <tr>
              <td :colspan="visibleColumns.length || 1" class="empty-state">
                Nenhum dado encontrado para os filtros informados.
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="productRows.length > 0" class="table-pagination">
        <div class="pagination-info">{{ paginationLabel }}</div>
        <div class="pagination-actions">
          <label>
            Itens por pagina
            <select v-model.number="pagination.pageSize">
              <option :value="10">10</option>
              <option :value="20">20</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
          </label>
          <button type="button" :disabled="pagination.page <= 1" @click="pagination.page -= 1">Anterior</button>
          <span>Pagina {{ pagination.page }} de {{ totalPages }}</span>
          <button type="button" :disabled="pagination.page >= totalPages" @click="pagination.page += 1">Proxima</button>
        </div>
      </div>
    </section>
  </main>
</template>
