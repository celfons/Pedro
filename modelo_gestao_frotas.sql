-- ================================
-- SCHEMA
-- ================================
CREATE SCHEMA IF NOT EXISTS frotas;
SET search_path TO frotas;

-- ================================
-- TABELAS DE DOMÍNIO
-- ================================
CREATE TABLE tipos_servico (
    id_tipo_servico      SERIAL PRIMARY KEY,
    nome                 VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE areas_servico (
    id_area_servico      SERIAL PRIMARY KEY,
    nome                 VARCHAR(100) NOT NULL UNIQUE
);

-- ================================
-- MOTORISTAS
-- ================================
CREATE TABLE motoristas (
    id_motorista         SERIAL PRIMARY KEY,
    nome_completo        VARCHAR(200) NOT NULL,
    cpf                  VARCHAR(14)  NOT NULL UNIQUE,
    numero_cnh           VARCHAR(20)  NOT NULL UNIQUE,
    data_vencimento_cnh  DATE         NOT NULL
);

-- ================================
-- VEICULOS
-- ================================
CREATE TABLE veiculos (
    id_veiculo             SERIAL PRIMARY KEY,
    placa                  VARCHAR(8)   NOT NULL UNIQUE,
    chassi                 VARCHAR(20)  NOT NULL UNIQUE,
    id_motorista_alocado   INTEGER      NULL REFERENCES motoristas(id_motorista) ON DELETE SET NULL,
    marca                  VARCHAR(100) NOT NULL,
    modelo                 VARCHAR(100) NOT NULL,
    quilometragem_atual    INTEGER      NOT NULL CHECK (quilometragem_atual >= 0),
    tipo_combustivel       VARCHAR(20)  NOT NULL CHECK (tipo_combustivel IN
                               ('Gasolina','Etanol','Flex','Diesel','GNV','Elétrico','Híbrido','Outro')),
    status                 VARCHAR(20)  NOT NULL CHECK (status IN
                               ('Disponivel','Em_Uso','Manutencao','Inativo'))
);
CREATE INDEX idx_veiculos_motorista_alocado ON veiculos(id_motorista_alocado);

-- ================================
-- VIAGENS / ROTEIROS
-- ================================
CREATE TABLE viagens (
    id_viagem            SERIAL PRIMARY KEY,
    id_veiculo           INTEGER      NOT NULL REFERENCES veiculos(id_veiculo)  ON DELETE RESTRICT,
    id_motorista         INTEGER      NOT NULL REFERENCES motoristas(id_motorista) ON DELETE RESTRICT,
    data_hora_saida      TIMESTAMPTZ  NOT NULL,
    data_hora_chegada    TIMESTAMPTZ  NOT NULL,
    km_saida             INTEGER      NOT NULL CHECK (km_saida >= 0),
    km_chegada           INTEGER      NOT NULL CHECK (km_chegada >= km_saida),
    finalidade           VARCHAR(200) NOT NULL,
    CONSTRAINT ck_viagens_periodo CHECK (data_hora_chegada >= data_hora_saida)
);
CREATE INDEX idx_viagens_veiculo  ON viagens(id_veiculo, data_hora_saida);
CREATE INDEX idx_viagens_motorista ON viagens(id_motorista, data_hora_saida);

-- ================================
-- ABASTECIMENTOS
-- ================================
CREATE TABLE abastecimentos (
    id_abastecimento     SERIAL PRIMARY KEY,
    id_veiculo           INTEGER      NOT NULL REFERENCES veiculos(id_veiculo) ON DELETE RESTRICT,
    data_abastecimento   TIMESTAMPTZ  NOT NULL,
    litros_abastecidos   NUMERIC(10,3) NOT NULL CHECK (litros_abastecidos > 0),
    valor_total          NUMERIC(12,2) NOT NULL CHECK (valor_total >= 0),
    km_abastecimento     INTEGER       NOT NULL CHECK (km_abastecimento >= 0)
);
CREATE INDEX idx_abastecimentos_veiculo_data ON abastecimentos(id_veiculo, data_abastecimento);

-- ================================
-- MANUTENCOES
-- ================================
CREATE TABLE manutencoes (
    id_manutencao        SERIAL PRIMARY KEY,
    id_veiculo           INTEGER       NOT NULL REFERENCES veiculos(id_veiculo) ON DELETE RESTRICT,
    id_tipo_servico      INTEGER       NOT NULL REFERENCES tipos_servico(id_tipo_servico) ON DELETE RESTRICT,
    data_entrada         DATE          NOT NULL,
    custo_total          NUMERIC(12,2) NOT NULL CHECK (custo_total >= 0),
    km_na_manutencao     INTEGER       NOT NULL CHECK (km_na_manutencao >= 0)
);
CREATE INDEX idx_manutencoes_veiculo_data ON manutencoes(id_veiculo, data_entrada);

-- ================================
-- ITENS_SERVICO
-- ================================
CREATE TABLE itens_servico (
    id_item_servico      SERIAL PRIMARY KEY,
    id_manutencao        INTEGER       NOT NULL REFERENCES manutencoes(id_manutencao) ON DELETE CASCADE,
    id_area_servico      INTEGER       NOT NULL REFERENCES areas_servico(id_area_servico) ON DELETE RESTRICT,
    item_descricao       VARCHAR(200)  NOT NULL,
    custo_unitario       NUMERIC(12,2) NOT NULL CHECK (custo_unitario >= 0)
);
CREATE INDEX idx_itens_servico_manutencao ON itens_servico(id_manutencao);
CREATE INDEX idx_itens_servico_area      ON itens_servico(id_area_servico);
