# Guía

- [Automate the rotation of a secret for resources that have two sets of authentication credentials](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation-dual)
- [Deliver events using private link service](https://learn.microsoft.com/en-us/azure/event-grid/consume-private-endpoints)

## Pendientes

- Si se puede crear una suscripción de evento desde un event grid desde una suscripción distinta a la que se tiene la función la cual es el endpoint de la suscripción de evento.
- Revisar opciones para asegurar la ejecución de la función
  - Si el llamado de la función realizado por el event grid puede utilizar identidad administrada (llamada por url https [token] poco seguro) 
  - Si se requiere que la función sea privada, esto implica agregar un event hub (endpoint privada por medio de una red) de por medio.



## Objetivo 

- Optimizar la seguridad de gestion de secretos en azure mediante la implementación de una solución automatizada para la rotación de secretos 

- Optimizar la seguridad de gestion de secretos en azure mediante el diseño de una solución automatizada para la rotación de secretos 

cumpliendo con políticas de seguridad, reduciendo riesgos de exposición y asegurando que los recursos sigan funcionando sin problemas



## Publico Objetivo 

Cualquier organización que utilice Azure y que requiera una gestión segura y eficiente de credenciales

Organizaciones sujetas a Cumplimiento Regulatorio y Normativo

- Empresas que usan Azure para Infraestructura como Servicio (IaaS)

- Equipos de Infraestructura y DevOps: Para automatizar la rotación de secretos y facilitar la gestión segura de acceso.

- CISO y equipos de seguridad: cumplimiento con políticas de seguridad

- Arquitectos de soluciones: Diseñar infraestructuras más seguras y escalables.


## Alcance 

- Diseñar una solución que permita rotar de forma automatizada secretos almacenados en un Key Vault de tipo: llaves de acceso a un Storage Account, y contraseñas de registros de aplicaciones


1. Azure Key Vault: Almacena y gestiona secretos y claves de acceso de manera segura, gestionando versiones y rotación de secretos.
2. Event Grid: Publica eventos relacionados con la expiración de secretos, notificando a las aplicaciones suscritas.
3. Azure Functions: Ejecuta código automáticamente en respuesta a eventos, como la regeneración de claves y actualización de secretos en Key Vault.
4. Azure Storage: Proporciona almacenamiento seguro de datos y recursos que requieren credenciales de acceso.
5. Azure Event Subscriptions: Gestiona suscripciones a eventos para recibir notificaciones y disparar acciones automáticas, como la ejecución de funciones.



- Si el llamado de la función realizado por el event grid puede utilizar identidad administrada

Consideraciones Importantes:
Event Grid por sí mismo no usa una identidad administrada para invocar la Azure Function, ya que no requiere autenticación directa para enviar eventos. Event Grid se comunica con la función a través de un endpoint HTTP/HTTPS.
Si el endpoint de la Azure Function está protegido por Azure AD, la función utilizará Azure AD para la autenticación, y Event Grid puede enviar eventos a ese endpoint si tiene los permisos adecuados configurados.
