import os
import json
import re
from docx import Document


# ============================================================
# CONFIGURAÇÕES
# ============================================================

ARQUIVO_ENTRADA = "hinos_nganguela.docx"

ARQUIVO_SAIDA = os.path.join(
    "assets",
    "dados",
    "hinos_nganguela.json"
)


# ============================================================
# PADRÕES DE REGEX
# ============================================================

# Captura cabeçalhos do tipo:
# - "4 (Música: C.Sr. 316)"
# - "4. (Música: C.C. 152)"
# - "4 (C.C. 152)"
# - "4 - Música..."
HEADER_PATTERN = re.compile(
    r'^\s*(\d+)\s*[\.)]?\s*'
    r'(?:\(\s*(?:Música|Musica)?\s*[:.]?\s*(.*?)\s*\)|-\s*(.*))?$',
    re.IGNORECASE
)

# Numeração isolada no início da linha
NUMERO_SOZINHO_PATTERN = re.compile(r'^\s*(\d+)\s*[\.)]?\s*$')

# Numeração de estrofes (Ex: "1. Uhi ño!", "2) Hati...")
NUMERO_ESTROFE_MANUAL_PATTERN = re.compile(
    r'^\s*(\d+)\s*[\.)]\s*(.*)$',
    re.DOTALL
)


# ============================================================
# AUXILIARES DE LIMPEZA E FORMATAÇÃO
# ============================================================

def limpar_texto(texto):
    if texto is None:
        return ""

    texto = texto.replace("\r\n", "\n").replace("\r", "\n")
    linhas = []

    for linha in texto.split("\n"):
        linha = re.sub(r'[ \t]+', ' ', linha).strip()
        linhas.append(linha)

    while linhas and not linhas[0]:
        linhas.pop(0)

    while linhas and not linhas[-1]:
        linhas.pop()

    return "\n".join(linhas)


def obter_texto_original(paragraph):
    partes = [run.text or "" for run in paragraph.runs if run.text]
    if partes:
        return "".join(partes)
    return paragraph.text or ""


def obter_fragmentos_formatacao(paragraph):
    fragmentos = []
    for run in paragraph.runs:
        texto = run.text or ""
        if not texto:
            continue

        negrito = bool(run.bold)

        if fragmentos and fragmentos[-1]["negrito"] == negrito:
            fragmentos[-1]["texto"] += texto
        else:
            fragmentos.append({
                "texto": texto,
                "negrito": negrito
            })

    return fragmentos


def obter_num_id(paragraph):
    try:
        return int(paragraph._p.pPr.numPr.numId.val)
    except Exception:
        return None


def obter_nivel_lista(paragraph):
    try:
        return int(paragraph._p.pPr.numPr.ilvl.val)
    except Exception:
        return 0


def eh_lista_principal(paragraph):
    num_id = obter_num_id(paragraph)
    nivel = obter_nivel_lista(paragraph)
    return num_id is not None and nivel == 0


def analisar_cabecalho(texto):
    texto_limpo = texto.strip()
    if not texto_limpo:
        return None

    # Se a linha começar com número seguido de texto de estrofe, não é cabeçalho de hino
    if re.match(r'^\d+\s*[\.)]\s+[A-Za-zÁ-ÿ]', texto_limpo):
        return None

    match = HEADER_PATTERN.match(texto_limpo)
    if match:
        num = int(match.group(1))
        musica = match.group(2) or match.group(3) or ""
        return {
            "numero": num,
            "musica": musica.strip(),
            "resto": ""
        }

    return None


def eh_categoria(paragraph, texto):
    """
    Identifica categorias verificando se o título principal está em maiúsculas
    e sem números no início.
    """
    texto = limpar_texto(texto)

    if not texto or "\n" in texto:
        return False

    # Nunca é categoria se começar com número (ex: "4", "1. Uhi ño")
    if re.match(r'^\d+', texto):
        return False

    palavras = [p for p in re.findall(r'\b[A-Za-zÁ-ÿ]+\b', texto) if len(p) > 1]
    if not palavras:
        return False

    # Verifica se as duas primeiras palavras estão em maiúsculas (ex: ATENDELO OVIPATU)
    primeiras_maiusculas = all(p.isupper() for p in palavras[:2])

    estilo_nome = paragraph.style.name.lower()
    eh_estilo_titulo = "heading" in estilo_nome or "title" in estilo_nome or "cabeçalho" in estilo_nome
    possui_negrito = any(bool(run.bold) for run in paragraph.runs if run.text.strip())

    if primeiras_maiusculas and (possui_negrito or eh_estilo_titulo or len(palavras) <= 4):
        return True

    return False


def normalizar_bloco(texto):
    return limpar_texto(texto)


def adicionar_linhas_bloco(bloco_atual, texto):
    texto = normalizar_bloco(texto)
    if not texto:
        return bloco_atual
    if not bloco_atual:
        return texto
    return bloco_atual + "\n" + texto


# ============================================================
# PROCESSAMENTO DE CONTEÚDO
# ============================================================

def processar_hino(unidades):
    blocos = []
    bloco_atual = ""
    tipo_bloco_atual = None
    numero_estrofe = 0

    def finalizar_bloco():
        nonlocal bloco_atual, tipo_bloco_atual
        bloco = normalizar_bloco(bloco_atual)
        if bloco:
            blocos.append(bloco)
        bloco_atual = ""
        tipo_bloco_atual = None

    for unidade in unidades:
        texto = unidade["texto"]
        fragmentos = unidade["fragmentos"]
        lista_principal = unidade["is_list"]

        if not fragmentos:
            fragmentos = [{"texto": texto, "negrito": False}]

        if lista_principal:
            finalizar_bloco()
            numero_estrofe += 1
            primeira_parte = True

            for fragmento in fragmentos:
                texto_fragmento = normalizar_bloco(fragmento["texto"])
                if not texto_fragmento:
                    continue

                if fragmento["negrito"]:
                    if tipo_bloco_atual != "coro":
                        finalizar_bloco()
                        bloco_atual = texto_fragmento
                        tipo_bloco_atual = "coro"
                    else:
                        bloco_atual = adicionar_linhas_bloco(bloco_atual, texto_fragmento)
                    continue

                if primeira_parte:
                    match_manual = NUMERO_ESTROFE_MANUAL_PATTERN.match(texto_fragmento)
                    if match_manual:
                        numero_estrofe = int(match_manual.group(1))
                        texto_fragmento = match_manual.group(2).strip()

                    if texto_fragmento:
                        bloco_atual = f"{numero_estrofe}. {texto_fragmento}"
                    else:
                        bloco_atual = f"{numero_estrofe}."

                    tipo_bloco_atual = "estrofe"
                    primeira_parte = False
                else:
                    if tipo_bloco_atual == "coro":
                        finalizar_bloco()
                        bloco_atual = texto_fragmento
                        tipo_bloco_atual = "estrofe"
                    else:
                        bloco_atual = adicionar_linhas_bloco(bloco_atual, texto_fragmento)

            continue

        for fragmento in fragmentos:
            texto_fragmento = normalizar_bloco(fragmento["texto"])
            if not texto_fragmento:
                continue

            match_manual = NUMERO_ESTROFE_MANUAL_PATTERN.match(texto_fragmento)
            if match_manual:
                finalizar_bloco()
                numero_estrofe = int(match_manual.group(1))
                texto_fragmento = match_manual.group(2).strip()

                if texto_fragmento:
                    bloco_atual = f"{numero_estrofe}. {texto_fragmento}"
                    tipo_bloco_atual = "estrofe"
                continue

            if fragmento["negrito"]:
                if tipo_bloco_atual != "coro":
                    finalizar_bloco()
                    bloco_atual = texto_fragmento
                    tipo_bloco_atual = "coro"
                else:
                    bloco_atual = adicionar_linhas_bloco(bloco_atual, texto_fragmento)
                continue

            if tipo_bloco_atual == "coro":
                finalizar_bloco()
                bloco_atual = texto_fragmento
                tipo_bloco_atual = "estrofe"
            elif bloco_atual:
                bloco_atual = adicionar_linhas_bloco(bloco_atual, texto_fragmento)
            else:
                numero_estrofe = max(numero_estrofe, 1)
                bloco_atual = f"{numero_estrofe}. {texto_fragmento}"
                tipo_bloco_atual = "estrofe"

    finalizar_bloco()
    return "\n\n".join(bloco for bloco in blocos if bloco)


# ============================================================
# EXTRAÇÃO PRINCIPAL
# ============================================================

def extract_hymns_from_docx(caminho_entrada):
    if not os.path.exists(caminho_entrada):
        print(f"❌ Arquivo não encontrado: {caminho_entrada}")
        return []

    document = Document(caminho_entrada)
    resultados = []

    categoria_atual = ""
    hino_atual = None
    unidades_hino = []
    id_global = 1

    def guardar_hino_atual():
        nonlocal hino_atual, unidades_hino, id_global

        if hino_atual is None:
            return

        texto_pt = processar_hino(unidades_hino)
        texto_pt = limpar_texto(texto_pt)

        if not texto_pt:
            print(f"⚠️ Nº {hino_atual['numero']} sem texto. Ignorado.")
            hino_atual = None
            unidades_hino = []
            return

        linhas = [l.strip() for l in texto_pt.split("\n") if l.strip()]
        titulo_pt = linhas[0] if linhas else f"Hino {hino_atual['numero']}"
        titulo_pt = re.sub(r'^\s*\d+\s*[\.)]\s*', '', titulo_pt).strip()

        resultado = {
            "id": id_global,
            "numero": hino_atual["numero"],
            "titulo_pt": titulo_pt,
            "texto_pt": texto_pt,
            "categoria": categoria_atual
        }

        resultados.append(resultado)
        print(f"✓ ID {id_global:03d} | Nº {hino_atual['numero']:03d} | Título: {titulo_pt[:30]}...")

        id_global += 1
        hino_atual = None
        unidades_hino = []

    for paragraph in document.paragraphs:
        texto_original = obter_texto_original(paragraph)

        if not texto_original.strip():
            continue

        # 1. Checa se é um número/cabeçalho de hino
        cabecalho = analisar_cabecalho(texto_original)
        if cabecalho is not None:
            guardar_hino_atual()

            hino_atual = {
                "numero": cabecalho["numero"],
                "musica": cabecalho["musica"]
            }
            unidades_hino = []
            continue

        # 2. Checa se é uma nova Categoria
        if eh_categoria(paragraph, texto_original):
            guardar_hino_atual()
            categoria_atual = limpar_texto(texto_original)
            print(f"\n📂 Categoria Detectada: {categoria_atual}")
            continue

        # 3. Adiciona parágrafo ao hino ativo
        if hino_atual is not None:
            unidades_hino.append({
                "texto": texto_original,
                "fragmentos": obter_fragmentos_formatacao(paragraph),
                "is_list": eh_lista_principal(paragraph)
            })

    guardar_hino_atual()
    return resultados


# ============================================================
# SALVAR
# ============================================================

def salvar_arquivo_json(dados, caminho_saida):
    pasta = os.path.dirname(caminho_saida)
    if pasta:
        os.makedirs(pasta, exist_ok=True)

    with open(caminho_saida, "w", encoding="utf-8") as arquivo:
        json.dump(dados, arquivo, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print("💾 JSON EM UMBUNDO GERADO COM SUCESSO")
    print("=" * 60)
    print(f"📁 Arquivo: {caminho_saida}")
    print(f"📚 Total de hinos extraídos: {len(dados)}")


if __name__ == "__main__":
    dados = extract_hymns_from_docx(ARQUIVO_ENTRADA)
    if dados:
        salvar_arquivo_json(dados, ARQUIVO_SAIDA)