Introducción 
El presente documento constituye la Especificación de Requerimientos del Software (ERS) elaborada por el grupo de trabajo [nombre del grupo] en el marco del proyecto App de Gestión de Propiedades en Arriendo, cuyo objetivo principal es definir de manera precisa y detallada los requerimientos necesarios para el desarrollo de los módulos de Gestión de Propiedades y Búsqueda y Descubrimiento de Propiedades. Para lograrlo, se identifican los factores clave que orientan el diseño e implementación de dichos módulos, incluyendo la prioridad de cada requerimiento, su nivel de detalle, su significado funcional y técnico, y los criterios de aceptación correspondientes, de modo que esta documentación establezca una base común de entendimiento entre los desarrolladores y los interesados del proyecto, facilitando así la trazabilidad y el seguimiento a lo largo de todo el ciclo de vida del software 
Propósito 
El propósito de esta especificación es documentar de manera estructurada y comprensible los requerimientos funcionales y no funcionales que deberán implementarse para garantizar el correcto funcionamiento de los módulos de Gestión de Propiedades y Búsqueda y Descubrimiento de Propiedades, proporcionando al mismo tiempo al cliente una visión clara de los criterios de aceptación de cada funcionalidad para permitir su validación y trazabilidad continua durante las etapas de desarrollo, pruebas y despliegue. 
Alcance 
Este documento delimita y describe los requerimientos funcionales asociados a los módulos de Gestión de Propiedades y Búsqueda y Descubrimiento de Propiedades a lo largo de sus fases de desarrollo, pruebas y puesta en producción, contemplando además los contratos de integración necesarios para la interoperabilidad con módulos externos como el de Autenticación y Gestión de Usuarios, sin abarcar la implementación de estos últimos, de manera que el enfoque permanezca centrado exclusivamente en los componentes mencionados y su alineación con los objetivos del proyecto. 
Descripción general 
Perspectiva del producto 
El sistema descrito en esta especificación corresponde a un subconjunto funcional dentro del proyecto global App de Gestión de Propiedades en Arriendo, donde los módulos de Gestión de Propiedades y Búsqueda y Descubrimiento de Propiedades forman parte integral de un sistema mayor que abarca componentes relacionados con la autenticación de usuarios, la gestión de perfiles y la comunicación entre propietarios y arrendatarios, integrándose con estos mediante contratos de servicio que persiguen una arquitectura modular y cohesiva. 
Funcionalidad del producto 
Los módulos objeto de esta especificación cumplen funciones esenciales dentro del ecosistema de la plataforma. El módulo de Gestión de Propiedades permitirá a los usuarios autenticados con rol de Propietario crear, editar y desactivar publicaciones de inmuebles, gestionando aspectos como la carga de multimedia, la fijación de ubicación mediante mapa interactivo y la administración del listado de propiedades activas e inactivas. 
 
Por su parte, el módulo de Búsqueda y Descubrimiento de Propiedades permitirá a los Arrendatarios explorar el catálogo de inmuebles disponibles mediante búsqueda por palabras clave y filtros avanzados por precio, ubicación, tipo de propiedad y número de habitaciones o baños, pudiendo además consultar el detalle completo de cada publicación, guardar favoritos, compartir enlaces y contactar directamente al propietario desde dispositivos móviles. 
 
Ambos módulos estarán interconectados con el sistema de gestión de cuentas y permisos, haciendo uso de los servicios de autenticación para garantizar el control de acceso y la trazabilidad de las acciones realizadas por cada tipo de usuario. 
 
Características de los usuarios 
 
Tipo de usuario 
	
Descripción 


Propietario 
	
Usuario registrado con capacidad de publicar y gestionar propiedades en arriendo dentro de la plataforma. Representa a inmobiliarias o personas naturales que ofrecen inmuebles y constituye el principal generador de contenido del sistema. 
 


Arrendatario 
	
Usuario registrado orientado a la búsqueda y evaluación de propiedades disponibles. Puede explorar publicaciones, aplicar filtros, guardar favoritos y contactar propietarios, siendo el público objetivo principal de consumo de la plataforma. 
 
Requisitos específicos 
Requisitos funcionales 
Requisito funcional 1 
IDENTIFICADOR: RF-001 
	
NOMBRE: Registro de Usuarios 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-002 


ENTRADA: Datos del usuario (correo, contraseña, tipo de cuenta). 
	
SALIDA: Cuenta de usuario creada exitosamente. 


DESCRIPCIÓN: El sistema debe permitir el registro de dos tipos de cuentas: Propietario y Arrendatario. 


PRECONDICIONES: El usuario debe tener sesión iniciada y un héroe equip. 


POSTCONDICIONES: Se crea el registro en la base de datos y el usuario queda habilitado para iniciar sesión. 


FLUJO BÁSICO:  
1. El usuario accede a la sección de registro. 
2. Selecciona el tipo de cuenta (Propietario o Arrendatario). 
3. Ingresa sus datos obligatorios. 
4. El sistema valida los datos y registra la cuenta. 


FLUJO ALTERNATIVO: A1. Si el correo electrónico ya está registrado, el sistema bloquea el registro y muestra un mensaje de advertencia. 


DIAGRAMA DE CASOS DE USO 
 
 
Requisito funcional 2 
IDENTIFICADOR: RF-002 
	
NOMBRE: Inicio de Sesión 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-001x| 


ENTRADA: Credenciales de acceso (correo/contraseña) o token social. 
	
SALIDA: Acceso concedido al sistema. 


DESCRIPCIÓN: El sistema debe permitir el acceso mediante correo electrónico/contraseña y/o autenticación social. 


PRECONDICIONES: El usuario debe tener una cuenta previamente registrada. 


POSTCONDICIONES: El usuario inicia sesión y es redirigido a su panel principal según su rol. 


FLUJO BÁSICO:  
1. El usuario navega a la pantalla de login. 
 
2. Ingresa sus credenciales o selecciona el proveedor social. 
 
3. El sistema autentica los datos. 
 
4. Se otorga el acceso. 
 


FLUJO ALTERNATIVO: A1. Si las credenciales son incorrectas, se deniega el acceso y se notifica al usuario. 


DIAGRAMA DE CASOS DE USO: 
Referido del anexo 1. 
 
 
Requisito funcional 3 
IDENTIFICADOR: RF-003 
	
NOMBRE: Gestión de Perfil 


PRIORIDAD DE DESARROLLO: Media 
	
REQUERIMIENTO ASOCIADO: RF-002 


ENTRADA: Nuevos datos personales o imagen de perfil. 
	
SALIDA: Perfil de usuario actualizado. 


DESCRIPCIÓN: Los usuarios deben poder editar su información básica (nombre, teléfono de contacto, foto de perfil). 


PRECONDICIONES: El usuario debe haber iniciado sesión. 


POSTCONDICIONES: Los cambios se guardan en la base de datos y se reflejan en la interfaz. 


FLUJO BÁSICO:  
1. El usuario accede a su perfil. 
 
2. Modifica la información deseada. 
 
3. Presiona "Guardar cambios". 
 
4. El sistema actualiza los registros. 


FLUJO ALTERNATIVO: A1. Si el formato de imagen es inválido, no se sube la foto y se informa del error. 


DIAGRAMA DE CASOS DE USO 
Referido del anexo 1. 
 
Requisito funcional 4 
IDENTIFICADOR: RF-004 
	
NOMBRE: Publicar Propiedad 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-005, RF-006 


ENTRADA: Título, descripción, precio, dirección, habitaciones, baños, área. 
	
SALIDA: Nueva propiedad registrada en el sistema. 


DESCRIPCIÓN: El usuario Propietario debe poder crear una nueva publicación ingresando los datos obligatorios. 


PRECONDICIONES: El usuario debe estar autenticado con el rol de "Propietario". 


POSTCONDICIONES: La propiedad queda guardada como activa y es visible en el listado. 


FLUJO BÁSICO:  
1. El Propietario selecciona "Nueva Publicación". 
 
2. Completa los campos obligatorios. 
 
3. Hace clic en "Publicar". 
 
4. El sistema valida la información y crea el registro. 
 


FLUJO ALTERNATIVO: A1. Si faltan datos obligatorios, el sistema resalta los campos faltantes e impide la publicación. 


DIAGRAMA DE CASOS DE USO 
 
Referido del anexo 1. 
 
Requisito funcional 5 
IDENTIFICADOR: RF-005 
	
NOMBRE: Carga de Multimedia 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-004 


ENTRADA: Archivos de imagen seleccionados por el usuario. 
	
SALIDA: Galería de imágenes asociada a la propiedad. 


DESCRIPCIÓN: El sistema debe permitir subir una galería de fotos (mínimo 1, máximo 15 fotos) para cada propiedad. 


PRECONDICIONES: Estar en el flujo de creación o edición de una propiedad. 


POSTCONDICIONES: Las imágenes son almacenadas y vinculadas a la propiedad. 


FLUJO BÁSICO:  
1. El usuario selecciona la opción para subir fotos. 
 
2. Elige entre 1 y 15 imágenes válidas. 
 
3. El sistema carga las imágenes y genera una vista previa. 
 


FLUJO ALTERNATIVO: A1. Si se excede el límite de 15 fotos, el sistema rechaza las adicionales. 


DIAGRAMA DE CASOS DE USO 
Referido del anexo 1. 
 
 
Requisito funcional 6 
IDENTIFICADOR: RF-006 
	
NOMBRE: Geolocalización 


PRIORIDAD DE DESARROLLO: Media 
	
REQUERIMIENTO ASOCIADO: RF-004 


ENTRADA: Interacción con el mapa interactivo. 
	
SALIDA: Coordenadas (latitud/longitud) guardadas. 


DESCRIPCIÓN: El sistema debe permitir fijar la ubicación de la propiedad en un mapa interactivo al momento de crear la publicación. 


PRECONDICIONES: Estar en el proceso de creación/edición de propiedad. 


POSTCONDICIONES: La ubicación geográfica se guarda vinculada a la propiedad. 


FLUJO BÁSICO:  
1. El usuario interactúa con el mapa provisto. 
 
2. Coloca un marcador en la ubicación exacta. 
 
3. El sistema captura y guarda las coordenadas. 
 


FLUJO ALTERNATIVO: A1. Si falla la carga del mapa, se permite el ingreso manual de la dirección. 


DIAGRAMA DE CASOS DE USO 
 
Referido en el anexo 1. 
 
Requisito funcional 7 
IDENTIFICADOR: RF-007 
	
NOMBRE: Edición y Eliminación 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-004, RF-008 


ENTRADA: Acción de editar campos o eliminar la propiedad. 
	
SALIDA: Acción de editar campos o eliminar la propiedad. 


DESCRIPCIÓN: El propietario debe poder modificar los datos de sus propiedades publicadas o eliminarlas si ya no están disponibles. 


PRECONDICIONES: El usuario debe ser el autor de la publicación y estar autenticado. 


POSTCONDICIONES: Los datos son modificados o el estado de la propiedad cambia a "Inactiva". 


FLUJO BÁSICO:  
1. Propietario accede a su lista de propiedades. 
 
2. Selecciona "Editar" o "Eliminar". 
 
3. Realiza el cambio o confirma la acción. 
 
4. El sistema actualiza la base de datos. 
 


FLUJO ALTERNATIVO: A1. Si el usuario cancela la eliminación, la propiedad se mantiene intacta. 


DIAGRAMA DE CASOS DE USO 
 
Referido en anexo 1. 
 
Requisito funcional 8 
IDENTIFICADOR: RF-008 
	
NOMBRE: Listado de "Mis Propiedades" 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-004, RF-007 


ENTRADA: Acceso a la sección correspondiente del perfil. 
	
SALIDA: Vista de todas las propiedades publicadas por el usuario. 


DESCRIPCIÓN: El propietario debe tener una vista para gestionar todas sus publicaciones activas e inactivas. 


PRECONDICIONES: El usuario Propietario debe haber iniciado sesión 


POSTCONDICIONES: Interfaz cargada con el resumen de sus propiedades. 


FLUJO BÁSICO:  
 
1. El usuario navega a "Mis Propiedades". 
 
2. El sistema consulta las propiedades vinculadas a su cuenta. 
 
3. Se muestra la lista separando activas de inactivas. 
 


FLUJO ALTERNATIVO: A1. Si no tiene propiedades registradas, se muestra un mensaje invitando a publicar. 


DIAGRAMA DE CASOS DE USO 
Referido en el anexo 1. 
 
Requisito funcional 9 
IDENTIFICADOR: RF-009 
	
NOMBRE: Búsqueda General 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-010 


ENTRADA: Palabras clave ingresadas en la barra de búsqueda. 
	
SALIDA: Listado de propiedades que coinciden. 


DESCRIPCIÓN: Los usuarios deben poder buscar propiedades mediante una barra de búsqueda por palabras clave. 


PRECONDICIONES: Deben existir propiedades activas en el sistema. 


POSTCONDICIONES: Se muestra la interfaz con los resultados encontrados.. 


FLUJO BÁSICO:  
 
1. El usuario ingresa una palabra clave. 
 
2. Presiona "Buscar". 
 
3. El sistema busca coincidencias en títulos, descripciones o ubicaciones. 
 
4. El sistema muestra los resultados. 
 


FLUJO ALTERNATIVO: A1. Si no hay coincidencias, se indica que no se encontraron resultados. 


DIAGRAMA DE CASOS DE USO: 
Referido en el anexo. 
 
Requisito funcional 10 
IDENTIFICADOR: RF-010 
	
NOMBRE: Filtros Avanzados 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: 


ENTRADA: Parámetros seleccionados (precio, ubicación, tipo, etc.). 
	
SALIDA: Resultados de búsqueda depurados. 


DESCRIPCIÓN: El sistema debe permitir filtrar los resultados por: Rango de precios, Ubicación, Tipo de propiedad y Cantidad de habitaciones/baños. 


PRECONDICIONES: El usuario se encuentra en la vista de búsqueda. 


POSTCONDICIONES: Se actualiza la vista mostrando solo propiedades que cumplen los criterios. 


FLUJO BÁSICO:  
 
1. El usuario despliega los filtros. 
 
2. Selecciona los parámetros deseados. 
 
3. Aplica los filtros. 
 
4. El sistema procesa y actualiza la lista de resultados. 
 


FLUJO ALTERNATIVO: 
A1. El usuario limpia los filtros para regresar a la búsqueda general. 


DIAGRAMA DE CASOS DE USO: 
 
Explicado en el anexo 1. 
 
Requisito funcional 11 
IDENTIFICADOR: RF-011 
	
NOMBRE: Vista de Detalle 


PRIORIDAD DE DESARROLLO: Alta 
	
REQUERIMIENTO ASOCIADO: RF-009 


ENTRADA: Selección de una propiedad en el listado. 
	
SALIDA: Pantalla con toda la información y fotos de la propiedad. 


DESCRIPCIÓN: Al seleccionar una propiedad, el usuario debe ver la información completa, la galería de fotos ampliable y la ubicación en el mapa. 


PRECONDICIONES: La propiedad seleccionada debe estar activa. 


POSTCONDICIONES: Se carga la vista detallada con todos los recursos asociados. 


FLUJO BÁSICO:  
1. El usuario hace clic sobre una propiedad. 
 
2. El sistema recupera los datos detallados. 
 
3. Se muestran atributos, fotos y ubicación en el mapa. 
 


FLUJO ALTERNATIVO: A1. Si la propiedad fue desactivada recientemente, el sistema muestra un mensaje de "Propiedad no disponible". 


DIAGRAMA DE CASOS DE USO 
 
Referido en anexo 1. 
 
Requisito funcional 12 
 
IDENTIFICADOR: RF-12 
	
NOMBRE:  Guardar Favoritos 


PRIORIDAD DE DESARROLLO: Media 
	
REQUERIMIENTO ASOCIADO: RF-011 


ENTRADA: Acción de marcar la propiedad como favorita. 
	
SALIDA:  Propiedad añadida a la lista personal del usuario. 


DESCRIPCIÓN: Los usuarios deben poder marcar propiedades como "Favoritas" para acceder a ellas rápidamente desde su perfil. 


PRECONDICIONES: El usuario debe estar autenticado. 


POSTCONDICIONES: La propiedad se asocia a la lista de favoritos del usuario 


FLUJO BÁSICO:
 
1. El usuario visualiza una propiedad. 
 
2. Presiona el botón de "Favorito". 
 
3. El sistema guarda el registro en el perfil del usuario. 
 


FLUJO ALTERNATIVO: A1. Si un usuario no autenticado intenta guardar, el sistema le pide iniciar sesión. 


DIAGRAMA DE CASOS DE USO: 
 
Referido en el anexo 1. 
 
 
Requisito funcional 13 
IDENTIFICADOR: RF-13 
	
NOMBRE: Llamada Directa 


PRIORIDAD DE DESARROLLO:  Alta 
	
REQUERIMIENTO ASOCIADO: RF-011 


ENTRADA: Clic en el botón "Llamar". 
	
SALIDA: Apertura de la app de teléfono nativa. 


DESCRIPCIÓN:  Si se accede desde un dispositivo móvil, debe existir un botón para llamar directamente al número registrado por la inmobiliaria/propietario. 


PRECONDICIONES: Acceso desde un dispositivo móvil y propiedad con número configurado. 


POSTCONDICIONES: Se envía el comando de llamada al sistema operativo del dispositivo. 


FLUJO BÁSICO:                                                                                                                                                                                       1. El usuario ve el detalle de la propiedad en su celular. 
 
2. Presiona "Llamar". 
 
3. El sistema invoca el protocolo telefónico y abre la app de llamadas. 
 


FLUJO ALTERNATIVO:  A1. Si se accede desde escritorio, se muestra el número telefónico en pantalla. 


DIAGRAMA DE CASOS DE USO: 
 
Referido en el anexo 1. 
 
Requisito funcional 14 
 
IDENTIFICADOR: RF-14 
	
NOMBRE: Compartir Propiedad 


PRIORIDAD DE DESARROLLO: Media 
	
REQUERIMIENTO ASOCIADO: RF-011 


ENTRADA: Clic en el botón "Compartir ". 
	
SALIDA: Enlace generado o menú de compartir nativo abierto. 


DESCRIPCIÓN: El usuario debe poder compartir el enlace de una propiedad a través de redes sociales o aplicaciones de mensajería externa. 


PRECONDICIONES: Estar dentro de la vista de detalle de la propiedad. 


POSTCONDICIONES:  Se expone el enlace público de la propiedad. 


FLUJO BÁSICO:                                                                                                                                                                                        1. El usuario selecciona "Compartir". 
 
2. El sistema despliega las opciones de redes sociales o la API nativa del dispositivo. 
 
3. El usuario comparte el enlace. 


FLUJO ALTERNATIVO: A1. El usuario puede simplemente copiar el enlace al portapapeles. 


DIAGRAMA DE CASOS DE USO: 
 
Referido en el anexo 1. 