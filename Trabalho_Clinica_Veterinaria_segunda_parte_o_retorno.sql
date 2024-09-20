create database clinica;

use clinica;

-- Criação de Tabelas

CREATE TABLE Pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    idade INT NOT NULL
);

CREATE TABLE Veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50) NOT NULL
);

CREATE TABLE Consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_veterinario INT NOT NULL,
    data_consulta DATE NOT NULL,
    custo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario)
);

CREATE TABLE Log_Consultas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    custo_antigo DECIMAL(10, 2) NOT NULL,
    custo_novo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta)
);

-- Inserts nas Tabelas

INSERT INTO Pacientes (nome, especie, idade) VALUES ('Rex', 'Cachorro', 5);
INSERT INTO Pacientes (nome, especie, idade) VALUES ('Miau', 'Gato', 3);
INSERT INTO Pacientes (nome, especie, idade) VALUES ('Fifi', 'Coelho', 2);

INSERT INTO Veterinarios (nome, especialidade) VALUES ('Dr. Ana', 'Cardiologia');
INSERT INTO Veterinarios (nome, especialidade) VALUES ('Dr. João', 'Ortopedia');
INSERT INTO Veterinarios (nome, especialidade) VALUES ('Dr. Carla', 'Dermatologia');

INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo) 
VALUES (1, 1, '2024-09-20', 150.00);

INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo) 
VALUES (2, 2, '2024-09-21', 100.00);

INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo) 
VALUES (3, 3, '2024-09-22', 75.00);

-- Criação de Procedures 

DELIMITER //

CREATE PROCEDURE agendar_consulta (
    IN p_id_paciente INT,
    IN p_id_veterinario INT,
    IN p_data_consulta DATE,
    IN p_custo DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (p_id_paciente, p_id_veterinario, p_data_consulta, p_custo);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE atualizar_paciente (
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR(100),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INT
)
BEGIN
    UPDATE Pacientes
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE remover_consulta (
    IN p_id_consulta INT
)
BEGIN
    DELETE FROM Consultas
    WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION total_gasto_paciente (p_id_paciente INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);
    
    -- Calcular o total gasto pelo paciente em consultas
    SELECT IFNULL(SUM(custo), 0) INTO total
    FROM Consultas
    WHERE id_paciente = p_id_paciente;
    
    RETURN total;
END //

DELIMITER ;

-- Testes das Procedures

CALL agendar_consulta(1, 2, '2024-09-23', 120.00);

SELECT * FROM Consultas;

CALL atualizar_paciente(1, 'Rexy', 'Cachorro', 6);

SELECT * FROM Pacientes WHERE id_paciente = 1;

CALL remover_consulta(1);

SELECT * FROM Consultas;

SELECT total_gasto_paciente(1) AS total_gasto;

-- Criação de Triggers

DELIMITER //

CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON Pacientes
FOR EACH ROW
BEGIN
    -- Verificar se a idade é um número positivo
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Idade inválida. A idade deve ser um número positivo.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON Consultas
FOR EACH ROW
BEGIN
    -- Verificar se o custo foi alterado
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //

DELIMITER ;

-- Segunda Parte

-- Tabelas

CREATE TABLE Medicamentos (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dosagem VARCHAR(50) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Procedimentos (
    id_procedimento INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    custo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta)
);

CREATE TABLE Prescricoes (
    id_prescricao INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    id_medicamento INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta),
    FOREIGN KEY (id_medicamento) REFERENCES Medicamentos(id_medicamento)
);

-- Inserts

INSERT INTO Medicamentos (nome, dosagem, preco) VALUES ('Amoxicilina', '250mg', 30.00);
INSERT INTO Medicamentos (nome, dosagem, preco) VALUES ('Antipulgas', '1 dose', 50.00);
INSERT INTO Medicamentos (nome, dosagem, preco) VALUES ('Vacina Raiva', '1 ml', 70.00);
INSERT INTO Prescricoes (id_consulta, id_medicamento, quantidade) VALUES (4, 1, 10);  
INSERT INTO Prescricoes (id_consulta, id_medicamento, quantidade) VALUES (3, 2, 1);   
INSERT INTO Prescricoes (id_consulta, id_medicamento, quantidade) VALUES (2, 3, 1);   
INSERT INTO Procedimentos (id_consulta, descricao, custo) VALUES (1, 'Exame de sangue', 100.00);
INSERT INTO Procedimentos (id_consulta, descricao, custo) VALUES (2, 'Raio-X', 200.00);
INSERT INTO Procedimentos (id_consulta, descricao, custo) VALUES (3, 'Cirurgia de remoção de tumor', 500.00);

-- Triggers

DELIMITER //

CREATE TRIGGER verificar_preco_medicamento
BEFORE INSERT ON Medicamentos
FOR EACH ROW
BEGIN
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Preço inválido. O preço deve ser um valor positivo.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER atualizar_custo_total_consulta
AFTER INSERT ON Procedimentos
FOR EACH ROW
BEGIN
    UPDATE Consultas
    SET custo = custo + NEW.custo
    WHERE id_consulta = NEW.id_consulta;
END //

DELIMITER ;

CREATE TABLE Log_Prescricoes (
    id_log_prescricao INT AUTO_INCREMENT PRIMARY KEY,
    id_prescricao INT NOT NULL,
    data_prescricao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_prescricao) REFERENCES Prescricoes(id_prescricao)
);

DELIMITER //

CREATE TRIGGER registrar_prescricao
AFTER INSERT ON Prescricoes
FOR EACH ROW
BEGIN
    INSERT INTO Log_Prescricoes (id_prescricao)
    VALUES (NEW.id_prescricao);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER atualizar_custo_prescricao
AFTER UPDATE ON Medicamentos
FOR EACH ROW
BEGIN
    UPDATE Prescricoes
    SET quantidade = NEW.preco
    WHERE id_medicamento = OLD.id_medicamento;
END //

DELIMITER ;

CREATE TABLE Log_Idade_Pacientes (
    id_log_idade INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    data_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);

DELIMITER //

CREATE TRIGGER notificar_idade_paciente
AFTER INSERT ON Pacientes
FOR EACH ROW
BEGIN
    IF NEW.idade > 10 THEN
        INSERT INTO Log_Idade_Pacientes (id_paciente)
        VALUES (NEW.id_paciente);
    END IF;
END //

DELIMITER ;

-- Procedures

DELIMITER //

CREATE FUNCTION verificar_disponibilidade_medicamento(p_id_medicamento INT)
RETURNS int
DETERMINISTIC
BEGIN
    DECLARE quantidade INT;
    
    SELECT COUNT(*) INTO quantidade
    FROM Prescricoes
    WHERE id_medicamento = p_id_medicamento;
    
    RETURN quantidade > 0;
END //

DELIMITER ;


DELIMITER //

CREATE FUNCTION custo_total_procedimentos(p_id_consulta INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(custo), 0) INTO total
    FROM Procedimentos
    WHERE id_consulta = p_id_consulta;
    
    RETURN total;
END //

DELIMITER ;

DELIMITER //

DELIMITER //

CREATE FUNCTION listar_medicamentos_prescritos(p_id_consulta INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE lista TEXT DEFAULT '';
    
    SELECT GROUP_CONCAT(m.nome SEPARATOR ', ') INTO lista
    FROM Prescricoes AS pr
    JOIN Medicamentos AS m ON pr.id_medicamento = m.id_medicamento
    WHERE pr.id_consulta = p_id_consulta;
    
    RETURN IFNULL(lista, 'Nenhum medicamento prescrito');
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION contar_consultas_paciente(p_id_paciente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM Consultas
    WHERE id_paciente = p_id_paciente;
    
    RETURN total;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION media_preco_consulta()
RETURNS DECIMAL(5, 2)
DETERMINISTIC
BEGIN
    DECLARE media DECIMAL(5, 2);
    
    SELECT AVG(custo) INTO media FROM Consultas;
    
    RETURN IFNULL(media, 0);
END //

DELIMITER ;


-- Testes das Procedures

SELECT media_preco_consulta() AS media_preco;

SELECT contar_consultas_paciente(1) AS total_consultas;

SELECT verificar_disponibilidade_medicamento(1) AS medicamento_disponivel;

SELECT custo_total_procedimentos(1) AS custo_total;

SELECT listar_medicamentos_prescritos(1) AS medicamentos_prescritos;
