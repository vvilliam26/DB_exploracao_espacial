import cx_Oracle
import sys
import os


print("Digite o usuario do banco de dados: ")
con_user = input()
print("Digite a senha do banco de dados: ")
con_pass = input()
print("Digite o nome do banco de dados: ")
con_db_name = input()
print("\n")



#con_host = *retirado por protecao*
con_port = 1521
#con_service = *retirado por protecao*

def cls():
    os.system('cls')

try:
    dsn = cx_Oracle.makedsn(con_host, 1521, service_name=con_service)
    conn = connection = cx_Oracle.connect(
        user = con_user,
        password = con_pass,
        dsn = dsn,
        encoding="UTF-8"
        )
    
    cls()
    print("Conexão bem sucedida!")
except cx_Oracle.Error as error:
    print("Não foi possível conectar ao banco de dados: ", error)
    input()
    sys.exit()


while(True):

    print("Selecione o opção que você quer:\n")
    print("1 - Procurar planetas que possuam um material específico.\n")
    print("2 - Inserir novo laboratório.\n")
    print("3 - Sair.")
    

    opt = input()

    if(opt == "1"):
        print("Digite a Sigla do material que você procura: ")
        material = input()
        material = material.upper()

        cur = connection.cursor()
        cur.execute(
            """SELECT DISTINCT
                A.PLANETA
            FROM
                AMOSTRA A
            JOIN
                MATERIAL_CONTEM_AMOSTRA MA ON A.ID = MA.ID_AMOSTRA
            JOIN
                MATERIAL M ON MA.SIGLA_MATERIAL = M.SIGLA
            WHERE
                M.SIGLA = :material""", material = material
            )
        rows = cur.fetchall()

        if(len(rows) == 0):
            print("\nNão há planetas cadastrados com esse material.\n")
            print("Pressione qualquer tecla para continuar.\n")
        else:
            print("\n")
            for row in rows:
                print(row)
        print("\n")
        print("Pressione qualquer tecla para continuar.\n")
        input()

        cur.close()
        
    elif(opt == "2"):
        print("Digite o Bloco do novo laboratório: ")
        new_lab_bloco = input()
        print("\nDigite a Sala do novo laboratório: ")
        new_lab_sala = input()

        cur = connection.cursor()

        try:
           with connection.cursor() as cursor:
                cur.execute(
                    """
                    INSERT INTO Laboratorio (Bloco, Sala)
                    VALUES (:bloco, :sala)
                    """, 
                    [new_lab_bloco,new_lab_sala])

                conn.commit()

                print("Laboratório inserido com sucesso!\n")

        except cx_Oracle.DatabaseError as e:
            erro, = e.args
            print("Erro durante a inserção:", erro)
            print("\n")

            conn.rollback()


    elif(opt == "3"):
        #conn.close()
        sys.exit()

    else:
        cls()
        print("Você deve inserir um número válido.\n")
        print("Pressione qualquer tecla para continuar.\n")
        input()


    
