# M6 - Pipeline ETL

Archivo: Pipeline_ETL_Perez_Ingrid.pbix
Datos: Pipeline_ETL_Dataset.xlsx
Consultas: Dim_Clientes, Dim_Productos, Dim_Categorias, Fact_Ventas

## Lo que encontré y lo que hice

En clientes estaba el id 1 cargado dos veces (Maria Lopez) y en productos el id 103
(Monitor 4K). Los saqué con Quitar duplicados por la columna de id, porque el id es la
clave y en una tabla de dimension no puede repetirse.

Los nulos los reemplace, no los elimine. Si elimino, Power Query me borra la fila entera
y pierdo el cliente o el producto completo. En clientes le puse "sin dato" al email de
Valentina Paz y a la ciudad de Roberto Diaz. Valentina tiene 5 ventas, asi que si la
borraba esas ventas se quedaban sin cliente.

En productos el SSD Externo no tenia precio. Lo busque en la tabla ventas, donde ese
producto aparece 5 veces, siempre a 130, asi que use ese valor. La Laptop Gaming Pro no
tenia categoria, pero su subcategoria es Laptops y en los demas productos Laptops es
Computacion, asi que le puse Computacion. No inventé datos, los saqué del mismo archivo.

## Tipos de datos

Los id y las cantidades quedaron como numero entero. Precio, costo, precio unitario,
descuento y total de venta como numero decimal, porque son montos. Las fechas como fecha
y el resto como texto.

## Merge

Cruce Fact_Ventas con Dim_Productos por id_producto y expandi solo nombre_producto y
categoria. Quedaron las mismas 50 ventas, ahora con 11 columnas.

## Como quedo

Dim_Clientes 11 filas, Dim_Productos 12 filas, Fact_Ventas 50 filas.
Las cuatro tablas cargan sin errores y no quedaron celdas vacias.
El detalle de cada paso esta en consultas_power_query.m, con los comentarios que deje en
el Editor Avanzado.
