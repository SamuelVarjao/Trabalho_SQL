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

