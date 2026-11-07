import json
import os
import re
from docx import Document


# =============================================================
# CONFIGURAÇÃO
# =============================================================

CONFIG = {
    # ---------------------------------------------------------
    # IDIOMA / VARIANTE
    # ---------------------------------------------------------
    "idioma": "umbundo",

    # ---------------------------------------------------------
    # NOMES DOS TIPOS DE CONTEÚDO
    # ---------------------------------------------------------
    "nomes": {
        "hino": "Ekovongo",
        "hinos": "Ekovongo",

        "invocatoria": "Akovongo",
        "invocatorias": "Akovongo",

        "litania": "Onoha",
        "litanias": "Onoha",

        "salmo": "Salmo",
        "salmos": "Salmos",
    },

    # ---------------------------------------------------------
    # DOCUMENTOS DE ENTRADA
    # ---------------------------------------------------------
    "documentos": {
        "hinos": "hinos_umbundo.docx",
        "litanias": "litanias_umbundo.docx",
        "salmos": "salmos.docx",
        "invocatorias": "invocatorias_umbundo.docx",
    },

    # ---------------------------------------------------------
    # FICHEIROS JSON DE SAÍDA
    # ---------------------------------------------------------
    "json": {
        "hinos": "hinos_umbundo.json",
        "litanias": "litanias_umbundo.json",
        "salmos": "salmos.json",
        "invocatorias": "invocatorias_umbundo.json",
    },

    # ---------------------------------------------------------
    # CONFIGURAÇÃO DOS HINOS
    # ---------------------------------------------------------
    "hinos_config": {
        # Hinos numerados como:
        #
        # 001
        # 002
        # 003
        #
        "digitos_numero": 3,

        # Campo usado como título
        "campo_titulo": "titulo_pt",

        # Campo usado como texto
        "campo_texto": "texto_pt",

        # Categoria inicial caso o documento comece
        # diretamente com um hino.
        "categoria_inicial": "Geral",

        # Tamanho máximo de uma linha que pode ser
        # considerada categoria.
        "max_tamanho_categoria": 80,
    },

    # ---------------------------------------------------------
    # CONFIGURAÇÃO DAS INVOCATÓRIAS
    # ---------------------------------------------------------
    "invocatorias_config": {
        "categoria_inicial": "Geral",

        # Formato esperado:
        #
        # 1.
        # 2.
        # 3.
        #
        "regex_numero": r"^(\d+)\.",

        # Separadores que podem aparecer no documento
        "separadores": [
            "xxx",
            "***xXx***",
        ],
    },

    # ---------------------------------------------------------
    # CONFIGURAÇÃO DAS LITANIAS
    # ---------------------------------------------------------
    "litanias_config": {
        # Formato:
        #
        # ONOHA YATETE
        # ONOHA YATETE – título
        #
        "prefixo": "ONOHA",

        "separadores": [
            "xxx",
            "***xXx***",
        ],
    },
}


# =============================================================
# FUNÇÕES AUXILIARES
# =============================================================

def normalizar_linha(linha):
    """
    Normaliza uma linha sem alterar o conteúdo textual.

    Remove:
    - tabs;
    - espaços duplicados;
    - espaços no início/fim.
    """

    if linha is None:
        return ""

    linha = linha.replace("\t", " ")

    linha = re.sub(
        r"[ ]+",
        " ",
        linha
    )

    return linha.strip()


def dividir_linhas(texto):
    """
    Divide corretamente as linhas internas de um parágrafo
    do Word.

    O DOCX pode conter várias linhas dentro de um único
    parágrafo através de Enter, Shift + Enter ou outras
    quebras reconhecidas por splitlines().
    """

    if not texto:
        return []

    resultado = []

    for linha in texto.splitlines():

        linha = normalizar_linha(linha)

        if linha:
            resultado.append(linha)

    return resultado


def garantir_pasta(caminho):
    """
    Cria a pasta de destino caso ela ainda não exista.
    """

    pasta = os.path.dirname(caminho)

    if pasta:
        os.makedirs(
            pasta,
            exist_ok=True
        )


def salvar_arquivo_json(
    dados,
    caminho_saida,
    nome_tipo
):
    """
    Salva os dados em JSON.
    """

    if not dados:

        print(
            f"⚠️ Aviso: Nenhum dado extraído para "
            f"{nome_tipo}. "
            f"O arquivo não será criado."
        )

        return

    garantir_pasta(caminho_saida)

    with open(
        caminho_saida,
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            dados,
            f,
            ensure_ascii=False,
            indent=2
        )

    print(
        f"✅ Sucesso: {len(dados)} "
        f"{nome_tipo} extraídos em: "
        f"{caminho_saida}"
    )


def localizar_documento(
    base,
    nome
):
    """
    Procura o documento em vários locais possíveis.
    """

    caminhos = [
        os.path.join(
            base,
            nome
        ),

        os.path.join(
            base,
            "..",
            nome
        ),

        os.path.join(
            base,
            "..",
            "..",
            nome
        ),
    ]

    for caminho in caminhos:

        caminho = os.path.abspath(
            caminho
        )

        if os.path.exists(caminho):

            return caminho

    return None


# =============================================================
# DETECÇÃO DE CATEGORIAS DOS HINOS
# =============================================================

def linha_e_categoria_hino(
    linha,
    limite=80
):
    """
    Determina se uma linha do DOCX representa uma categoria
    dos hinos.

    No documento de Umbundo as categorias aparecem assim:

        EKOVONGO

        EFENDELO LESIVAYO

        UCITO WA YESU

    Características consideradas:

    - linha não vazia;
    - não possui números;
    - tamanho limitado;
    - está em letras maiúsculas;
    - possui pelo menos letras;
    - não começa com número de hino.

    IMPORTANTE:

    Esta função pode ser chamada mesmo quando existe um
    hino aberto. Isso permite detectar corretamente:

        004
        ...
        EFENDELO LESIVAYO
        005

    fazendo com que 004 termine antes da nova categoria.
    """

    if not linha:
        return False

    linha = linha.strip()

    if not linha:
        return False

    # ---------------------------------------------------------
    # Não aceitar linhas muito grandes como categoria
    # ---------------------------------------------------------

    if len(linha) > limite:
        return False

    # ---------------------------------------------------------
    # Não aceitar linhas que contenham números
    # ---------------------------------------------------------

    if re.search(r"\d", linha):
        return False

    # ---------------------------------------------------------
    # Precisa conter pelo menos uma letra
    # ---------------------------------------------------------

    if not re.search(r"[A-Za-zÀ-ÿ]", linha):
        return False

    # ---------------------------------------------------------
    # Verificar se está em maiúsculas
    #
    # isupper() funciona corretamente para caracteres
    # acentuados e outras letras Unicode.
    # ---------------------------------------------------------

    if not linha.isupper():
        return False

    # ---------------------------------------------------------
    # Evitar linhas que sejam apenas pontuação
    # ---------------------------------------------------------

    somente_letras = re.sub(
        r"[^A-Za-zÀ-ÿ]",
        "",
        linha
    )

    if not somente_letras:
        return False

    return True


def aplicar_titulo_categoria(linha):
    """
    Converte:

        EFENDELO LESIVAYO

    em:

        Efendelo Lesivayo

    e:

        UCITO WA YESU

    em:

        Ucito Wa Yesu
    """

    return linha.strip().title()


# =============================================================
# EXTRAIR HINOS
# =============================================================

def extrair_hinos(
    docx_path,
    output_json
):
    """
    Extrai hinos de um DOCX.

    Estrutura esperada:

        EKOVONGO

        001

        1. Uhi ño! Uhi ño!
        Tu fendeli ño;
        Uhiño loku yeva ondaka eyi.

        2. Uhi ño! Uhi ño!

        EFENDELO LESIVAYO

        005

        1. O kola, o kola, o kola,
        ...

    O resultado será:

        {
            "id": 1,
            "numero": "001",
            "titulo_pt": "Uhi ño! Uhi ño!",
            "texto_pt": "...",
            "categoria": "Ekovongo"
        }

    E:

        {
            "id": 5,
            "numero": "005",
            "titulo_pt": "O kola, o kola, o kola,",
            "texto_pt": "...",
            "categoria": "Efendelo Lesivayo"
        }
    """

    if not os.path.exists(docx_path):

        print(
            f"❌ Erro: '{docx_path}' não encontrado."
        )

        return

    doc = Document(
        docx_path
    )

    hinos = []

    hino_actual = None
    linhas_hino = []

    categoria_actual = CONFIG[
        "hinos_config"
    ][
        "categoria_inicial"
    ]

    digitos = CONFIG[
        "hinos_config"
    ][
        "digitos_numero"
    ]

    limite_categoria = CONFIG[
        "hinos_config"
    ][
        "max_tamanho_categoria"
    ]

    regex_numero = re.compile(
        rf"^(\d{{{digitos}}})$"
    )

    # =========================================================
    # EXTRAIR TÍTULO
    # =========================================================

    def extrair_titulo(linhas):

        if not linhas:
            return ""

        # -----------------------------------------------------
        # Procurar o primeiro verso.
        #
        # Exemplo:
        #
        # 1. Uhi ño! Uhi ño!
        #
        # Resultado:
        #
        # Uhi ño! Uhi ño!
        # -----------------------------------------------------

        for linha in linhas:

            match = re.match(
                r"^1\.\s*(.+)$",
                linha
            )

            if match:

                return match.group(
                    1
                ).strip()

        # -----------------------------------------------------
        # Fallback
        # -----------------------------------------------------

        return linhas[0].strip()

    # =========================================================
    # FINALIZAR HINO
    # =========================================================

    def finalizar_hino():

        nonlocal hino_actual
        nonlocal linhas_hino

        if hino_actual is None:
            return

        linhas = [
            linha.strip()
            for linha in linhas_hino
            if linha.strip()
        ]

        # -----------------------------------------------------
        # Sem conteúdo
        # -----------------------------------------------------

        if not linhas:

            hino_actual[
                CONFIG["hinos_config"]["campo_titulo"]
            ] = ""

            hino_actual[
                CONFIG["hinos_config"]["campo_texto"]
            ] = ""

            hinos.append(
                hino_actual
            )

            hino_actual = None
            linhas_hino = []

            return

        # -----------------------------------------------------
        # TÍTULO
        # -----------------------------------------------------

        titulo = extrair_titulo(
            linhas
        )

        # -----------------------------------------------------
        # TEXTO
        #
        # Mantemos a primeira linha:
        #
        # 1. Uhi ño! Uhi ño!
        #
        # Isso é importante porque o título também pertence
        # ao texto do hino.
        # -----------------------------------------------------

        texto = "\n\n".join(
            linhas
        ).strip()

        # -----------------------------------------------------
        # GUARDAR
        # -----------------------------------------------------

        hino_actual[
            CONFIG["hinos_config"]["campo_titulo"]
        ] = titulo

        hino_actual[
            CONFIG["hinos_config"]["campo_texto"]
        ] = texto

        hinos.append(
            hino_actual
        )

        hino_actual = None
        linhas_hino = []

    # =========================================================
    # PERCORRER DOCUMENTO
    # =========================================================

    for para in doc.paragraphs:

        linhas_paragrafo = dividir_linhas(
            para.text
        )

        if not linhas_paragrafo:
            continue

        for linha in linhas_paragrafo:

            # =================================================
            # PRIMEIRO:
            # DETECTAR CATEGORIA
            # =================================================
            #
            # IMPORTANTE:
            #
            # A categoria pode aparecer DEPOIS de um hino.
            #
            # Exemplo:
            #
            # 004
            # ...
            #
            # EFENDELO LESIVAYO
            #
            # 005
            #
            # Portanto, se encontrarmos uma categoria enquanto
            # existe um hino aberto, primeiro finalizamos o hino.
            # =================================================

            if linha_e_categoria_hino(
                linha,
                limite_categoria
            ):

                # -------------------------------------------------
                # Se existe hino aberto, terminá-lo primeiro.
                # -------------------------------------------------

                if hino_actual is not None:

                    finalizar_hino()

                # -------------------------------------------------
                # Atualizar categoria.
                # -------------------------------------------------

                categoria_actual = aplicar_titulo_categoria(
                    linha
                )

                print(
                    f"📚 Categoria detectada: "
                    f"{categoria_actual}"
                )

                continue

            # =================================================
            # SEGUNDO:
            # NÚMERO DO HINO
            # =================================================

            match_numero = regex_numero.match(
                linha
            )

            if match_numero:

                # -------------------------------------------------
                # Se por algum motivo existir um hino aberto,
                # finalizar antes de iniciar outro.
                # -------------------------------------------------

                finalizar_hino()

                numero = match_numero.group(1)

                hino_actual = {
                    "id": len(hinos) + 1,
                    "numero": numero,
                    "titulo_pt": "",
                    "texto_pt": "",
                    "categoria": categoria_actual
                }

                linhas_hino = []

                continue

            # =================================================
            # TERCEIRO:
            # CONTEÚDO DO HINO
            # =================================================

            if hino_actual is not None:

                linhas_hino.append(
                    linha
                )

    # =========================================================
    # FINALIZAR ÚLTIMO HINO
    # =========================================================

    finalizar_hino()

    # =========================================================
    # ORDENAR POR NÚMERO
    # =========================================================

    hinos.sort(
        key=lambda hino: (
            int(hino["numero"])
            if str(hino["numero"]).isdigit()
            else 0
        )
    )

    # =========================================================
    # REORGANIZAR IDs
    # =========================================================

    for indice, hino in enumerate(
        hinos,
        start=1
    ):

        hino["id"] = indice

    # =========================================================
    # MOSTRAR RESUMO DAS CATEGORIAS
    # =========================================================

    categorias = {}

    for hino in hinos:

        categoria = hino.get(
            "categoria",
            "Geral"
        )

        if categoria not in categorias:
            categorias[categoria] = []

        categorias[categoria].append(
            hino
        )

    print()
    print("-" * 60)
    print("CATEGORIAS DOS HINOS")
    print("-" * 60)

    for categoria, lista in categorias.items():

        numeros = []

        for hino in lista:

            try:

                numeros.append(
                    int(hino["numero"])
                )

            except (ValueError, TypeError):

                pass

        if numeros:

            menor = min(numeros)
            maior = max(numeros)

            print(
                f"📚 {categoria}: "
                f"{len(lista)} hinos "
                f"({menor:03d}–{maior:03d})"
            )

        else:

            print(
                f"📚 {categoria}: "
                f"{len(lista)} hinos"
            )

    print("-" * 60)
    print()

    # =========================================================
    # SALVAR
    # =========================================================

    salvar_arquivo_json(
        hinos,
        output_json,
        CONFIG["nomes"]["hinos"]
    )


# =============================================================
# EXTRAIR LITANIAS
# =============================================================

def extrair_litanias(
    docx_path,
    output_json
):
    """
    Extrai litanias.

    Formatos aceites:

        ONOHA YATETE

        ONOHA YATETE – título

        ONOHA YAVALI - título
    """

    if not os.path.exists(docx_path):

        print(
            f"❌ Erro: '{docx_path}' não encontrado."
        )

        return

    doc = Document(
        docx_path
    )

    litanias = []

    litania_actual = None
    texto_acumulado = []

    prefixo = CONFIG[
        "litanias_config"
    ][
        "prefixo"
    ]

    separadores = {
        item.lower()
        for item in CONFIG[
            "litanias_config"
        ][
            "separadores"
        ]
    }

    regex_litania = re.compile(
        rf"^{re.escape(prefixo)}\s+(.+?)(?:\s+[–-]\s+|\s*$)",
        re.IGNORECASE
    )

    def finalizar_litania():

        nonlocal litania_actual
        nonlocal texto_acumulado

        if litania_actual is None:
            return

        litania_actual[
            "texto"
        ] = "\n\n".join(
            texto_acumulado
        ).strip()

        litanias.append(
            litania_actual
        )

        litania_actual = None
        texto_acumulado = []

    for para in doc.paragraphs:

        linhas = dividir_linhas(
            para.text
        )

        if not linhas:
            continue

        for linha in linhas:

            # =================================================
            # NOVA LITANIA
            # =================================================

            match = regex_litania.match(
                linha
            )

            if match:

                finalizar_litania()

                titulo = linha
                subtitulo = titulo

                if "–" in titulo:

                    partes = titulo.split(
                        "–",
                        1
                    )

                    subtitulo = partes[
                        1
                    ].strip()

                elif "-" in titulo:

                    partes = titulo.split(
                        "-",
                        1
                    )

                    subtitulo = partes[
                        1
                    ].strip()

                litania_actual = {
                    "id": len(litanias) + 1,
                    "titulo": titulo,
                    "subtitulo": subtitulo,
                    "texto": ""
                }

                texto_acumulado = []

                continue

            # =================================================
            # TEXTO
            # =================================================

            if litania_actual:

                if linha.lower() in separadores:
                    continue

                texto_acumulado.append(
                    linha
                )

    finalizar_litania()

    salvar_arquivo_json(
        litanias,
        output_json,
        CONFIG["nomes"]["litanias"]
    )


# =============================================================
# EXTRAIR SALMOS
# =============================================================

def extrair_salmos(
    docx_path,
    output_json
):
    """
    Extrai salmos mantendo formatação em negrito.
    """

    if not os.path.exists(docx_path):

        print(
            f"❌ Erro: '{docx_path}' não encontrado."
        )

        return

    doc = Document(
        docx_path
    )

    salmos = []

    salmo_actual = None
    texto_formatado = []

    regex_salmo = re.compile(
        r"^SALMO\s+(\d+)",
        re.IGNORECASE
    )

    def finalizar_salmo():

        nonlocal salmo_actual
        nonlocal texto_formatado

        if salmo_actual is None:
            return

        salmo_actual[
            "texto"
        ] = "".join(
            texto_formatado
        ).strip()

        salmos.append(
            salmo_actual
        )

        salmo_actual = None
        texto_formatado = []

    for para in doc.paragraphs:

        linhas = dividir_linhas(
            para.text
        )

        if not linhas:
            continue

        # -----------------------------------------------------
        # Detectar novo salmo
        # -----------------------------------------------------

        encontrou_salmo = False

        for linha in linhas:

            match = regex_salmo.match(
                linha
            )

            if match:

                finalizar_salmo()

                salmo_actual = {
                    "id": len(salmos) + 1,
                    "numero": match.group(1),
                    "texto": ""
                }

                texto_formatado = []

                encontrou_salmo = True

                continue

            # -------------------------------------------------
            # Conteúdo
            # -------------------------------------------------

            if salmo_actual:

                texto_formatado.append(
                    linha
                )

                texto_formatado.append(
                    "\n\n"
                )

        # -----------------------------------------------------
        # Evita processamento duplicado
        # -----------------------------------------------------

        if encontrou_salmo:
            continue

    finalizar_salmo()

    salvar_arquivo_json(
        salmos,
        output_json,
        CONFIG["nomes"]["salmos"]
    )


# =============================================================
# EXTRAIR INVOCATÓRIAS
# =============================================================

def extrair_invocatorias(
    docx_path,
    output_json
):
    """
    Extrai invocatórias.

    Para Umbundo:

        Akovongo 1
        Akovongo 2
        Akovongo 3
        ...
    """

    if not os.path.exists(docx_path):

        print(
            f"❌ Erro: '{docx_path}' não encontrado."
        )

        return

    doc = Document(
        docx_path
    )

    invocatorias = []

    invocatoria_actual = None
    texto_formatado = []

    categoria_actual = CONFIG[
        "invocatorias_config"
    ][
        "categoria_inicial"
    ]

    regex_numero = re.compile(
        CONFIG[
            "invocatorias_config"
        ][
            "regex_numero"
        ]
    )

    nome_invocatoria = CONFIG[
        "nomes"
    ][
        "invocatoria"
    ]

    separadores = {
        item.lower()
        for item in CONFIG[
            "invocatorias_config"
        ][
            "separadores"
        ]
    }

    def finalizar_invocatoria():

        nonlocal invocatoria_actual
        nonlocal texto_formatado

        if invocatoria_actual is None:
            return

        invocatoria_actual[
            "texto"
        ] = "".join(
            texto_formatado
        ).strip()

        invocatorias.append(
            invocatoria_actual
        )

        invocatoria_actual = None
        texto_formatado = []

    def adicionar_texto(
        texto
    ):

        if texto:

            texto_formatado.append(
                texto
            )

    for para in doc.paragraphs:

        linhas = dividir_linhas(
            para.text
        )

        if not linhas:
            continue

        for linha in linhas:

            # =================================================
            # NÚMERO DA INVOCATÓRIA
            # =================================================

            match_numero = regex_numero.match(
                linha
            )

            if match_numero:

                finalizar_invocatoria()

                num = match_numero.group(
                    1
                )

                invocatoria_actual = {
                    "id": len(invocatorias) + 1,
                    "numero": num,
                    "titulo": (
                        f"{nome_invocatoria} "
                        f"{num}"
                    ),
                    "categoria": categoria_actual,
                    "texto": ""
                }

                texto_formatado = []

                texto_sem_numero = re.sub(
                    rf"^\s*{re.escape(num)}\.\s*",
                    "",
                    linha,
                    count=1
                )

                adicionar_texto(
                    texto_sem_numero
                )

                texto_formatado.append(
                    "\n\n"
                )

                continue

            # =================================================
            # CATEGORIA
            # =================================================

            if invocatoria_actual is None:

                if linha_e_categoria_hino(
                    linha,
                    60
                ):

                    categoria_actual = (
                        aplicar_titulo_categoria(
                            linha
                        )
                    )

                continue

            # =================================================
            # SEPARADORES
            # =================================================

            if linha.lower() in separadores:
                continue

            # =================================================
            # CONTINUAÇÃO
            # =================================================

            adicionar_texto(
                linha
            )

            texto_formatado.append(
                "\n\n"
            )

    finalizar_invocatoria()

    salvar_arquivo_json(
        invocatorias,
        output_json,
        CONFIG["nomes"]["invocatorias"]
    )


# =============================================================
# EXECUÇÃO
# =============================================================

if __name__ == "__main__":

    print()
    print("=" * 60)
    print("        EXTRATOR DO HINÁRIO IECA")
    print("=" * 60)
    print()

    print(
        f"🌍 Idioma: "
        f"{CONFIG['idioma'].capitalize()}"
    )

    print(
        f"🎵 Hinos: "
        f"{CONFIG['nomes']['hinos']}"
    )

    print(
        f"☀️ Invocatórias: "
        f"{CONFIG['nomes']['invocatorias']}"
    )

    print(
        f"📜 Litanias: "
        f"{CONFIG['nomes']['litanias']}"
    )

    print()

    # =========================================================
    # DIRETÓRIO BASE
    # =========================================================

    base = os.path.dirname(
        os.path.abspath(__file__)
    )

    # =========================================================
    # DIRETÓRIO DOS JSON
    # =========================================================

    data_dir = os.path.abspath(
        os.path.join(
            base,
            "..",
            "assets",
            "dados"
        )
    )

    os.makedirs(
        data_dir,
        exist_ok=True
    )

    # =========================================================
    # DOCUMENTOS
    # =========================================================

    documento_hinos = localizar_documento(
        base,
        CONFIG["documentos"]["hinos"]
    )

    documento_litanias = localizar_documento(
        base,
        CONFIG["documentos"]["litanias"]
    )

    documento_salmos = localizar_documento(
        base,
        CONFIG["documentos"]["salmos"]
    )

    documento_invocatorias = localizar_documento(
        base,
        CONFIG["documentos"]["invocatorias"]
    )

    # =========================================================
    # HINOS
    # =========================================================

    if documento_hinos:

        extrair_hinos(
            documento_hinos,
            os.path.join(
                data_dir,
                CONFIG["json"]["hinos"]
            )
        )

    else:

        print(
            "⚠️ Documento de hinos não encontrado:"
        )

        print(
            f"   {CONFIG['documentos']['hinos']}"
        )

    # =========================================================
    # LITANIAS
    # =========================================================

    if documento_litanias:

        extrair_litanias(
            documento_litanias,
            os.path.join(
                data_dir,
                CONFIG["json"]["litanias"]
            )
        )

    else:

        print(
            "⚠️ Documento de litanias não encontrado:"
        )

        print(
            f"   {CONFIG['documentos']['litanias']}"
        )

    # =========================================================
    # SALMOS
    # =========================================================

    if documento_salmos:

        extrair_salmos(
            documento_salmos,
            os.path.join(
                data_dir,
                CONFIG["json"]["salmos"]
            )
        )

    else:

        print(
            "⚠️ Documento de salmos não encontrado:"
        )

        print(
            f"   {CONFIG['documentos']['salmos']}"
        )

    # =========================================================
    # INVOCATÓRIAS
    # =========================================================

    if documento_invocatorias:

        extrair_invocatorias(
            documento_invocatorias,
            os.path.join(
                data_dir,
                CONFIG["json"]["invocatorias"]
            )
        )

    else:

        print(
            "⚠️ Documento de invocatórias não encontrado:"
        )

        print(
            f"   {CONFIG['documentos']['invocatorias']}"
        )

    # =========================================================
    # FINAL
    # =========================================================

    print()
    print("=" * 60)
    print("             EXTRAÇÃO CONCLUÍDA")
    print("=" * 60)
    print()

    print(
        f"📂 JSONs: {data_dir}"
    )

    print()