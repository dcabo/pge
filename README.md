Instalando la aplicación en local
=================================

Dependencias
------------

 1. Instala [Bundler][1].
 
    > $ gem install bundler
    
 2. Usa Bundler para instalar todas las dependencias necesarias (salvo que me haya dejado algo, claro :):
 
    > $ bundle install

[1]: http://gembundler.com/

Rellenando la Base de Datos
---------------------------

 1. Extraer los datos de gastos de los presupuestos usando los scripts en `parser/`
 
    > $ ./extract_expenses.rb > output/expenses.csv
    
 1. Una base de datos vacía, `development.db`, se crea automáticamente al arrancar la aplicación por primera vez en el directorio raíz de la aplicación.
 
 1. Entrar en la consola de administración de sqlite3:
 
    > $ sqlite3 development.db
    
 1. Importar los datos a partir del fichero CSV generado anteriormente:
 
    > sqlite3> .mode csv    
    > sqlite3> .separator "|"    
    > sqlite3> .import parser/output/expenses.csv expenses    
    > sqlite3> .exit    
    
