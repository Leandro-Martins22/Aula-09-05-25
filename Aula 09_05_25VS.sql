-- Criação do banco de dados (execute esta parte primeiro)
CREATE DATABASE IF NOT EXISTS db_teste_trigger;
USE db_teste_trigger;

-- 1. Criação da tabela principal (execute esta parte em segundo)
CREATE TABLE IF NOT EXISTS funcionarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_atualizacao VARCHAR(20),
    nome VARCHAR(100),
    telefone VARCHAR(50),
    email VARCHAR(50),  
    data_nascimento VARCHAR(20),
    rua VARCHAR(100),
    bairro VARCHAR(50),
    cidade VARCHAR(50), 
    estado VARCHAR(50),
    estado_sigla VARCHAR(2),
    cargo VARCHAR(50), 
    salario FLOAT
);

-- 2. Criação da tabela de backup (execute em terceiro)
CREATE TABLE IF NOT EXISTS funcionariosBkp (
    data_mod VARCHAR(20),
    operacao VARCHAR(10),
    id BIGINT,
    data_atualizacao VARCHAR(20),
    nome VARCHAR(100),
    telefone VARCHAR(50),
    email VARCHAR(50),  
    data_nascimento VARCHAR(20),
    rua VARCHAR(100),
    bairro VARCHAR(50),
    cidade VARCHAR(50), 
    estado VARCHAR(50),
    estado_sigla VARCHAR(2),
    cargo VARCHAR(50), 
    salario FLOAT
);

-- 3. Criação da trigger para DELETE (execute em quarto)
DELIMITER //
CREATE TRIGGER IF NOT EXISTS tg_backup_delete
BEFORE DELETE ON funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO funcionariosBkp VALUES (
        NOW(),
        'DELETE',
        OLD.id,
        OLD.data_atualizacao,
        OLD.nome,
        OLD.telefone,
        OLD.email,
        OLD.data_nascimento,
        OLD.rua,
        OLD.bairro,
        OLD.cidade,
        OLD.estado,
        OLD.estado_sigla,
        OLD.cargo,
        OLD.salario
    );
END//
DELIMITER ;

-- 4. Criação da trigger para UPDATE (execute em quinto)
DELIMITER //
CREATE TRIGGER IF NOT EXISTS tg_backup_update
BEFORE UPDATE ON funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO funcionariosBkp VALUES (
        NOW(),
        'UPDATE',
        OLD.id,
        OLD.data_atualizacao,
        OLD.nome,
        OLD.telefone,
        OLD.email,
        OLD.data_nascimento,
        OLD.rua,
        OLD.bairro,
        OLD.cidade,
        OLD.estado,
        OLD.estado_sigla,
        OLD.cargo,
        OLD.salario
    );
END//
DELIMITER ;

-- 5. Inserção de dados de teste (execute em sexto)
INSERT INTO funcionarios VALUES
(1, '2023-01-15', 'João Silva', '(11) 9999-8888', 'joao@email.com', '1980-05-20', 'Rua A', 'Centro', 'São Paulo', 'São Paulo', 'SP', 'Analista', 5000.00),
(2, '2023-01-16', 'Maria Souza', '(11) 7777-6666', 'maria@email.com', '1985-08-15', 'Rua B', 'Jardins', 'São Paulo', 'São Paulo', 'SP', 'Gerente', 8000.00);

-- 6. Teste de UPDATE (execute em sétimo)
UPDATE funcionarios 
SET salario = 5500.00, data_atualizacao = DATE_FORMAT(NOW(), '%Y-%m-%d')
WHERE id = 1;

-- 7. Teste de DELETE (execute em oitavo)
DELETE FROM funcionarios WHERE id = 2;

-- 8. Verificação dos resultados (execute em nono)
SELECT * FROM funcionarios;
SELECT * FROM funcionariosBkp;