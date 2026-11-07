import os
import json
import re
from docx import Document


# ============================================================
# CONFIGURAÇÕES
# ============================================================

ARQUIVO_ENTRADA = "hinos.docx"

ARQUIVO_SAIDA = os.path.join(
    "assets",
    "dados",
    "categorias_hinos.json"
)


# ============================================================
# PADRÕES
# ============================================================

# Cabeçalhos normais:
#
# 1 (Música: C.Sr. 316)
# 2 (Música: C.C.152; Lyra 76 2ª Mús CC 221)
#
# Também aceita:
#
# 216 (Música. The Hymnary n° 383)
#
# E aceita conteúdo no mesmo parágrafo:
#
# 355 (Música: Lyra 110; S.H. 503)
# 1.Estrela da noite...
#
HEADER_PATTERN = re.compile(
    r'^\s*(\d+)\s*'
    r'\(\s*'
    r'(?:Música|Musica)'
    r'\s*[:.]?\s*'
    r'(.*?)'
    r'\)\s*'
    r'(.*)$',
    re.IGNORECASE | re.DOTALL
)


# Alguns conteúdos podem aparecer apenas como:
#
# 184
#
NUMERO_SOZINHO_PATTERN = re.compile(
    r'^\s*(\d+)\s*$'
)


# Numeração manual excepcional:
#
# 1. Texto
# 2) Texto
# 4.Ó Rei divino...
#
NUMERO_ESTROFE_MANUAL_PATTERN = re.compile(
    r'^\s*(\d+)\s*[\.)]\s*(.*)$',
    re.DOTALL
)


# ============================================================
# LIMPAR TEXTO
# ============================================================

def limpar_texto(texto):
    """
    Limpa espaços desnecessários, preservando
    as quebras de linha.
    """

    if texto is None:
        return ""

    texto = texto.replace("\r\n", "\n")
    texto = texto.replace("\r", "\n")

    linhas = []

    for linha in texto.split("\n"):

        linha = re.sub(
            r'[ \t]+',
            ' ',
            linha
        )

        linha = linha.strip()

        linhas.append(linha)

    # Remove linhas vazias no início
    while linhas and not linhas[0]:
        linhas.pop(0)

    # Remove linhas vazias no fim
    while linhas and not linhas[-1]:
        linhas.pop()

    return "\n".join(linhas)


# ============================================================
# TEXTO ORIGINAL DO PARÁGRAFO
# ============================================================

def obter_texto_original(paragraph):
    """
    Obtém o texto diretamente dos runs do Word.

    Isso preserva melhor as quebras de linha existentes
    dentro dos parágrafos.
    """

    partes = []

    for run in paragraph.runs:

        texto = run.text or ""

        if texto:
            partes.append(texto)

    if partes:
        return "".join(partes)

    return paragraph.text or ""


# ============================================================
# FRAGMENTOS DE FORMATAÇÃO
# ============================================================

def obter_fragmentos_formatacao(paragraph):
    """
    Divide o parágrafo conforme o estado de negrito.

    O negrito NÃO será gravado no JSON.

    Ele serve somente para identificar coros.

    Exemplo:

        texto normal
        texto normal
        coro em negrito
        coro em negrito
    """

    fragmentos = []

    for run in paragraph.runs:

        texto = run.text or ""

        if not texto:
            continue

        negrito = bool(run.bold)

        if (
            fragmentos
            and fragmentos[-1]["negrito"] == negrito
        ):
            fragmentos[-1]["texto"] += texto

        else:

            fragmentos.append({
                "texto": texto,
                "negrito": negrito
            })

    return fragmentos


# ============================================================
# NUMERAÇÃO AUTOMÁTICA DO WORD
# ============================================================

def obter_num_id(paragraph):
    """
    Obtém o numId da lista automática do Word.
    """

    try:

        return int(
            paragraph
            ._p
            .pPr
            .numPr
            .numId
            .val
        )

    except Exception:

        return None


def obter_nivel_lista(paragraph):
    """
    Obtém o nível da lista automática.

    Nível 0 = estrofe principal.
    """

    try:

        return int(
            paragraph
            ._p
            .pPr
            .numPr
            .ilvl
            .val
        )

    except Exception:

        return 0


def eh_lista_principal(paragraph):
    """
    Verifica se o parágrafo possui numeração
    automática principal do Word.
    """

    num_id = obter_num_id(paragraph)
    nivel = obter_nivel_lista(paragraph)

    return (
        num_id is not None
        and nivel == 0
    )


# ============================================================
# ANALISAR CABEÇALHO
# ============================================================

def analisar_cabecalho(texto):
    """
    Reconhece cabeçalhos normais e casos especiais.

    Retorna:

        numero
        musica
        resto

    Exemplo:

        355 (Música: Lyra 110; S.H. 503)
        1.Estrela...

    retorna:

        numero = 355
        musica = Lyra 110; S.H. 503
        resto = 1.Estrela...
    """

    if not texto:
        return None

    match = HEADER_PATTERN.match(texto)

    if match:

        return {
            "numero": int(match.group(1)),
            "musica": match.group(2).strip(),
            "resto": match.group(3).strip()
        }

    # Caso especial:
    #
    # 184
    #

    match_numero = NUMERO_SOZINHO_PATTERN.match(
        texto.strip()
    )

    if match_numero:

        return {
            "numero": int(match_numero.group(1)),
            "musica": "",
            "resto": ""
        }

    return None


# ============================================================
# DETECTAR CATEGORIA
# ============================================================

def eh_categoria(paragraph, texto):
    """
    As categorias do documento são títulos em maiúsculas
    e normalmente em negrito.

    Exemplos reais:

        CHAMADA PARA ADORAÇÃO
        LOUVOR E ADORAÇÃO
        ENTRADA TRIUNFAL DE JESUS
        A PAIXÃO E A MORTE DE JESUS
        HINOS VESPERTINOS
        DOXOLOGIAS
    """

    texto = limpar_texto(texto)

    if not texto:
        return False

    # Categoria deve ser uma única linha
    if "\n" in texto:
        return False

    # Tem de conter letras
    letras = [
        caractere
        for caractere in texto
        if caractere.isalpha()
    ]

    if not letras:
        return False

    # Deve estar em maiúsculas
    if texto.upper() != texto:
        return False

    # Deve possuir pelo menos um run em negrito
    possui_negrito = any(
        bool(run.bold)
        for run in paragraph.runs
    )

    if not possui_negrito:
        return False

    # Nunca considerar número puro como categoria
    if NUMERO_SOZINHO_PATTERN.match(texto):
        return False

    return True


# ============================================================
# NORMALIZAR BLOCO
# ============================================================

def normalizar_bloco(texto):
    """
    Limpa um bloco sem destruir suas linhas.
    """

    return limpar_texto(texto)


# ============================================================
# ADICIONAR TEXTO AO BLOCO
# ============================================================

def adicionar_linhas_bloco(
    bloco_atual,
    texto
):
    """
    Adiciona texto ao bloco usando uma única quebra
    de linha interna.
    """

    texto = normalizar_bloco(texto)

    if not texto:
        return bloco_atual

    if not bloco_atual:
        return texto

    return (
        bloco_atual
        + "\n"
        + texto
    )


# ============================================================
# PROCESSAR UM HINO
# ============================================================

def processar_hino(unidades):
    """
    Constrói o texto final do hino.

    Regras:

    - Cada estrofe automática inicia novo bloco.
    - A numeração é reconstruída.
    - O coro fica separado.
    - O coro não recebe HTML.
    - Todas as estrofes/coros ficam separados por linha vazia.
    - Estrofes depois do coro continuam numeradas.
    """

    blocos = []

    bloco_atual = ""
    tipo_bloco_atual = None

    numero_estrofe = 0

    # --------------------------------------------------------
    # Finalizar bloco
    # --------------------------------------------------------

    def finalizar_bloco():

        nonlocal bloco_atual
        nonlocal tipo_bloco_atual

        bloco = normalizar_bloco(
            bloco_atual
        )

        if bloco:

            blocos.append(
                bloco
            )

        bloco_atual = ""
        tipo_bloco_atual = None

    # --------------------------------------------------------
    # Percorrer unidades
    # --------------------------------------------------------

    for unidade in unidades:

        texto = unidade["texto"]
        fragmentos = unidade["fragmentos"]
        lista_principal = unidade["is_list"]

        if not fragmentos:

            fragmentos = [
                {
                    "texto": texto,
                    "negrito": False
                }
            ]

        # ====================================================
        # NOVA ESTROFE AUTOMÁTICA
        # ====================================================

        if lista_principal:

            # IMPORTANTE:
            #
            # Uma nova numeração automática significa
            # obrigatoriamente uma nova estrofe.
            #
            # Isto resolve o problema:
            #
            # 1. estrofe
            #
            # coro
            #
            # 2. estrofe
            #
            # 3. estrofe
            #
            # 4. estrofe

            finalizar_bloco()

            numero_estrofe += 1

            primeira_parte = True

            for fragmento in fragmentos:

                texto_fragmento = normalizar_bloco(
                    fragmento["texto"]
                )

                if not texto_fragmento:
                    continue

                # --------------------------------------------
                # CORO
                # --------------------------------------------

                if fragmento["negrito"]:

                    if tipo_bloco_atual != "coro":

                        finalizar_bloco()

                        bloco_atual = (
                            texto_fragmento
                        )

                        tipo_bloco_atual = "coro"

                    else:

                        bloco_atual = (
                            adicionar_linhas_bloco(
                                bloco_atual,
                                texto_fragmento
                            )
                        )

                    continue

                # --------------------------------------------
                # TEXTO NORMAL DA ESTROFE
                # --------------------------------------------

                if primeira_parte:

                    # Caso exista numeração manual dentro
                    # do próprio texto, aproveitamos o número.
                    match_manual = (
                        NUMERO_ESTROFE_MANUAL_PATTERN.match(
                            texto_fragmento
                        )
                    )

                    if match_manual:

                        numero_estrofe = int(
                            match_manual.group(1)
                        )

                        texto_fragmento = (
                            match_manual
                            .group(2)
                            .strip()
                        )

                    if texto_fragmento:

                        bloco_atual = (
                            f"{numero_estrofe}. "
                            f"{texto_fragmento}"
                        )

                    else:

                        bloco_atual = (
                            f"{numero_estrofe}."
                        )

                    tipo_bloco_atual = "estrofe"

                    primeira_parte = False

                else:

                    if tipo_bloco_atual == "coro":

                        finalizar_bloco()

                        bloco_atual = (
                            texto_fragmento
                        )

                        tipo_bloco_atual = "estrofe"

                    else:

                        bloco_atual = (
                            adicionar_linhas_bloco(
                                bloco_atual,
                                texto_fragmento
                            )
                        )

            continue

        # ====================================================
        # PARÁGRAFO NÃO NUMERADO
        # ====================================================

        for fragmento in fragmentos:

            texto_fragmento = normalizar_bloco(
                fragmento["texto"]
            )

            if not texto_fragmento:
                continue

            # --------------------------------------------
            # NUMERAÇÃO MANUAL
            # --------------------------------------------

            match_manual = (
                NUMERO_ESTROFE_MANUAL_PATTERN.match(
                    texto_fragmento
                )
            )

            if match_manual:

                finalizar_bloco()

                numero_estrofe = int(
                    match_manual.group(1)
                )

                texto_fragmento = (
                    match_manual
                    .group(2)
                    .strip()
                )

                if texto_fragmento:

                    bloco_atual = (
                        f"{numero_estrofe}. "
                        f"{texto_fragmento}"
                    )

                    tipo_bloco_atual = "estrofe"

                continue

            # --------------------------------------------
            # CORO
            # --------------------------------------------

            if fragmento["negrito"]:

                if tipo_bloco_atual != "coro":

                    finalizar_bloco()

                    bloco_atual = (
                        texto_fragmento
                    )

                    tipo_bloco_atual = "coro"

                else:

                    bloco_atual = (
                        adicionar_linhas_bloco(
                            bloco_atual,
                            texto_fragmento
                        )
                    )

                continue

            # --------------------------------------------
            # TEXTO NORMAL
            # --------------------------------------------

            if tipo_bloco_atual == "coro":

                finalizar_bloco()

                bloco_atual = (
                    texto_fragmento
                )

                tipo_bloco_atual = "estrofe"

            elif bloco_atual:

                bloco_atual = (
                    adicionar_linhas_bloco(
                        bloco_atual,
                        texto_fragmento
                    )
                )

            else:

                # Caso raro:
                # texto normal sem numeração.
                numero_estrofe = max(
                    numero_estrofe,
                    1
                )

                bloco_atual = (
                    f"{numero_estrofe}. "
                    f"{texto_fragmento}"
                )

                tipo_bloco_atual = "estrofe"

    # ========================================================
    # ÚLTIMO BLOCO
    # ========================================================

    finalizar_bloco()

    # ========================================================
    # SEPARAÇÃO FINAL
    # ========================================================

    return "\n\n".join(
        bloco
        for bloco in blocos
        if bloco
    )


# ============================================================
# EXTRAIR HINOS
# ============================================================

def extract_hymns_from_docx(
    caminho_entrada
):
    """
    Extrai os 372 conteúdos do documento.
    """

    if not os.path.exists(
        caminho_entrada
    ):

        print(
            f"❌ Arquivo não encontrado: "
            f"{caminho_entrada}"
        )

        return []

    document = Document(
        caminho_entrada
    )

    resultados = []

    categoria_atual = ""

    hino_atual = None
    unidades_hino = []

    id_global = 1

    # ========================================================
    # GUARDAR HINO ATUAL
    # ========================================================

    def guardar_hino_atual():

        nonlocal hino_atual
        nonlocal unidades_hino
        nonlocal id_global

        if hino_atual is None:
            return

        texto_pt = processar_hino(
            unidades_hino
        )

        texto_pt = limpar_texto(
            texto_pt
        )

        if not texto_pt:

            print(
                f"⚠️ Nº {hino_atual['numero']} "
                f"não possui texto. Ignorado."
            )

            hino_atual = None
            unidades_hino = []

            return

        # ====================================================
        # TÍTULO
        # ====================================================

        linhas = [
            linha.strip()
            for linha in texto_pt.split("\n")
            if linha.strip()
        ]

        if linhas:

            titulo_pt = linhas[0]

        else:

            titulo_pt = (
                f"Hino {hino_atual['numero']}"
            )

        # Remove somente eventual número do início
        titulo_pt = re.sub(
            r'^\s*\d+\s*[\.)]\s*',
            '',
            titulo_pt
        ).strip()

        # ====================================================
        # JSON
        # ====================================================

        resultado = {
            "id": id_global,
            "numero": hino_atual["numero"],
            "titulo_pt": titulo_pt,
            "texto_pt": texto_pt,
            "categoria": categoria_atual,
            "musica": hino_atual["musica"]
        }

        resultados.append(
            resultado
        )

        print(
            f"✓ ID {id_global:03d} | "
            f"Nº {hino_atual['numero']:03d} | "
            f"{titulo_pt}"
        )

        id_global += 1

        hino_atual = None
        unidades_hino = []

    # ========================================================
    # PERCORRER DOCUMENTO
    # ========================================================

    for paragraph in document.paragraphs:

        texto_original = (
            obter_texto_original(
                paragraph
            )
        )

        if not texto_original.strip():
            continue

        # ====================================================
        # CABEÇALHO
        # ====================================================

        cabecalho = analisar_cabecalho(
            texto_original
        )

        if cabecalho is not None:

            # Guarda o conteúdo anterior
            guardar_hino_atual()

            # Inicia novo conteúdo
            hino_atual = {
                "numero": cabecalho["numero"],
                "musica": cabecalho["musica"]
            }

            unidades_hino = []

            # ------------------------------------------------
            # Caso o texto esteja no mesmo parágrafo
            #
            # Exemplo real:
            #
            # 355 (Música: ...)
            # 1.Estrela da noite...
            #
            # E também:
            #
            # 366 (Música: ...)
            # A Deus, supremo Benfeitor...
            # ------------------------------------------------

            resto = cabecalho["resto"]

            if resto:

                unidades_hino.append({
                    "texto": resto,
                    "fragmentos": [
                        {
                            "texto": resto,
                            "negrito": False
                        }
                    ],
                    "is_list": False
                })

            continue

        # ====================================================
        # CATEGORIA
        # ====================================================

        if eh_categoria(
            paragraph,
            texto_original
        ):

            # Se havia um hino aberto, termina primeiro.
            guardar_hino_atual()

            categoria_atual = limpar_texto(
                texto_original
            )

            print(
                f"\n📂 Categoria: "
                f"{categoria_atual}"
            )

            continue

        # ====================================================
        # CONTEÚDO DO HINO
        # ====================================================

        if hino_atual is not None:

            unidades_hino.append({

                "texto": texto_original,

                "fragmentos":
                    obter_fragmentos_formatacao(
                        paragraph
                    ),

                "is_list":
                    eh_lista_principal(
                        paragraph
                    )
            })

    # ========================================================
    # GUARDAR ÚLTIMO
    # ========================================================

    guardar_hino_atual()

    return resultados


# ============================================================
# SALVAR JSON
# ============================================================

def salvar_arquivo_json(
    dados,
    caminho_saida
):
    """
    Salva o JSON mantendo a ordem exata dos campos.
    """

    pasta = os.path.dirname(
        caminho_saida
    )

    if pasta:

        os.makedirs(
            pasta,
            exist_ok=True
        )

    with open(
        caminho_saida,
        "w",
        encoding="utf-8"
    ) as arquivo:

        json.dump(
            dados,
            arquivo,
            ensure_ascii=False,
            indent=2
        )

    print()
    print("=" * 60)
    print("💾 JSON GERADO COM SUCESSO")
    print("=" * 60)
    print(
        f"📁 Arquivo: {caminho_saida}"
    )
    print(
        f"📚 Total de conteúdos: "
        f"{len(dados)}"
    )
    print("=" * 60)


# ============================================================
# VALIDAR RESULTADOS
# ============================================================

def validar_resultados(
    dados
):
    """
    Faz verificações para garantir que o resultado
    não perdeu informações importantes.
    """

    print()
    print("=" * 60)
    print("🔎 VALIDAÇÃO")
    print("=" * 60)

    if not dados:

        print(
            "❌ Nenhum conteúdo extraído."
        )

        return

    # ========================================================
    # TOTAL
    # ========================================================

    if len(dados) == 372:

        print(
            "✓ TOTAL CORRETO: 372 conteúdos."
        )

    else:

        print(
            f"⚠️ TOTAL ENCONTRADO: "
            f"{len(dados)}"
        )

        print(
            "   Esperado: 372"
        )

    # ========================================================
    # CAMPOS
    # ========================================================

    campos_esperados = [
        "id",
        "numero",
        "titulo_pt",
        "texto_pt",
        "categoria",
        "musica"
    ]

    campos_corretos = True

    for item in dados:

        campos = list(
            item.keys()
        )

        if campos != campos_esperados:

            campos_corretos = False

            print(
                f"⚠️ Ordem incorreta "
                f"no ID {item['id']}"
            )

    if campos_corretos:

        print(
            "✓ Ordem dos campos correta:"
        )

        print(
            "  id → numero → titulo_pt → "
            "texto_pt → categoria → musica"
        )

    # ========================================================
    # NÚMEROS
    # ========================================================

    numeros = [
        item["numero"]
        for item in dados
    ]

    faltantes = [
        numero
        for numero in range(1, 373)
        if numero not in numeros
    ]

    if not faltantes:

        print(
            "✓ Números 1–372 encontrados."
        )

    else:

        print(
            "⚠️ Números faltantes:"
        )

        print(
            faltantes
        )

    # ========================================================
    # CATEGORIAS
    # ========================================================

    categorias = sorted(
        set(
            item["categoria"]
            for item in dados
            if item["categoria"]
        )
    )

    print(
        f"✓ Categorias encontradas: "
        f"{len(categorias)}"
    )

    for categoria in categorias:

        quantidade = sum(
            1
            for item in dados
            if item["categoria"] == categoria
        )

        print(
            f"   • {categoria}: "
            f"{quantidade}"
        )

    # ========================================================
    # HTML
    # ========================================================

    html_encontrado = False

    for item in dados:

        texto = item["texto_pt"]

        if (
            "<b>" in texto
            or "</b>" in texto
            or "<strong>" in texto
            or "</strong>" in texto
        ):

            html_encontrado = True

            print(
                f"⚠️ HTML encontrado "
                f"no nº {item['numero']}"
            )

    if not html_encontrado:

        print(
            "✓ Nenhum HTML de negrito encontrado."
        )

    # ========================================================
    # EXEMPLO DO PRIMEIRO HINO
    # ========================================================

    primeiro = next(
        (
            item
            for item in dados
            if item["numero"] == 1
        ),
        None
    )

    if primeiro:

        print()
        print(
            "📖 VERIFICAÇÃO DO HINO Nº 1"
        )
        print("-" * 60)

        print(
            primeiro["texto_pt"]
        )

        print("-" * 60)

    # ========================================================
    # DOXOLOGIAS
    # ========================================================

    doxologias = [
        item
        for item in dados
        if item["categoria"]
        == "DOXOLOGIAS"
    ]

    print()

    print(
        f"✓ Doxologias extraídas: "
        f"{len(doxologias)}"
    )

    if doxologias:

        print(
            "  Números: "
            + ", ".join(
                str(item["numero"])
                for item in doxologias
            )
        )


# ============================================================
# EXECUÇÃO
# ============================================================

if __name__ == "__main__":

    print()
    print("=" * 60)
    print("📖 EXTRATOR DE HINOS IECA")
    print("=" * 60)
    print()

    dados = extract_hymns_from_docx(
        ARQUIVO_ENTRADA
    )

    if dados:

        salvar_arquivo_json(
            dados,
            ARQUIVO_SAIDA
        )

        validar_resultados(
            dados
        )

    else:

        print(
            "❌ Nenhum conteúdo foi extraído."
        )

    print()
    print("=" * 60)
    print("🏁 PROCESSAMENTO TERMINADO")
    print("=" * 60)