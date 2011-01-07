Instalando la aplicación en local
=================================

Arrancando la aplicación
------------------------
  
 1. Usa [Bundler][1] para instalar todas las dependencias necesarias (salvo que me haya dejado algo, claro :). Desde el directorio raíz de la aplicación:
 
    > $ gem install bundler   # si no lo tienes instalado    
    > $ bundle install    
    
 1. Arranca la aplicación:
 
    > ./server
    
 1. Una base de datos vacía, `development.db`, se crea automáticamente en el directorio raíz al arrancar la aplicación por primera vez.

 1. Para rellenar la nueva base de datos con los datos de los Presupuestos, sigue las instrucciones del [parser][2].
 
[1]: http://gembundler.com/
[2]: /dcabo/pge/tree/master/parser

    
