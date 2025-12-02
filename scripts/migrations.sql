-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create table pessoas (without nome and email)
CREATE TABLE IF NOT EXISTS pessoas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    documento VARCHAR(14) NOT NULL,
    tipo_pessoa CHAR(1) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    perfil VARCHAR(50) NOT NULL DEFAULT 'PADRAO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_pessoa CHECK (tipo_pessoa IN ('F', 'J')),
    CONSTRAINT chk_documento_tamanho CHECK (
        (tipo_pessoa = 'F' AND LENGTH(documento) = 11) OR
        (tipo_pessoa = 'J' AND LENGTH(documento) = 14)
    ),
    CONSTRAINT chk_documento_numerico CHECK (documento ~ '^[0-9]+$')
);

-- Unique index on documento
CREATE UNIQUE INDEX IF NOT EXISTS idx_pessoas_documento ON pessoas(documento);

-- Index on perfil, cargo
CREATE INDEX IF NOT EXISTS idx_pessoas_perfil_cargo ON pessoas(perfil, cargo);

-- Trigger function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger
DROP TRIGGER IF EXISTS update_pessoas_modtime ON pessoas;
CREATE TRIGGER update_pessoas_modtime
BEFORE UPDATE ON pessoas
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
