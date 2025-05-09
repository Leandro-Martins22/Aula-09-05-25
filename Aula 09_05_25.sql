-- 1. Criação do banco de dados (executar primeiro)
CREATE DATABASE IF NOT EXISTS sistema_monitoramento;
USE sistema_monitoramento;

-- 2. Tabela principal de funcionários (executar segundo)
CREATE TABLE IF NOT EXISTS funcionarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    cargo VARCHAR(50),
    departamento VARCHAR(50),
    salario DECIMAL(10,2),
    data_admissao DATE,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- 3. Tabela de backup para dados alterados/excluídos (executar terceiro)
CREATE TABLE IF NOT EXISTS funcionarios_backup (
    id_backup INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT,
    tipo_operacao ENUM('UPDATE', 'DELETE'),
    dados_anteriores JSON,
    data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) DEFAULT CURRENT_USER()
);

-- 4. Tabela de log para novos registros (executar quarto)
CREATE TABLE IF NOT EXISTS funcionarios_log (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT,
    tipo_operacao ENUM('INSERT'),
    novos_dados JSON,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) DEFAULT CURRENT_USER()
);

-- 5. Trigger para INSERT (executar quinto)
DELIMITER //
CREATE TRIGGER tg_log_insert
AFTER INSERT ON funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO funcionarios_log (id_funcionario, tipo_operacao, novos_dados)
    VALUES (
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'nome', NEW.nome,
            'cpf', NEW.cpf,
            'cargo', NEW.cargo,
            'departamento', NEW.departamento,
            'salario', NEW.salario,
            'data_admissao', NEW.data_admissao
        )
    );
END//
DELIMITER ;

-- 6. Trigger para UPDATE (executar sexto)
DELIMITER //
CREATE TRIGGER tg_backup_update
BEFORE UPDATE ON funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO funcionarios_backup (id_funcionario, tipo_operacao, dados_anteriores)
    VALUES (
        OLD.id,
        'UPDATE',
        JSON_OBJECT(
            'nome', OLD.nome,
            'cpf', OLD.cpf,
            'cargo', OLD.cargo,
            'departamento', OLD.departamento,
            'salario', OLD.salario,
            'data_admissao', OLD.data_admissao,
            'ativo', OLD.ativo
        )
    );
END//
DELIMITER ;

-- 7. Trigger para DELETE (executar sétimo)
DELIMITER //
CREATE TRIGGER tg_backup_delete
BEFORE DELETE ON funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO funcionarios_backup (id_funcionario, tipo_operacao, dados_anteriores)
    VALUES (
        OLD.id,
        'DELETE',
        JSON_OBJECT(
            'nome', OLD.nome,
            'cpf', OLD.cpf,
            'cargo', OLD.cargo,
            'departamento', OLD.departamento,
            'salario', OLD.salario,
            'data_admissao', OLD.data_admissao,
            'ativo', OLD.ativo
        )
    );
END//
DELIMITER ;

-- 8. Inserção de dados de teste (executar oitavo)
INSERT INTO funcionarios (nome, cpf, cargo, departamento, salario, data_admissao)
VALUES 
('João Silva', '123.456.789-00', 'Analista', 'TI', 4500.00, '2020-05-15'),
('Maria Oliveira', '987.654.321-00', 'Gerente', 'RH', 6500.00, '2018-03-10'),
('Carlos Souza', '456.789.123-00', 'Desenvolvedor', 'TI', 5200.00, '2021-07-22');

-- 9. Operações de teste (executar nono)
-- Atualização de registro
UPDATE funcionarios 
SET salario = 4800.00, cargo = 'Analista Sênior'
WHERE id = 1;

-- Exclusão de registro
DELETE FROM funcionarios WHERE id = 3;

-- Inserção de novo registro
INSERT INTO funcionarios (nome, cpf, cargo, departamento, salario, data_admissao)
VALUES ('Ana Costa', '111.222.333-44', 'Designer', 'Marketing', 3800.00, '2023-01-10');

SELECT * FROM funcionarios;

SELECT 
    id_backup,
    id_funcionario,
    tipo_operacao,
    DATE_FORMAT(data_modificacao, '%d/%m/%Y %H:%i') as data_mod,
    JSON_PRETTY(dados_anteriores) as dados_anteriores
FROM funcionarios_backup;

-- Registros de log (INSERT)
SELECT 
    id_log,
    id_funcionario,
    tipo_operacao,
    DATE_FORMAT(data_criacao, '%d/%m/%Y %H:%i') as data_criacao,
    JSON_PRETTY(novos_dados) as novos_dados
FROM funcionarios_log;