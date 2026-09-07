extends Control

var itens: Array = []
var inimigos: Array = []
var salas: Array = []

var itens_csv: String = "res://CSVs/Itens.csv"
var salas_csv: String = "res://CSVs/Salas.csv"
var inimigos_csv: String = "res://CSVs/Inimigos.csv"

func _ready() -> void:
	carregar_csv_itens()
	carregar_csv_inimigos()
	carregar_csv_salas()

func carregar_csv_itens():
	var arquivo = FileAccess.open(itens_csv, FileAccess.READ)

	if arquivo == null:
		push_error("Nao foi possivel abrir itens.csv")
		return

	# limpa caso a função seja chamada novamente
	itens.clear()

	# pula cabeçalho
	arquivo.get_line()

	while not arquivo.eof_reached():
		var linha = arquivo.get_line()

		if linha.strip_edges() == "":
			continue

		var colunas = linha.split(",")

		var item = {
			"id": colunas[0],
			"nome": colunas[1],
			"tipo": colunas[2],
			"dano": int(colunas[3]),
			"velocidade_ataque": float(colunas[4]),
			"raridade": colunas[5],
			"valor": int(colunas[6]),
			"descricao": colunas[7]
		}

		itens.append(item)

	arquivo.close()

	print("Banco carregado: ", itens.size(), " itens.")

func carregar_csv_inimigos():
	var arquivo = FileAccess.open(inimigos_csv, FileAccess.READ)

	if arquivo == null:
		push_error("Nao foi possivel abrir inimigos.csv")
		return

	# limpa caso a função seja chamada novamente
	inimigos.clear()

	# pula cabeçalho
	arquivo.get_line()

	while not arquivo.eof_reached():
		var linha = arquivo.get_line()

		if linha.strip_edges() == "":
			continue

		var colunas = linha.split(",")

		var inimigo = {
			"id": colunas[0],
			"nome": colunas[1],
			"vida": colunas[2],
			"dano": int(colunas[3]),
			"velocidade_movimento": float(colunas[4]),
			"raridade": colunas[5],
			"recompensa": int(colunas[6]),
		}

		inimigos.append(inimigo)

	arquivo.close()

	print("Banco carregado: ", inimigos.size(), " inimigos.")

func carregar_csv_salas():
	var arquivo = FileAccess.open(salas_csv, FileAccess.READ)

	if arquivo == null:
		push_error("Nao foi possivel abrir Salas.csv")
		return

	arquivo.get_line() # pula cabeçalho

	while not arquivo.eof_reached():
		var linha = arquivo.get_line()

		if linha.strip_edges() == "":
			continue

		var colunas = linha.split(",")

		var sala = {
			"id": colunas[0],
			"tipo": colunas[1],
			"peso_sorteio": int(colunas[2]),
			"inimigos_permitidos": colunas[3],
			"nivel_minimo": int(colunas[4])
		}

		salas.append(sala)

	arquivo.close()

	print("Salas carregadas: ", salas.size())

func buscar_por_id(id: String) -> Dictionary:
	for item in itens:
		if item["id"] == id:
			return item

	return {}

func escolher_aleatorio_ponderado(lista: Array) -> Dictionary:
	if lista.is_empty():
		return {}

	var peso_total = 0

	for elemento in lista:
		peso_total += obter_peso(elemento["raridade"])

	if peso_total <= 0:
		return {}

	var sorteio = randi() % peso_total
	var acumulado = 0

	for elemento in lista:
		acumulado += obter_peso(elemento["raridade"])
sexo
		if sorteio < acumulado:
			return elemento

	return lista[0]

func obter_peso(raridade: String) -> int:

	match raridade.strip_edges():
		"Comum":
			return 60

		"Incomum":
			return 25

		"Raro":
			return 10

		"Epico":
			return 4

		"Lendario":
			return 1

	return 1

func escolher_sala_ponderada() -> Dictionary:
	if salas.is_empty():
		push_error("Nenhuma sala carregada.")
		return {}

	var peso_total: int = 0

	for sala in salas:
		peso_total += sala["peso_sorteio"]

	if peso_total <= 0:
		push_error("Peso total das salas é zero.")
		return {}

	var sorteio = randi_range(1, peso_total)

	var acumulado: int = 0

	for sala in salas:
		acumulado += sala["peso_sorteio"]

		if sorteio <= acumulado:
			return sala

	return {}

func _on_shuffle_item_button_down() -> void:

	var escolhido = escolher_aleatorio_ponderado(itens)

	if escolhido.is_empty():
		return

	print("Item escolhido: ", escolhido["nome"])
	print("Raridade: ", escolhido["raridade"])

func _on_shuffle_enemy_button_down() -> void:
	var escolhido = escolher_aleatorio_ponderado(inimigos)

	if escolhido.is_empty():
		return

	print("Inimigo escolhido: ", escolhido["nome"])
	print("Raridade: ", escolhido["raridade"])

func _on_shuffle_room_button_down() -> void:
	var sala_escolhida = escolher_sala_ponderada()

	if sala_escolhida.is_empty():
		return

	print("Sala escolhida: ", sala_escolhida["id"])
	print("Tipo: ", sala_escolhida["tipo"])

func _on_shuffle_all_button_down() -> void:
	_on_shuffle_enemy_button_down()
	_on_shuffle_item_button_down()
	_on_shuffle_room_button_down()
