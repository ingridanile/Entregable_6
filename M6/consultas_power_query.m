// ===================== Dim_Clientes =====================
let
  Origen = Excel.Workbook(File.Contents("C:\Users\CCC\Desktop\Curso Analisis de Datos\Pipeline_ETL_Dataset.xlsx"), null, false),
  clientes_sheet = Origen{[Item = "clientes", Kind = "Sheet"]}[Data],
  #"Filtrar contenido nulo y espacios en blanco" = each List.Select(_, each _ <> null and (not (_ is text) or Text.Trim(_) <> "")),
  #"Filas inferiores quitadas" = Table.RemoveLastN(clientes_sheet, each try List.IsEmpty(List.Skip(#"Filtrar contenido nulo y espacios en blanco"(Record.FieldValues(_)), 1)) otherwise false),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"Filas inferiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"id_cliente", Int64.Type}, {"nombre_cliente", type text}, {"email", type text}, {"ciudad", type text}, {"pais", type text}, {"segmento", type text}, {"fecha_registro", Int64.Type}}),
    //Se quitan los duplicados del id_cliente para no duplicar sus ventas, id_cliente es una PK y debe tener un valor unico
    #"Duplicados quitados" = Table.Distinct(#"Tipo cambiado", {"id_cliente"}),
    //Se reemplaza el campo null email y ciudad para no perder los datos completos del cliente
    #"Valor reemplazado" = Table.ReplaceValue(#"Duplicados quitados",null,"sin dato",Replacer.ReplaceValue,{"email"}),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Valor reemplazado",null,"sin dato",Replacer.ReplaceValue,{"ciudad"}),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Valor reemplazado1",{{"fecha_registro", type date}})
in
    #"Tipo cambiado1"


// ===================== Dim_Productos =====================
let
  Origen = Excel.Workbook(File.Contents("C:\Users\CCC\Desktop\Curso Analisis de Datos\Pipeline_ETL_Dataset.xlsx"), null, false),
  productos_sheet = Origen{[Item = "productos", Kind = "Sheet"]}[Data],
  #"Filtrar contenido nulo y espacios en blanco" = each List.Select(_, each _ <> null and (not (_ is text) or Text.Trim(_) <> "")),
  #"Filas inferiores quitadas" = Table.RemoveLastN(productos_sheet, each try List.IsEmpty(List.Skip(#"Filtrar contenido nulo y espacios en blanco"(Record.FieldValues(_)), 1)) otherwise false),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"Filas inferiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"id_producto", Int64.Type}, {"nombre_producto", type text}, {"categoria", type text}, {"subcategoria", type text}, {"precio", type number}, {"costo", Int64.Type}, {"stock", Int64.Type}, {"activo", Int64.Type}}),
    #"Duplicados quitados" = Table.Distinct(#"Tipo cambiado", {"id_producto"}),
    //Recuperamos el precio que faltaba de la tabla ventas, donde el producto tiene varias ventas al mismo precio
    #"Precio Recuperado Tabla 3 (ventas)" = Table.ReplaceValue(#"Duplicados quitados",null,130,Replacer.ReplaceValue,{"precio"}),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Precio Recuperado Tabla 3 (ventas)",{{"costo", type number}}),
    //Deducimos que la subcategoria Laptops pertenece a la categoría computacion, porque aparece esta informacion en otros productos
    #"Categoria deducida por subcategoria" = Table.ReplaceValue(#"Tipo cambiado1",null,"Computación",Replacer.ReplaceValue,{"categoria"})
in
    #"Categoria deducida por subcategoria"


// ===================== Dim_Categorias =====================
let
  Origen = Excel.Workbook(File.Contents("C:\Users\CCC\Desktop\Curso Analisis de Datos\Pipeline_ETL_Dataset.xlsx"), null, false),
  categorias_sheet = Origen{[Item = "categorias", Kind = "Sheet"]}[Data],
  #"Filtrar contenido nulo y espacios en blanco" = each List.Select(_, each _ <> null and (not (_ is text) or Text.Trim(_) <> "")),
  #"Filas inferiores quitadas" = Table.RemoveLastN(categorias_sheet, each try List.IsEmpty(List.Skip(#"Filtrar contenido nulo y espacios en blanco"(Record.FieldValues(_)), 1)) otherwise false),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"Filas inferiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"id_categoria", Int64.Type}, {"nombre_categoria", type text}, {"descripcion", type text}})
in
  #"Tipo cambiado"


// ===================== Fact_Ventas =====================
let
  Origen = Excel.Workbook(File.Contents("C:\Users\CCC\Desktop\Curso Analisis de Datos\Pipeline_ETL_Dataset.xlsx"), null, false),
  ventas_sheet = Origen{[Item = "ventas", Kind = "Sheet"]}[Data],
  #"Filtrar contenido nulo y espacios en blanco" = each List.Select(_, each _ <> null and (not (_ is text) or Text.Trim(_) <> "")),
  #"Filas inferiores quitadas" = Table.RemoveLastN(ventas_sheet, each try List.IsEmpty(List.Skip(#"Filtrar contenido nulo y espacios en blanco"(Record.FieldValues(_)), 1)) otherwise false),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"Filas inferiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"id_venta", Int64.Type}, {"fecha_venta", type date}, {"id_cliente", Int64.Type}, {"id_producto", Int64.Type}, {"cantidad", Int64.Type}, {"precio_unitario", type number}, {"descuento", type number}, {"total_venta", type number}, {"canal", type text}}),
    #"Consultas combinadas" = Table.NestedJoin(#"Tipo cambiado", {"id_producto"}, Dim_Productos, {"id_producto"}, "Dim_Productos", JoinKind.LeftOuter),
    #"Se expandió Dim_Productos" = Table.ExpandTableColumn(#"Consultas combinadas", "Dim_Productos", {"nombre_producto", "categoria"}, {"Dim_Productos.nombre_producto", "Dim_Productos.categoria"})
in
  #"Se expandió Dim_Productos"
