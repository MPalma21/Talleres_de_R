# =============================================================================
# Clase 6: Introducción a gráficas en R
# Profesor : Santiago Neira 
# Objetivos:
# - Identificar principios de visualización de datos básica
# - Utilizar funciones básicas y avanzadas del paquete ggplot
# =============================================================================

#  Configuración inicial del ambiente ----------------------------------------


# Instalación y carga de paquetes necesarios
required_packages <- c("openxlsx", "ggplot2", "dplyr", "lubridate")

# Función para instalar paquetes si no están instalados
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
}

install_if_missing(required_packages)

# Cargar librerías
lapply(required_packages, library, character.only = TRUE)



#  Configuración del directorio de trabajo ----------------------------------


# Obtener usuario del sistema
username <- Sys.getenv("USERNAME")

# Crear ruta dinámica para los datos
ruta_datos <- file.path("C:/Users", username, 
                        "OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos clase 7")

# Establecer directorio de trabajo
setwd(ruta_datos)



# Cargue de bases, exploración y filtro -----------------------------------


datos <- read.xlsx("PANEL_CARACTERISTICAS_GENERALES(2022).xlsx")

# filtro de la base de datos. 

datos_line <- datos %>% filter(coddepto %in% c(5,11, 25, 27, 52, 76)) %>%
                     group_by(ano, coddepto) %>%  summarise(pobl_tot=sum(pobl_tot),
                                                           pib_total=sum(pib_total))



pegue <- datos %>% 
  arrange(coddepto, depto) %>% 
  distinct(coddepto, .keep_all=TRUE) %>%
  select(coddepto, depto)


datos_line<- left_join(datos_line, pegue, by="coddepto")

  
datos_filtrados <- datos %>% filter(ano==2021) %>% 
  filter(coddepto %in% c(5,11, 25, 27, 52, 76))



# Entendiendo la estructura básica de ggplot2 -----------------------------

# - ggplot funciona de manera aditiva y escalonada (recuerden el comando pipe  %>% )

# ejes 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot)) 

# scatterplot 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point()

#Hay mucha varianza en los datos (outliers), si no queremos quitarlos, podemos mantener escala en logaritmos

ggplot(datos_filtrados, aes(x = indrural, y = pobl_tot)) +
  geom_point() +
  scale_y_log10()

# lineas horizontales y verticales 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_vline(xintercept = 0.50)
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_hline(yintercept = 0)



# los gráficos se pueden añadir aditivamente como capas 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() + 
  geom_vline(xintercept = 0.50, color= "red", linetype = 2)+
  scale_y_log10()


#cambiar colores
# https://r-charts.com/es/paletas-colores/
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(color="red")+
  scale_y_log10()
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(color="#52261D")+
  scale_y_log10()


# cambiar tamaño de los puntos 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(size = 0.10, color="blue")+
  scale_y_log10()


# cambiar shape de los features 
# http://www.cookbook-r.com/Graphs/Shapes_and_line_types/
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(shape = 0)+
  scale_y_log10()

ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(shape = 1)+
  scale_y_log10()+geom_vline(xintercept = 0.50, color= "red", linetype = 2)



## colorear con base en los datos 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + 
  geom_point(aes(color= as.factor(depto)))+
  scale_y_log10()




## linetype 
# http://www.sthda.com/english/wiki/line-types-in-r-lty


ggplot(datos_line, aes(x= ano, y= pobl_tot))  + geom_line(aes(color= as.factor(depto)))

ggplot(datos_line, aes(x= ano, y= pobl_tot))  + geom_line(linetype = 2, aes(color= as.factor(depto)))

 

# Más tipos de gráficos ---------------------------------------------------

# Una variable continua -----------------------------------
# histograma
# Fill - Rellena

ggplot(datos_filtrados, aes(x= indrural)) + geom_histogram(bins = 10) 


# binwidth está asociado al tamaño del intervalo del eje x. 
ggplot(datos_filtrados, aes(x= indrural)) + geom_histogram(binwidth = 0.5, aes(fill= as.factor(depto))) 


ggplot(datos_filtrados, aes(x= indrural)) + geom_histogram(bins = 20, aes(fill= as.factor(depto))) 


# ¿Qué problema hay? 

# densidad 
ggplot(datos_filtrados, aes(x= indrural)) + geom_density(aes(fill= as.factor(depto))) 

ggplot(datos_filtrados, aes(x= indrural)) + geom_density(aes(color= as.factor(depto)))




# Una variable discreta ------------------------
# ¿Cuántos municipios hay por departamento? 

## lotes por proyecto
# Crear el gráfico de barras

ggplot(datos_filtrados, aes(x = as.factor(depto))) + geom_bar(color="red")


ggplot(datos_filtrados, aes(x = as.factor(depto))) + geom_bar(color="red", fill= "grey")



# Una variable discreta y una continua -------------------
# boxplot() 
ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +
  geom_boxplot()


# cambiar los outliers 


ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +
  geom_boxplot(outlier.color = "red", outlier.size = 5, outlier.shape=2)



# geom_jitter() vs geom_point()
ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +
  geom_point()


ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +
  geom_jitter(aes(color= as.factor(depto)))


# juntando los boxplots con geom_jitter
ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +
  geom_boxplot() +
  geom_jitter(aes(color= as.factor(depto)))


# geom_violin()
ggplot(datos_filtrados, aes(x = as.factor(depto), y = indrural)) +  geom_boxplot() +
  geom_violin(aes(color= as.factor(depto)))





# dos variables discretas ------------------------


ggplot(datos_filtrados, aes(x = as.factor(depto), y = as.factor(codmdo))) + geom_count()


ggplot(datos_filtrados, aes(x = as.factor(depto), y = as.factor(codmdo))) + geom_jitter()


# dos variables continuas ----------------
# geom smooth
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() + scale_y_log10()+
  geom_smooth(method = "lm", formula = y ~ x) 


# polinomio de grado 2
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() + scale_y_log10()+
  geom_smooth(method = "lm", formula = y ~ poly(x, 2))


### Qué pasa si ajustamos el eje y en términos logarítmicos?

ggplot(datos_filtrados, aes(x = indrural, y = pobl_tot)) +
  geom_point() +
  scale_y_log10() +
  geom_smooth(method = "lm", formula = y ~ x)

# geom_text() y geom_label()

ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + 
  geom_text(aes(label = municipio))  + geom_point()


ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + 
  geom_text(aes(label = municipio), check_overlap = TRUE)


#geom_label()
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + 
  geom_label(aes(label = municipio), check_overlap = TRUE)



# facet_grig() y facet_wrap()
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(aes(color=as.factor(depto)))+ scale_y_log10()


ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +
  facet_grid(~depto)+ scale_y_log10()


ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +
  facet_wrap(~depto)

# Colores de las gráficas -------------------------

ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(aes(color = depto)) +
  scale_color_brewer(palette = "Blues")+ scale_y_log10()

RColorBrewer::display.brewer.all()

# si fuese continuo 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(aes(color = altura)) +
  scale_color_distiller(palette = "Reds")+ scale_y_log10()



ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(aes(color = altura)) +
  scale_color_gradient(low= "red", high= "green")+ scale_y_log10()



# elementos adicionales a las gráficas -----------------

# gráfica base. 
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point()+ scale_y_log10()
## temas -------------
# https://ggplot2.tidyverse.org/reference/ggtheme.html
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point()  + theme_bw()

ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +
  theme_minimal()


# cambiar las scalas
# eje x
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +
  theme_minimal() + 
  scale_x_continuous(limits= c(0, 0.8), #limits altera los limites del eje
                     breaks = seq(0, 1, 0.2)) 

# cambiar las scalas
# eje y
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +
  theme_minimal() +
  scale_y_continuous(
    name = "población",        # Nombre del eje y
    breaks = seq(0, 9000000, 3000000), # Posiciones de las marcas del eje y
    labels = paste(seq(0, 9, 3), "millones"), # Etiquetas de las marcas del eje y
  )



# labels a los aspectos de las gráficas
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +  # Puntos
  labs(
    title = "Gráfico de dispersión",  # Título
    subtitle = "Ejemplo con ggplot2",  # Subtítulo
    x = "Eje X",  # Nombre del eje x
    y = "Eje Y"   # Nombre del eje y
  )


# tamaño de la fuente.
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point() +  # Puntos
  labs(
    title = "Gráfico de dispersión",  # Título
    subtitle = "Ejemplo con ggplot2",  # Subtítulo
    x = "Eje X",  # Nombre del eje x
    y = "Eje Y"   # Nombre del eje y
  ) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),  # Tamaño y estilo del título
    plot.subtitle = element_text(size = 10),              # Tamaño del subtítulo
    axis.title = element_text(size = 12),                 # Tamaño de los nombres de los ejes
    axis.text = element_text(size = 10)
  )


# eje x
ggplot(datos_filtrados, aes(x= indrural, y= pobl_tot))  + geom_point(aes(color = depto)) +
  theme_minimal() + 
  scale_x_continuous(limits= c(0, 0.8), #limits altera los limites del eje
                     breaks = seq(0, 1, 0.2)) +   
  scale_color_discrete(name= "Departamento") +
  theme(legend.position = "right") # cambia la posición de la leyenda. 


#### Ejemplo de una gráfica autocontenida - gráfico de barras
# Gráfico de torta: población total por departamento en 2021 ---------------

datos_torta <- datos_filtrados %>%
  group_by(depto) %>%
  summarise(pobl_tot = sum(pobl_tot)) %>%
  mutate(pct = round(pobl_tot/sum(pobl_tot)*100, 1))

ggplot(datos_torta, aes(x = "", y = pobl_tot, fill = depto)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y") +
  geom_text(aes(label = paste0(pct, "%")), 
            position = position_stack(vjust=0.5), size=3) +
  labs(
    title = "Distribución de la población por departamento (2021)",
    fill = "Departamento",
    caption = "Fuente: DANE – GEIH, módulo Características Generales. Archivo PANEL_CARACTERISTICAS_GENERALES(2022).xlsx"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.caption = element_text(size = 8, hjust = 0) # caption más pequeño y alineado a la izquierda
  )





