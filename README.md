# 📦 poryectoSQL – Sistema de Base de Datos Avanzado (MySQL)

## 📌 Descripción del proyecto

**proyectoSQL** es una base de datos relacional diseñada para simular una plataforma de comercio electrónico multi-vendedor.  
Incluye gestión de productos, clientes, proveedores, ventas, control de inventario, auditoría automática, automatización con eventos y lógica de negocio avanzada mediante procedimientos almacenados y triggers.

El sistema está construido en **MySQL** y está orientado a un entorno real de negocio con automatización y control de integridad de datos.

---

## 🧠 Objetivo

Implementar una base de datos robusta que permita:

- Gestionar ventas en una plataforma e-commerce
- Controlar inventario en tiempo real
- Automatizar procesos administrativos
- Mantener auditoría de cambios críticos
- Generar reportes automáticos
- Mejorar la integridad y consistencia de los datos

---

## 🏗️ Estructura del sistema

### 📁 Tablas principales
- clientes
- productos
- categorias
- proveedores
- ventas
- detalle_ventas
- sucursal

### 📁 Tablas auxiliares
- logs_cambios_precio
- auditoria_clientes
- auditoria_estado_pedido
- alertas_stock
- ventas_eliminadas
- resenas_productos
- creditos_cliente
- kpis_mensuales
- carritos
- promociones
- y otras tablas de auditoría y análisis

---

## ⚙️ Funcionalidades implementadas

---

## 🔥 TRIGGERS (20)

### 📌 Control de inventario
- Validación de stock antes de registrar ventas
- Descuento automático del stock tras venta
- Prevención de stock negativo

### 📌 Auditoría
- Registro de cambios de precios
- Registro de cambios de estado de pedidos
- Registro de nuevos clientes

### 📌 Validaciones de datos
- Validación de email
- Validación de precio mayor a cero
- Prevención de auto-referidos

### 📌 Automatización interna
- Actualización de fecha de modificación de productos
- Asignación de categoría por defecto
- Conteo automático de productos por categoría

---

## ⏰ EVENTOS PROGRAMADOS (20)

### 📊 Reportes automáticos
- Reporte semanal de ventas
- KPIs mensuales
- Ranking de productos más vendidos
- Dashboard administrativo

### 🧹 Mantenimiento de base de datos
- Limpieza de carritos abandonados
- Eliminación de datos temporales
- Purga de registros antiguos

### 📦 Inventario
- Lista de reabastecimiento diaria
- Alertas de bajo stock
- Suspensión de cuentas inactivas

### 🔐 Auditoría y monitoreo
- Detección de actividad sospechosa
- Registro del tamaño de la base de datos
- Log de inconsistencias

---

## 🧾 PROCEDIMIENTOS ALMACENADOS (20)

### 💰 Ventas
- Crear venta transaccional
- Procesar pagos
- Cambiar estado de pedidos
- Generar reportes de ventas

### 👤 Clientes
- Registrar clientes
- Fusionar cuentas duplicadas
- Anonimizar clientes (borrado lógico)
- Historial de compras

### 📦 Productos
- Agregar productos
- Ajustar stock manualmente
- Aplicar descuentos por categoría
- Búsqueda avanzada de productos

### 🔄 Procesos avanzados
- Procesar devoluciones
- Sistema de reseñas
- Productos relacionados
- Asignación de proveedores

---

## 🔐 Características técnicas

- Triggers BEFORE y AFTER
- Manejo de errores con SIGNAL SQLSTATE
- Uso de transacciones (COMMIT / ROLLBACK)
- Eventos programados (EVENT SCHEDULER)
- Consultas con JOIN optimizados
- Integridad referencial
- Lógica de negocio en base de datos

---

## 🧪 Tecnologías usadas

- MySQL 8+
- DBeaver / MySQL Workbench
- SQL (DDL, DML, TCL)
- Event Scheduler

---

## 🚀 Instalación y ejecución

```sql
CREATE DATABASE marketplace_pro;
USE marketplace_pro;