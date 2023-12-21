-- Consultas

-- Talvez seja uma consulta bacana para colocar na aplicação (apesar de ser simples),
-- deixando o usuário digitar o material que procura
SELECT DISTINCT
    A.PLANETA
FROM
    AMOSTRA A
JOIN
    MATERIAL_CONTEM_AMOSTRA MA ON A.ID = MA.ID_AMOSTRA
JOIN
    MATERIAL M ON MA.SIGLA_MATERIAL = M.SIGLA
WHERE
    M.SIGLA = 'M1';

-- QUERY 1: Estatística de planetas com mais materiais úteis, em ordem decrescente.
SELECT
    P.DESIGNACAO_ASTRONOMICA, COUNT(MU.SIGLA_MATERIAL) AS MATERIAIS_UTEIS
FROM
    MATERIAL_UTIL MU
JOIN
    MATERIAL_CONTEM_AMOSTRA MA  ON MU.SIGLA_MATERIAL = MA.SIGLA_MATERIAL
JOIN
    AMOSTRA A ON A.ID = MA.ID_AMOSTRA
JOIN
    COLETA C ON C.PLANETA = A.PLANETA AND C.DATA_HORA_PARTIDA = A.DATA_HORA_PARTIDA
JOIN
    MISSAO MI ON MI.PLANETA = C.PLANETA AND MI.DATA_HORA_PARTIDA = C.DATA_HORA_PARTIDA
RIGHT JOIN
    PLANETA P ON P.DESIGNACAO_ASTRONOMICA = MI.PLANETA
GROUP BY
    P.DESIGNACAO_ASTRONOMICA
ORDER BY MATERIAIS_UTEIS DESC;

-- QUERY 2: Encontrar os cientistas que têm um número de publicações maior do
-- que a média geral de publicações de todos os cientistas.
SELECT
    F.CPF, F.NOME, COUNT(PUBLICACAO) AS NUM_PUBLICACOES
FROM
    FUNCIONARIO F
JOIN
    PUBLICACOES_CIENTISTA PC ON F.CPF = PC.CIENTISTA
GROUP BY
    F.CPF, F.NOME
HAVING
    COUNT(PUBLICACAO) > (
        SELECT
            AVG(NUM_PUBLICACOES) AS MEDIA_PUBLICACOES
        FROM (
            SELECT
                CIENTISTA, COUNT(PUBLICACAO) AS NUM_PUBLICACOES
            FROM
                PUBLICACOES_CIENTISTA
            GROUP BY
                CIENTISTA
        )
    );

-- QUERY 3: Listar os pilotos que participaram de todas as missões de coleta e de todas as missões de mineração
-- (Divisão Relacional).
SELECT 
    F.NOME, P.CPF 
FROM 
    FUNCIONARIO F
JOIN
    PILOTO P ON F.CPF = P.CPF
WHERE
    NOT EXISTS(
        (
            SELECT
                C.PLANETA, C.DATA_HORA_PARTIDA
            FROM
                COLETA C
        )
        MINUS
        (
            SELECT
                C.PLANETA, C.DATA_HORA_PARTIDA
            FROM
                COLETA C
            JOIN
                MISSAO MISS ON C.PLANETA = MISS.PLANETA AND C.DATA_HORA_PARTIDA = MISS.DATA_HORA_PARTIDA
            WHERE
                MISS.PILOTO = P.CPF
        )
    ) AND NOT EXISTS(
        (
            SELECT
                M.PLANETA, M.DATA_HORA_PARTIDA
            FROM MINERACAO M
        )
        MINUS
        (
            SELECT
                M.PLANETA, M.DATA_HORA_PARTIDA
            FROM
                MINERACAO M
            JOIN
                MISSAO MISS ON M.PLANETA = MISS.PLANETA AND M.DATA_HORA_PARTIDA = MISS.DATA_HORA_PARTIDA
            WHERE
                MISS.PILOTO = P.CPF
        )
    );

-- QUERY 4: Encontrar funcionários que nunca ajudaram em qualquer tipo de missão.
SELECT
    F.CPF, F.NOME
FROM
    FUNCIONARIO F
WHERE
    CPF NOT IN(
        (
            SELECT DISTINCT
                CRC.CIENTISTA AS CPF
            FROM
                CIENTISTA_REALIZA_COLETA CRC
        )
        UNION
        (
            SELECT DISTINCT
                MPM.MINERADOR
            FROM
                MINERADOR_PARTICIPA_MINERACAO MPM
        )
        UNION
        (
            SELECT DISTINCT
                F.CPF
            FROM
                MISSAO M
            JOIN
                FUNCIONARIO F ON F.CPF IN (M.PILOTO, M.ADMINISTRADOR)
        )
    );

-- QUERY 5: Média de Temperatura em Planetas Rochosos Agrupada por Tipo Climático.
SELECT
    TIPO_CLIMATICO, COUNT(*) AS QUANTIDADE, AVG(TEMPERATURA_MEDIA) AS MEDIA_TEMPERATURA
FROM
    PLANETA
WHERE
    TIPO_PLANETA = 'Rochoso'
GROUP BY
    TIPO_CLIMATICO
ORDER BY
    MEDIA_TEMPERATURA DESC;
